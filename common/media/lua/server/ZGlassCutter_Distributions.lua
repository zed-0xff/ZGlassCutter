local MOD_ID = "ZGlassCutter"

local COPY_DISTR = {
    [MOD_ID .. ".GlassCuttingMag"] = "GlassmakingMag1",
    [MOD_ID .. ".GlassCutter"]     = "Calipers",
}

local logger = {
    debug = function(...) print(string.format("[d] %s: %s", MOD_ID, string.format(...))) end,
    info  = function(...) print(string.format("[.] %s: %s", MOD_ID, string.format(...))) end,
    warn  = function(...) print(string.format("[?] %s: %s", MOD_ID, string.format(...))) end,
    error = function(...) print(string.format("[!] %s: %s", MOD_ID, string.format(...))) end,
}

local function copyDistr(rootTbl, srcKey, dstKey)
    if type(rootTbl) ~= "table" then
        logger.warn("copyDistr(rootTbl, '%s', '%s'): expected a table but got %s", srcKey, dstKey, type(rootTbl))
        return 0
    end

    local nAdded = 0
    for tableName, dist in pairs(rootTbl) do
        if type(dist) == "table" and dist.items then
            for i = 1, #dist.items, 2 do
                if dist.items[i] == srcKey then
                    -- assuming table structure is consistent and contains pairs of key and weight, so the weight is always at index i + 1
                    local weight = dist.items[i + 1]

                    -- logger.debug("adding %s to distribution %s with weight %d", dstKey, tableName, weight)
                    table.insert(dist.items, dstKey)
                    table.insert(dist.items, weight)
                    nAdded = nAdded + 1
                    break -- intended break of inner loop only
                end
            end
        end
    end
    logger.info("added %d entries for '%s'", nAdded, dstKey)

    -- return value is unused for now, but may be useful for testing or logging in the future
    return nAdded
end

local function updateDistributions()
    local t0 = os.time()
    if ProceduralDistributions then
        for dst, src in pairs(COPY_DISTR) do
            copyDistr(ProceduralDistributions.list, src, dst)
        end
    else
        logger.error("ProceduralDistributions not found, skipping distribution updates.")
    end
    local t1 = os.time()
    logger.info("distribution updates completed in %.3fs", t1 - t0)
end

Events.OnPreDistributionMerge.Add(updateDistributions)
