ZGlassCutter = ZGlassCutter or {}

local function predicateGlassCutter(item)
    return item:hasTag(ISCutOutGlass.RequiredItemTag) and not item:isBroken()
end

-- global for tests
function ZGlassCutter.onCutOutGlass(playerObj, window)
    if luautils.walkAdjWindowOrDoor(playerObj, window:getSquare(), window) then
        if ISWorldObjectContextMenu.equip(playerObj, playerObj:getPrimaryHandItem(), predicateGlassCutter, true) then
            ISTimedActionQueue.add(ISCutOutGlass:new(playerObj, window));
            return true
        end
    end
end

-- only called if character has the required item
local function addCutOutGlassOption(context, character, window, cutter)
    local option = context:addOption(
        getText("IGUI_ZGlassCutter_CutOutGlass"),
        character, ZGlassCutter.onCutOutGlass, window)

    option.toolTip = ISToolTip:new()
    option.iconTexture = cutter:getTexture()

    if ISCutOutGlass.canPerform(character, window) then
        local breakChance = ISCutOutGlass.getWindowBreakChance(character, cutter)
        option.notAvailable = breakChance >= 100

        local chanceColor = ColorInfo.new(0, 0, 0, 1)
        getCore():getGoodHighlitedColor():interp(getCore():getBadHighlitedColor(), breakChance/100, chanceColor);

        option.badColor = breakChance > 50
        option.toolTip.description = string.format(
            "%s: <RGB:%f,%f,%f> <SPACE><SPACE> %d%%",
            getText("IGUI_ChanceToBreak"), chanceColor:getR()*255, chanceColor:getG()*255, chanceColor:getB()*255, breakChance
        )
    else
        option.notAvailable = true
        if character:getPerkLevel(ISCutOutGlass.RequiredPerk) < ISCutOutGlass.RequiredPerkLevel then
            option.toolTip.description = getText("Tooltip_Skill_Too_Low", ISCutOutGlass.RequiredPerk:getName())
        elseif window:isBarricaded() then
            option.toolTip.description = getText("IGUI_WindowBarricaded")
        end
    end

    return option
end

local function fillContextMenu(playerIndex, context, worldObjects, test)
    local window
    for i = 1, #worldObjects do
        local object = worldObjects[i]
        if instanceof(object, "IsoWindow") then
            window = object
            break
        end
    end

    if not window or window:isBarricaded() or window:isSmashed() or window:isGlassRemoved() then
        return
    end

    local windowOption = context:getOptionFromName(getText("Window"))
    if windowOption then
        local windowMenu = context:getSubInstance(windowOption.subOption)
        if windowMenu ~= nil then
            context = windowMenu
        end
    end

    local player = getSpecificPlayer(playerIndex)
    local cutter = player:getInventory():getItemFromTag(ISCutOutGlass.RequiredItemTag, true, true)
    if cutter then
        addCutOutGlassOption(context, player, window, cutter)
    end
end

Events.OnFillWorldObjectContextMenu.Add(fillContextMenu)
