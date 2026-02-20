describe("ZGlassCutter.MakeGlassCutter", function()
    it("exists", function()
        local recipe = getScriptManager():getCraftRecipe(subject)
        assert(recipe)
    end)
end)

return ZBSpec.run()
