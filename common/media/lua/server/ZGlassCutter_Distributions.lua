local MOD_ID = "ZGlassCutter"

local COPY_DISTR = {
    [MOD_ID .. ".GlassCuttingMag"] = "GlassmakingMag1",
    [MOD_ID .. ".GlassCutter"]     = "Calipers",
}

local logger = zdk.Logger.new(MOD_ID)

local function updateDistributions()
    local t0 = os.time()
    if ProceduralDistributions then
        for dst, src in pairs(COPY_DISTR) do
            zdk.copy_distr(ProceduralDistributions.list, src, dst, logger)
        end
    else
        logger:error("ProceduralDistributions not found, skipping distribution updates.")
    end
    local t1 = os.time()
    logger:info("distribution updates completed in %.3fs", t1 - t0)
end

Events.OnPreDistributionMerge.Add(updateDistributions)
