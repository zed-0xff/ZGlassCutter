-- local x = getCore():getScreenWidth() / 2
-- local y = getCore():getScreenHeight() / 2
-- local obj=getPlayer():getSquare():getObjects():get(0)
-- triggerEvent("OnObjectRightMouseButtonDown", obj, x, y)
-- triggerEvent("OnObjectRightMouseButtonUp", obj, x, y)

describe("player", function()
    -- XXX as of 42.13.2 recipe has to be in 'Base' module :( -- https://pzwiki.net/wiki/CraftRecipe
    local RECIPE_ID   = "MakeGlassCutter"
    local MAGAZINE_ID = "ZGlassCutter.GlassCuttingMag"
    local CUTTER_ID   = "ZGlassCutter.GlassCutter"

    local player = get_player()
    local recipe = getScriptManager():getCraftRecipe(RECIPE_ID)

    before_each(function()
        init_player(player)
    end)

    it("can learn recipe from the magazine", function()
        set_sandbox_option("MinutesPerPage", 0.001)
        set_timed_action_instant(false) -- breaks skillbooks reading in SP

        assert.is_false(player:isRecipeActuallyKnown(RECIPE_ID))
        assert.is_false(player:isRecipeActuallyKnown(recipe))

        local magazine = add_item(player, MAGAZINE_ID)
        read_book(player, magazine)

        assert(player:isRecipeActuallyKnown(RECIPE_ID))
        assert(player:isRecipeActuallyKnown(recipe))
    end)

    it("can craft the cutter", function()
        assert( recipe )

        all_exec("(getPlayer() or getOnlinePlayers():get(0)):getKnownRecipes():add('" .. RECIPE_ID .. "')")
        local table = place_table(get_player():getSquare())
        set_perk_level(player, Perks.Maintenance, 1)
        set_timed_action_instant(true) -- set to false to check the actual animation

        add_item(player, "Base.Diamond")
        add_item(player, "Base.Epoxy")
        add_item(player, "Base.CompassGeometry")
        add_item(player, "Base.Hammer")

        local containers = ISInventoryPaneContextMenu.getContainers(player)
        assert( containers )

        local craftBench = nil
        local logic = HandcraftLogic.new(player, craftBench, table)
        logic:setContainers(containers)
        logic:setRecipe(recipe)
        logic:setManualSelectInputs(true)

        assert(logic:isValidRecipeForCharacter(recipe))
        assert(logic:isRecipeAvailableForCharacter(recipe))
        assert(logic:canCharacterPerformRecipe(recipe))

        local action = ISHandcraftAction.FromLogic(logic)
        ISTimedActionQueue.add(action);

        local inv = player:getInventory()
        timeout(30, function()
            wait_for(inv.contains, inv, CUTTER_ID)
        end)

        assert(not inv:contains("Base.Diamond"))
        assert(not inv:contains("Base.CompassGeometry"))
        assert(inv:contains("Base.Epoxy"))
        assert(inv:contains("Base.Hammer"))
    end)
end)

return ZBSpec.runAsync()
