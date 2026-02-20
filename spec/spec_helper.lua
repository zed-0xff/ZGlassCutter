function get_player()
    if isServer() then
        return getOnlinePlayers():get(0) -- XXX assumes only one player online
    else
        return getPlayer()
    end
end

function create_item(itemFullType)
    local item = instanceItem(itemFullType)
    assert(item, "Failed to create item: " .. itemFullType)
    return item
end
