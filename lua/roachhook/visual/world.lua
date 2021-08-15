local floorMats = {
    ["dev/dev_measuregeneric01b"] = true
}
local lastColor = Color(0, 0, 0, 0)
local function WorldModulation()
    local clr0 = RoachHook.Config["visuals.b_world_modulation.color"]
    if(!clr0) then return end

    local world = game.GetWorld()
    local mats = world:GetMaterials()

    if(RoachHook.Config["visuals.b_world_modulation"]) then
        if(lastColor.r != clr0.r || lastColor.g != clr0.g || lastColor.b != clr0.b || lastColor.a != clr0.a) then
            for k,v in ipairs(mats) do            
                local mat = Material(v)
                mat:SetVector("$color", Vector(clr0.r / 255, clr0.g / 255, clr0.b / 255))
                
                if(floorMats[v]) then continue end
                mat:SetFloat("$alpha", clr0.a / 255)
            end

            lastColor.r = clr0.r
            lastColor.g = clr0.g
            lastColor.b = clr0.b
            lastColor.a = clr0.a
        end
    else
        for k,v in ipairs(mats) do
            local mat = Material(v)
            mat:SetVector("$color", Vector(1, 1, 1))
            mat:SetFloat("$alpha", 1)
        end
    end
end
local function PropModulation()
    local clr = RoachHook.Config["visuals.b_prop_modulation.color"]
    if(!clr) then return end

    if(RoachHook.Config["visuals.b_prop_modulation"]) then
        for k, v in ipairs(ents.FindByClass("prop_*")) do
            v:SetColor(clr)
        end
    else
        for k, v in ipairs(ents.FindByClass("prop_*")) do
            v:SetColor(color_white)
        end
    end
end

RoachHook.OverlayHook[#RoachHook.OverlayHook + 1] = function()
    WorldModulation()
    PropModulation()
end