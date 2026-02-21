describe(ISCutOutGlass, function()
    local player = get_player()
    local cutter = create_item(CUTTER_ID)

    it("exists", function()
        assert(described_class)
    end)

    it("has RequiredPerk = Maintenance", function()
        assert.eq(Perks.Maintenance, described_class.RequiredPerk)
    end)

    it("has RequiredPerkLevel = 1", function()
        assert.eq(1, described_class.RequiredPerkLevel)
    end)

    it("has RequiredItemTag matching Tags.GlassCutter", function()
        assert.eq(ZGlassCutter.Tags.GlassCutter, described_class.RequiredItemTag)
    end)

    it("has MinDuration and MaxDuration in range", function()
        assert(described_class.MinDuration >= 1)
        assert(described_class.MaxDuration >= described_class.MinDuration)
    end)

    it("predicateNotBroken returns true for unbroken item", function()
        local item = create_item(CUTTER_ID)
        assert.is_true(described_class.predicateNotBroken(item))
    end)

    it("predicateNotBroken returns false for broken item", function()
        local item = create_item(CUTTER_ID)
        item:setCondition(0)
        assert.is_true(item:isBroken())
        assert.is_false(described_class.predicateNotBroken(item))
    end)

    describe("getDuration()", function()
        before_all(function()
            set_timed_action_instant(false)
        end)

        it("is lower with higher Maintenance perk", function()
            local action = ISCutOutGlass:new(player, cutter)

            set_perk_level(player, Perks.Maintenance, 5)
            local reduced = action:getDuration()

            set_perk_level(player, Perks.Maintenance, 1)
            local base = action:getDuration()

            assert.lt(reduced, base)
        end)
    end)

    describe("getWindowBreakChance()", function()
        before_all(function()
            init_player()
        end)

        it("returns a number between 1 and 100", function()
            assert(player)
            local chance = described_class.getWindowBreakChance(player, cutter)
            assert.is_number(chance)
            assert.gt(chance, 0)
            assert.lt(chance, 101)
        end)

        it("is lower with higher Maintenance perk", function()
            set_perk_level(player, Perks.Maintenance, 1)
            local baseChance = described_class.getWindowBreakChance(player, cutter)

            set_perk_level(player, Perks.Maintenance, 5)
            local reducedChance = described_class.getWindowBreakChance(player, cutter)

            assert.lt(reducedChance, baseChance)
        end)

        it("is lower if player has Engineer profession", function()
            player:getDescriptor():setCharacterProfession(CharacterProfession.UNEMPLOYED)
            local baseChance = described_class.getWindowBreakChance(player, cutter)

            player:getDescriptor():setCharacterProfession(CharacterProfession.ENGINEER)
            local reducedChance = described_class.getWindowBreakChance(player, cutter)

            assert.lt(reducedChance, baseChance)
        end)

        it("is lower if player is drunk", function()
            local stat = CharacterStat.INTOXICATION
            player:getStats():set(stat, stat:getMaximumValue())
            local drunkChance = described_class.getWindowBreakChance(player, cutter)

            player:getStats():set(stat, stat:getDefaultValue())
            local baseChance = described_class.getWindowBreakChance(player, cutter)

            assert.gt(drunkChance, baseChance)
        end)

        it("is lower if player is all-thumbs", function()
            player:getCharacterTraits():add(CharacterTrait.ALL_THUMBS)
            local allThumbsChance = described_class.getWindowBreakChance(player, cutter)

            player:getCharacterTraits():remove(CharacterTrait.ALL_THUMBS)
            local baseChance = described_class.getWindowBreakChance(player, cutter)

            assert.gt(allThumbsChance, baseChance)
        end)
    end)
end)

return ZBSpec.runAsync()
