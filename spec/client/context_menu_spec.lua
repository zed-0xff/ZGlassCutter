local SCR_CENTER_X = getCore():getScreenWidth() / 2
local SCR_CENTER_Y = getCore():getScreenHeight() / 2

describe("context menu", function()
    local player = get_player()
    local window, menu, window_option, window_submenu

    before_all(function()
        init_player(player)
        add_item(player, CUTTER_ID)
        ISContextManager.getInstance():getWorldMenu().printDebug = function(data)
            menu = data
        end
    end)

    before_each(function()
        window = place_window(player:getSquare(), "fixtures_windows_01_1")
        triggerEvent("OnObjectRightMouseButtonDown", window, SCR_CENTER_X, SCR_CENTER_Y)
        triggerEvent("OnObjectRightMouseButtonUp",   window, SCR_CENTER_X, SCR_CENTER_Y)

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

        it("has 'Cut out glass' option", function()
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

return ZBSpec.runAsync()
