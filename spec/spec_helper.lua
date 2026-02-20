function create_item(itemFullType)
    local item = instanceItem(itemFullType)
    assert(item, "Failed to create item: " .. itemFullType)
    return item
end
