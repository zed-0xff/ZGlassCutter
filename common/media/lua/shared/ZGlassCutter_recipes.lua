local logger = zdk.Logger.new("ZGlassCutter")

-- ...
-- [ZGlassCutter] Patching recipe 87ScampCamperMakeRearSideWindow
-- [ZGlassCutter] Patching recipe 85chevyStepVanMakeFrontWindshield
-- [ZGlassCutter] Patching recipe CUDAMakeRearSideWindow
-- [ZGlassCutter] Patching recipe 90pierceArrowMakeSideWindow
-- [ZGlassCutter] Patching recipe 93fordTaurusMakeRearWindshield
-- [ZGlassCutter] Patching recipe 92fordCVPIMakeRearSideWindow
-- [ZGlassCutter] Patching recipe 63beetleMakeFrontSideWindow
-- ...

-- find all recipes using scalpel and glass pane, and add glass cutter as an alternative to scalpel
local function patchScalpelAndGlassRecipes()
    local recipes = getScriptManager():getAllCraftRecipes()
    logger:info("found %d recipes", recipes:size())
    for i=0,recipes:size()-1 do
        local recipe = recipes:get(i)
        -- XXX for some reason canUseItem() returns false in OnGameBoot
        --if recipe:canUseItem("Base.Scalpel") and recipe:canUseItem("Base.GlassPanel") then
            -- logger:info("Found recipe %s that uses scalpel and glass panel", recipe:getName())
            local inputs = recipe:getInputs()
            local newLines = {}
            local scalpelFound = false
            for j=0,inputs:size()-1 do
                local input = inputs:get(j)
                if input:getOriginalLine() == "item 1 [Base.Scalpel] mode:keep" then
                    scalpelFound = true
                    table.insert(newLines, "item 1 [Base.Scalpel;ZGlassCutter.GlassCutter] mode:keep")
                else
                    table.insert(newLines, input:getOriginalLine())
                end
            end
            if scalpelFound then
                logger:info("Patching recipe %s", recipe:getName())

                local newInputs = "{ inputs {\n" .. table.concat(newLines, ",\n") .. ",\n} }"
                inputs:clear()
                recipe:Load(recipe:getName(), newInputs)
--            else
--                logger:warn("Scalpel not found in recipe %s", recipe:getName())
            end
        --end
    end
end

Events.OnGameBoot.Add(patchScalpelAndGlassRecipes)
