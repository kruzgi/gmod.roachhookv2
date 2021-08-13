local mats = {
    RoachHook.Materials.chams.none,
    RoachHook.Materials.chams.textured,
    RoachHook.Materials.chams.textured,
    RoachHook.Materials.chams.wireframe,
    RoachHook.Materials.chams.metalic,
}

hook.Add("PreDrawViewModel", "viewmodelchams", function(vm,plr, weapon)
    if(!RoachHook.Config["player.b_viewmodel_chams"]) then
        render.SuppressEngineLighting(false)
        render.SetColorModulation(1, 1, 1)
        render.MaterialOverride(RoachHook.Materials.chams.none)
        render.SetBlend(1)

        return
    end
    if(RoachHook.Config["misc.b_obs_proof"] && RoachHook.Config["misc.b_obs_proof.b_auto_hide"]) then return end

    local clr = RoachHook.Config["player.b_viewmodel_chams.color"]

    render.SuppressEngineLighting(RoachHook.Config["player.b_viewmodel_chams.mat"] == 3)
    render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
    render.MaterialOverride(mats[RoachHook.Config["player.b_viewmodel_chams.mat"]])
    render.SetBlend(clr.a / 255)
end)
hook.Add("PostDrawViewModel", "viewmodelchams", function()
    render.SetColorModulation(1, 1, 1)
    render.MaterialOverride(RoachHook.Materials.chams.none)
    render.SetBlend(1)
    render.SuppressEngineLighting(false)
end)

hook.Add("PreDrawPlayerHands", "handchams", function()
    if(!RoachHook.Config["player.b_hand_chams"]) then
        render.SuppressEngineLighting(false)
        render.SetColorModulation(1, 1, 1)
        render.MaterialOverride(RoachHook.Materials.chams.none)
        render.SetBlend(1)
        
        return
    end
    if(RoachHook.Config["misc.b_obs_proof"] && RoachHook.Config["misc.b_obs_proof.b_auto_hide"]) then return end

    local clr = RoachHook.Config["player.b_hand_chams.color"]

    render.SuppressEngineLighting(RoachHook.Config["player.b_hand_chams.mat"] == 3)
    render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
    render.MaterialOverride(mats[RoachHook.Config["player.b_hand_chams.mat"]])
    render.SetBlend(clr.a / 255)
end)
hook.Add("PostDrawPlayerHands", "handchams", function()
    render.SetColorModulation(1, 1, 1)
    render.MaterialOverride(RoachHook.Materials.chams.none)
    render.SetBlend(1)
end)