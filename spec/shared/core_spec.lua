describe("ZGlassCutter module", function()
    it("exists", function()
        assert(ZGlassCutter)
    end)

    it("has Tags.GlassCutter", function()
        assert(ZGlassCutter.Tags)
        assert(ZGlassCutter.Tags.GlassCutter)
    end)
end)

return ZBSpec.run()
