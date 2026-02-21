require "TimedActions/ISBaseTimedAction"

ISCutOutGlass = ISBaseTimedAction:derive("ISCutOutGlass")

--- constants

ISCutOutGlass.RequiredPerk      = Perks.Maintenance
ISCutOutGlass.RequiredPerkLevel = 1
ISCutOutGlass.RequiredItemTag   = ZGlassCutter.Tags.GlassCutter
ISCutOutGlass.MinDuration       = 50
ISCutOutGlass.MaxDuration       = 200

--- helper functions

local function clamp(_value, _min, _max)
    if _min > _max then _min, _max = _max, _min; end;
    return math.min(math.max(_value, _min), _max);
end

--- static methods

function ISCutOutGlass.getWindowBreakChance(character, cutter) -- returns 0-100
    local chance = (
        75
        - character:getPerkLevel(Perks.Maintenance) * 5
        - character:getPerkLevel(Perks.Glassmaking) * 5
        - character:getPerkLevel(Perks.Science)     * 5 -- will return 0 if perk is not defined
        - character:getPerkLevel(Perks.Aiming)      * 5
        - character:getPerkLevel(Perks.Woodwork)    * 5
        - character:getPerkLevel(Perks.Agility)     * 5
    )

    chance = chance / forageSystem.getPanicPenalty(character)
    chance = chance / forageSystem.getBodyPenalty(character) -- TODO: drunk / tired

    if character:tooDarkToRead() then
        chance = chance + 20
    end

    if character:getDescriptor():isCharacterProfession(CharacterProfession.ENGINEER) then
        chance = chance / 2
    end

    if character:hasTrait(CharacterTrait.ALL_THUMBS) or character:isWearingAwkwardGloves() then
        chance = chance + 40
    end

    if cutter and ZItemTiers and ZItemTiers.GetItemTierIndex then
        local tierIdx = ZItemTiers.GetItemTierIndex(cutter)
        if tierIdx then
            chance = chance - (tierIdx - 1) * 10 -- 10% reduction per tier > Common
        end
    end

    return clamp(chance, 1, 100)
end

function ISCutOutGlass.predicateNotBroken(item)
    return not item:isBroken()
end

function ISCutOutGlass.canPerform(character, window) -- called by context menu handler
    return  window and character and
            window:getObjectIndex() ~= -1 and 
        not window:isSmashed() and 
        not window:isGlassRemoved() and
        not window:isBarricaded() and
         character:getPerkLevel(ISCutOutGlass.RequiredPerk) >= ISCutOutGlass.RequiredPerkLevel and
         character:getInventory():containsTagEval(ISCutOutGlass.RequiredItemTag, ISCutOutGlass.predicateNotBroken)
end

--- instance methods

function ISCutOutGlass:new(character, window)
	local o = ISBaseTimedAction.new(self, character);
	o.window = window
	o.maxTime = o:getDuration()
    o.useProgressBar = true
    o.caloriesModifier = 8
    return o
end

function ISCutOutGlass:isValid()
    if not self.character:hasEquippedTag(ISCutOutGlass.RequiredItemTag) then
        return false
    end
    return ISCutOutGlass.canPerform(self.character, self.window)
end

function ISCutOutGlass:waitToStart()
	self.character:faceThisObject(self.window)
	return self.character:shouldBeTurning()
end

function ISCutOutGlass:update()
	self.character:faceThisObject(self.window)
    self.character:setMetabolicTarget(Metabolics.UsingTools)
end

function ISCutOutGlass:start()
    -- effect sound
    local emitter = self.character:getEmitter()
    self.sound = emitter:playSound("cutGlass")
    emitter:setVolume(self.sound, 0.5)
    local pitch = 0.62 * ISCutOutGlass.MaxDuration / self.maxTime
    emitter:setPitch(self.sound, pitch) -- try to match the duration

    -- world sound
    local soundRadius = 3
    local soundVolume = 0.5
    addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), soundRadius, soundVolume)

	self:setActionAnim("Loot")
	self.character:SetVariable("LootPosition", "Mid")
	self:setOverrideHandModels(nil, nil)
	self.character:reportEvent("EventLootItem");
end

function ISCutOutGlass:stop()
    self.character:stopOrTriggerSound(self.sound)
	ISBaseTimedAction.stop(self)
end

function ISCutOutGlass:perform()
    self.character:stopOrTriggerSound(self.sound)
--    if isClient() then
--        self.character:playerVoiceSound("PainFromGlassCut")
--    end

	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ISCutOutGlass:complete()
    local cutter = self.character:getPrimaryHandItem()
    local condLowerChance = cutter:getConditionLowerChance() + self.character:getMaintenanceMod()

    -- ZombRand(100) returns 1-100 so:
    --  if break chance is 99% then random value of 99 should not break ia
    --  if break chance is  1% then random value of  0 should break ia
    if ZombRand(100) < ISCutOutGlass.getWindowBreakChance(self.character, cutter) then
        condLowerChance = condLowerChance / 2 -- more likely to lower condition if window breaks
        self.window:smashWindow()

        local gloves = self.character:getWornItem(ItemBodyLocation.HANDS)
        if gloves and not gloves:isBroken() and gloves:getScratchDefense() > 0 then
            gloves:setCondition(gloves:getCondition() - 1)
        else
            self.character:getBodyDamage():setScratchedWindow()
            sendDamage(self.character)
        end
    else
        self.window:setSmashed(true);
        self.window:setGlassRemoved(true)

        local inventory = self.character:getInventory()
        local item = inventory:AddItem("Base.GlassPanel")
        sendAddItemToContainer(inventory, item)
    end

    if ZombRand(condLowerChance) == 0 then
        cutter:setCondition(cutter:getCondition() - 1)
    end

	if isServer() then
		self.window:sync()
	end
	return true;
end

function ISCutOutGlass:getDuration()
	if self.character:isTimedActionInstant() then
		return 1;
	end
	local dur = 200 - (
        self.character:getPerkLevel(Perks.Maintenance) + 
        self.character:getPerkLevel(Perks.Mechanics)   + 
        self.character:getPerkLevel(Perks.Glassmaking) +
        self.character:getPerkLevel(Perks.Science)
    ) * 5

	return clamp(dur, ISCutOutGlass.MinDuration, ISCutOutGlass.MaxDuration)
end
