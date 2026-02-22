CUTTER_ID = "ZGlassCutter.GlassCutter"
GLASS_ID  = "Base.GlassPanel"

-- TODO: MP
function set_panic(player, bPanic)
    local panicStat = CharacterStat.PANIC
    player:getStats():set(panicStat, bPanic and panicStat:getMaximumValue() or panicStat:getMinimumValue())
end

local function getObjectWithSprite(square, spriteName)
    if not square then return nil end
    for i=1,square:getObjects():size() do
        local isoObject = square:getObjects():get(i-1)
        if isoObject:getSprite() and ((isoObject:getSprite():getName() == spriteName) or
                (isoObject:getSpriteName() == spriteName)) then
            return isoObject
        end
    end
    return nil
end

function place_window(square, name)
    remove_all_non_floor(square)

    local window = IsoWindow.new(getCell(), square, getSprite(name), true)
    square:AddSpecialObject(window)
    if isClient() then
        window:transmitCompleteItemToServer()
    end
    if isServer() then
        window:transmitCompleteItemToClients()
    end
    if square.getObjectWithSprite then
        return square:getObjectWithSprite(name) -- 42.13.2+
    else
        return getObjectWithSprite(square, name)
    end
end

function place_table(square)
    return place_tile(square, "furniture_tables_high_01_14")
end
