local CHECKS = {
    ["ZGlassCutter.GlassCuttingMag"] = "LibraryMagazines",
    ["ZGlassCutter.GlassCutter"]     = "MechanicTools",
}

for itemType, distName in pairs(CHECKS) do
    describe(itemType, function()
        it("is registered with ScriptManager", function()
            local item = ScriptManager.instance:getItem(subject)
            assert(item)
        end)
        
        it("can be instantiated", function()
            local item = create_item(subject)
            assert(item)
        end)
        
        it("is present in " .. distName .. " distribution", function()
            local dist = ProceduralDistributions.list[distName]
            assert(dist, distName .. " distribution not found")
            
            local found = false
            for i = 1, #dist.items, 2 do
                if dist.items[i] == subject then
                    found = true
                    break
                end
            end
            assert(found)
        end)

        it("has nonzero spawn chance", function()
            local dist = ProceduralDistributions.list[distName]
            assert(dist, distName .. " distribution not found")
            
            -- Simulate the roll logic: items array is [item1, weight1, item2, weight2, ...]
            -- Build a weighted list and check our books have non-zero weights
            local foundItems = {}
            local totalWeight = 0
            
            for i = 1, #dist.items, 2 do
                local itemType = dist.items[i]
                local weight = dist.items[i + 1] or 0
                
                if type(itemType) == "string" and itemType == subject then
                    foundItems[itemType] = weight
                end
                
                if type(weight) == "number" then
                    totalWeight = totalWeight + weight
                end
            end
            
            -- Verify books are present with positive weights
            assert.gt(foundItems[subject], 0)
            
            -- Calculate spawn probability
            local book1Weight = foundItems[subject] or 0
            local spawnChance = book1Weight / totalWeight * 100
            assert.gt(spawnChance, 0)
        end)
    end)
end

return ZBSpec.run()
