local SCR_CENTER_X = getCore():getScreenWidth() / 2
local SCR_CENTER_Y = getCore():getScreenHeight() / 2

--[[
local function open_context_menu_and_find_cut_out_glass()
    local window = place_window(get_player():getSquare(), "fixtures_windows_01_1")

    local menu = nil
    ISContextManager.getInstance():getWorldMenu().printDebug = function(data)
        menu = data
    end
    -- Trigger a re-fill so printDebug runs with latest menu state
    triggerEvent("OnObjectRightMouseButtonDown", window, SCR_CENTER_X, SCR_CENTER_Y)
    triggerEvent("OnObjectRightMouseButtonUp",   window, SCR_CENTER_X, SCR_CENTER_Y)
    ZBSpec.wait_for(function() return menu end)

    print("===", menu, "===")

    local window_submenu
    for _, option in ipairs(menu.context.options) do
        if option.name == "Window" then
            window_submenu = menu.context:getSubInstance(option.subOption)
            break
        end
    end

    local cut_out_glass_option
    if window_submenu then
        for _, opt in ipairs(window_submenu.options) do
            if opt.name == "Cut out glass" then
                cut_out_glass_option = opt
                break
            end
        end
    end
    return cut_out_glass_option
end

describe("test", function()
    before_all(function()
        init_player()
    end)

    context("when player has no cutter", function()
        it("does not show the 'Cut out glass' option", function()
            local cut_out_glass_option = open_context_menu_and_find_cut_out_glass()
            assert.is_nil(cut_out_glass_option)
        end)
    end)

    context("when player has a cutter", function()
        before_all(function()
            add_item(get_player(), CUTTER_ID)
        end)

        it("shows the 'Cut out glass' option", function()
            local cut_out_glass_option = open_context_menu_and_find_cut_out_glass()
            assert(cut_out_glass_option)
        end)
    end)
end)
]]

describe("context menu", function()
    local player = get_player()
    local window, menu, window_option, window_submenu

    before_all(function()
        init_player(player)
        -- add_item(player, CUTTER_ID)
        ISContextManager.getInstance():getWorldMenu().printDebug = function(data)
            menu = data
        end
    end)

    after_each(function()
        -- dismiss the menu by clicking outside of it
        triggerEvent("OnObjectLeftMouseButtonDown", nil, 0, 0)
    end)

    before_each(function()
        menu = nil
        window = place_window(player:getSquare(), "fixtures_windows_01_1")
        triggerEvent("OnObjectRightMouseButtonDown", window, SCR_CENTER_X, SCR_CENTER_Y)
        triggerEvent("OnObjectRightMouseButtonUp",   window, SCR_CENTER_X, SCR_CENTER_Y)

        wait_for(function() return menu end)

        window_option = nil
        window_submenu = nil
        for _, option in ipairs(menu.context.options) do
            if option.name == "Window" then
                window_option = option
                window_submenu = menu.context:getSubInstance(window_option.subOption)
                break
            end
        end
    end)

    it("has 'Window' option", function()
        assert(window_option)
    end)

    it("has 'Window' submenu", function()
        assert(window_submenu)
    end)

    describe("'Window' submenu", function()
        local cut_out_glass_option

        before_each(function()
            cut_out_glass_option = nil
            for _, option in ipairs(window_submenu.options) do
                if option.name == "Cut out glass" then
                    cut_out_glass_option = option
                    break
                end
            end
        end)

        context("when player has no cutter", function()
            it("does not show the 'Cut out glass' option", function()
                assert.is_nil(cut_out_glass_option)
            end)
        end)

        context("when player has a cutter", function()
            before_all(function()
                add_item(player, CUTTER_ID)
            end)

            it("shows the 'Cut out glass' option", function()
                assert(cut_out_glass_option)
            end)

            describe("'Cut out glass' option", function()
                it("has texture of the cutter item", function()
                    assert(cut_out_glass_option.iconTexture)
                    assert.eq(cut_out_glass_option.iconTexture, create_item(CUTTER_ID):getTexture())
                end)
            end)
        end)
    end)
end)

return ZBSpec.runAsync()
