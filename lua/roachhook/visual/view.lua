RoachHook.Detour.hook.Add("CalcView", "ViewFix", function(plr, orig, angles, fov)
    if(!LocalPlayer():Alive()) then return end

    if(RoachHook.Config["fakelag.b_enable"] && RoachHook.Config["fakelag.b_fakeduck"] && RoachHook.PressedVars["fakelag.b_fakeduck.key"]) then
        orig.z = LocalPlayer():GetPos().z + 64
    end

    if(RoachHook.Config["misc.camera.b_thirdperson"] && RoachHook.PressedVars["misc.camera.b_thirdperson.key"]) then
        local trc = util.TraceHull({
            start = orig,
            endpos = orig - (RoachHook.SilentAimbot:Forward() * RoachHook.Config["misc.camera.b_thirdperson.i_dist"]),
            mins = Vector(-3.75, -3.75, -3.75),
            maxs = Vector(3.75, 3.75, 3.75),
            mask = MASK_SHOT,
            filter = RoachHook.Detour.player.GetAll(),
        })

        orig = trc.HitPos
    end
    
    local anglee = ((RoachHook.Config["misc.camera.b_thirdperson"] && RoachHook.PressedVars["misc.camera.b_thirdperson.key"]) || (RoachHook.Config["visual.removals"] && RoachHook.Config["visual.removals"][1])) && RoachHook.SilentAimbot || angles
    if(RoachHook.Config["misc.b_obs_proof"] && RoachHook.Config["misc.b_obs_proof.b_auto_hide"]) then
        anglee = (RoachHook.Config["misc.camera.b_thirdperson"] && RoachHook.PressedVars["misc.camera.b_thirdperson.key"]) && RoachHook.SilentAimbot || angles
    end

    return {
        origin = orig,
        drawviewer = RoachHook.Config["misc.camera.b_thirdperson"] && RoachHook.PressedVars["misc.camera.b_thirdperson.key"],
        angles = anglee,
        fov = (RoachHook.Config["misc.camera.b_force_fov"] && 90 || fov) + (RoachHook.Config["misc.camera.i_fov"] || 0)
    }
end)

RoachHook.Detour.hook.Add("Think", "Force3DSkybox", function()
    if(RoachHook.Config["misc.b_obs_proof"] && RoachHook.Config["misc.b_obs_proof.b_auto_hide"]) then return end
    if(!RoachHook.Config["visual.removals"]) then return end
    if(!RoachHook.Config["visual.removals"][2]) then return end
    
    local r_3dsky = GetConVar("r_3dsky")
    if(r_3dsky:GetInt() == 0) then RunConsoleCommand("r_3dsky", "1") end
end)
RoachHook.Detour.hook.Add("PreDrawSkyBox", "HideSkybox", function()
    if(RoachHook.Config["misc.b_obs_proof"] && RoachHook.Config["misc.b_obs_proof.b_auto_hide"]) then return end
    if(!RoachHook.Config["visual.removals"]) then return end
    if(!RoachHook.Config["visual.removals"][2]) then return end

    return true
end)

RoachHook.Detour.hook.Add("CalcViewModelView", "CustomViewmodel", function(wpn, vm, oPos, oAng, pos, ang)
    if(RoachHook.Config["misc.b_obs_proof"] && RoachHook.Config["misc.b_obs_proof.b_auto_hide"]) then return end

    if(RoachHook.Config["visual.removals"] && RoachHook.Config["visual.removals"][4] && RoachHook.Config["fakelag.b_fakeduck"] && RoachHook.PressedVars["fakelag.b_fakeduck.key"]) then
        pos.z = RoachHook.Detour.LocalPlayer():GetPos().z + RoachHook.Detour.LocalPlayer():GetViewOffset().z
    end

    if(!LocalPlayer():Alive()) then return end
    if(!RoachHook.Config["player.b_custom_viewmodel"]) then return end
    local pos, ang = pos, ang
    pos = pos + (ang:Forward() * RoachHook.Config["player.b_custom_viewmodel.y"])
    pos = pos + (ang:Right() * RoachHook.Config["player.b_custom_viewmodel.x"])
    pos = pos + (ang:Up() * RoachHook.Config["player.b_custom_viewmodel.z"])

    local ang = ang + Angle(0, 0, RoachHook.Config["player.b_custom_viewmodel.roll"])

    return pos, ang
end)