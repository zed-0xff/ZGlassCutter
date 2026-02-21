describe("MakeGlassCutter", function()
    local recipe = getScriptManager():getCraftRecipe(subject)

    it("exists", function()
        assert(recipe)
    end)

    it("is not handcraft", function()
        assert.is_false(recipe:isInHandCraftCraft())
    end)

    it("is any surface craft", function()
        assert.is_true(recipe:isAnySurfaceCraft())
    end)

    it("can not be done in dark", function()
        assert.is_false(recipe:canBeDoneInDark())
    end)

    it("needs to be learned", function()
        assert.is_true(recipe:needToBeLearn())
    end)

    it("is not known by default", function()
        init_player()
        assert.is_false(get_player():isRecipeActuallyKnown(subject))
    end)
end)

return ZBSpec.run()
