local NTIMES = 30

describe("ZGlassCutter.onCutOutGlass", function()
    local player = get_player()
    local cutter, gloves

    local function run_series()
        local nok = 0
        for i = 1, NTIMES do
            local window = place_window(player:getSquare(), "fixtures_windows_01_1")

            assert(ZGlassCutter.onCutOutGlass(player, window))
            wait_for_not(ISTimedActionQueue.isPlayerDoingAction, player)

            wait_for(window.isSmashed, window)
            if window:isGlassRemoved() then
                nok = nok + 1
            end

            if cutter:getCondition() == 0 then
                break
            end
        end
        return nok
    end

    before_all(function()
        set_timed_action_instant(true)
    end)

    before_each(function()
        init_player(player)
        cutter = add_item(player, CUTTER_ID)
        gloves = add_item(player, "Base.Gloves_LeatherGloves")
        player:setWornItem(gloves:getBodyLocation(), gloves)

        player:setGodMod(false)
        player:setInvincible(false)
    end)

    context("with low skills", function()
        before_each(function()
            set_perk_level(player, Perks.Maintenance, 1)
        end)

        it("breaks the window and damages the gloves and player", function()
            local gloves_cond0 = gloves:getCondition()
            assert.gt(gloves_cond0, 0)

            local cutter_cond0 = cutter:getCondition()
            assert.eq(10, cutter_cond0)

            local nok = run_series()
            local cutter_cond1 = cutter:getCondition()
            print("[d] perk level  1: got " .. nok .. "/" .. NTIMES .. ", wear = " .. (cutter_cond0 - cutter_cond1))

            assert.gt(nok, 1)
            assert.lt(nok, NTIMES/2)
            assert.lt(cutter_cond1, cutter_cond0, "wears the cutter")

            local gloves_cond1 = gloves:getCondition()
            assert.eq(0, gloves_cond1, "wears the gloves")

            assert(player:getBodyDamage():HasInjury(), "damages hands")
        end)
    end)

    context("with top skills", function()
        before_each(function()
            set_perk_level(player, Perks.Maintenance, 10)
            set_perk_level(player, Perks.Glassmaking, 10)
            set_perk_level(player, Perks.Woodwork,    10)
        end)

        it("cuts the glass", function()
            local cond0 = cutter:getCondition()
            local nok = run_series()
            local cond1 = cutter:getCondition()
            print("[d] perk level 10: got " .. nok .. "/" .. NTIMES .. ", wear = " .. (cond0 - cond1))

            assert.gt(nok, NTIMES/2)
            assert.gt(cond1, 0)

            assert.is_false(player:getBodyDamage():HasInjury())
        end)
    end)
end)

return ZBSpec.runAsync()
