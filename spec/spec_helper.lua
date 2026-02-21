CUTTER_ID = "ZGlassCutter.GlassCutter"

function set_sandbox_option(option, value)
    ZBSpec.all_exec("getSandboxOptions():getOptionByName(\"" .. option .. "\"):setValue(" .. tostring(value) .. ")")
end

function set_timed_action_instant(value)
    -- Can't use get_player() here - all_exec sends code as string to server
    -- where spec_helper functions aren't available
    ZBSpec.all_exec("(getPlayer() or getOnlinePlayers():get(0)):setTimedActionInstantCheat(" .. tostring(value) .. ")")
end

function get_player()
    if isServer() then
        return getOnlinePlayers():get(0) -- XXX assumes only one player online
    else
        return getPlayer()
    end
end

-- TODO: MP
function set_panic(player, bPanic)
    local panicStat = CharacterStat.PANIC
    player:getStats():set(panicStat, bPanic and panicStat:getMaximumValue() or panicStat:getMinimumValue())
end

function init_player(player)
    if not player then
        player = get_player()
    end
    -- Abort any action the player is currently doing
    if ISTimedActionQueue and ISTimedActionQueue.clear then
        ISTimedActionQueue.clear(get_player())
    end
    if isClient() then
        -- Use server_eval (not server_exec) to wait for server to complete clearing
        -- before test continues. Otherwise race condition: add_item might run before
        -- server processes the clear, causing items to disappear after being added.
        server_eval("getOnlinePlayers():get(0):getInventory():removeAllItems()")
        server_eval("getOnlinePlayers():get(0):getReadLiterature():clear()")
        server_eval("getOnlinePlayers():get(0):forgetRecipes()")
    end
    -- both for SP and MP client
    player:getInventory():removeAllItems()
    player:getReadLiterature():clear()
    player:forgetRecipes()

    set_panic(player, false)
end


function read_book(player, book)
    ISTimedActionQueue.add(ISReadABook:new(player, book, 1))
    ZBSpec.wait_for_not(ISTimedActionQueue.isPlayerDoingAction, player)
end

function create_item(itemFullType)
    local item = instanceItem(itemFullType)
    assert(item, "Failed to create item: " .. itemFullType)
    return item
end

function add_item(player, itemFullType)
    local item = nil
    if isClient() then
        -- MP
        SendCommandToServer("/additem \"" .. player:getDisplayName() .. "\" \"" .. itemFullType .. "\"")
        local inv = player:getInventory()
        wait_for(inv.contains, inv, itemFullType)
        item = inv:getItemFromType(itemFullType, false, false)
    else
        -- SP
        item = create_item(itemFullType)
        player:getInventory():AddItem(item)
    end
    assert(item, "Failed to create item: " .. itemFullType)
    return item
end

function remove_all_non_floor(square)
    local toRemove = {}
    for i = 0, square:getObjects():size() - 1 do
        local obj = square:getObjects():get(i)
        if not obj:isFloor() then
            table.insert(toRemove, obj)
        end
    end

    for _, obj in ipairs(toRemove) do
        square:DeleteTileObject(obj) -- or RemoveTileObject ?
    end
end

function place_tile(square, name)
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if obj:getSprite():getName() == name then
            return obj
        end
    end
    remove_all_non_floor(square)
    return square:addTileObject(name)
end

function place_window(square, name)
    remove_all_non_floor(square)
    local window = IsoWindow.new(getCell(), square, getSprite(name), true)
    square:AddSpecialObject(window)
    return square:getObjectWithSprite(name)
end

function place_table(square)
    return place_tile(square, "furniture_tables_high_01_14")
end

function set_perk_level(player, perk, level)
    ZBSpec.all_exec("(getPlayer() or getOnlinePlayers():get(0)):setPerkLevelDebug(Perks." .. tostring(perk) .. ", " .. level .. ")")
end
