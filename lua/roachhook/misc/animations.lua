local tauntTimer = CurTime()
local tauntSZID = {ACT_GMOD_GESTURE_BOW, ACT_GMOD_TAUNT_MUSCLE, ACT_GMOD_GESTURE_BECON, ACT_GMOD_TAUNT_LAUGH, ACT_GMOD_TAUNT_PERSISTENCE, ACT_GMOD_GESTURE_DISAGREE, ACT_GMOD_GESTURE_AGREE, ACT_GMOD_GESTURE_WAVE, ACT_GMOD_TAUNT_DANCE}
hook.Add("Tick", "ForceTaunt", function()
    if(cvar_gamemode:GetString() != "darkrp") then return end
    if(!RoachHook.Config["misc.fun.b_force_taunt"] || !RoachHook.Config["misc.fun.b_force_taunt.i_taunt"]) then return end
    local id = tauntSZID[RoachHook.Config["misc.fun.b_force_taunt.i_taunt"]]
    if(!id) then return end

    if(tauntTimer <= CurTime()) then
        RunConsoleCommand("_DarkRP_DoAnimation", tostring(id))
        
        tauntTimer = CurTime() + (RoachHook.Config["misc.fun.b_force_taunt.fl_refresh_time"] || 1.0)
    end
end)
local taunts = {
    ACT_GMOD_TAUNT_SALUTE,
    ACT_GMOD_TAUNT_PERSISTENCE,
    ACT_GMOD_TAUNT_MUSCLE,
    ACT_GMOD_TAUNT_LAUGH,
    ACT_GMOD_TAUNT_CHEER,
    ACT_GMOD_TAUNT_DANCE,
    ACT_GMOD_TAUNT_ROBOT,
    ACT_GMOD_DEATH,
    ACT_HL2MP_SWIM,
}
local bStartedTaunt = false
local bWasInNoclip = false
local iLastTaunt = nil
RoachHook.Detour.hook.Add("PrePlayerDraw", "robot_taunt", function(plr)
    if(plr != LocalPlayer()) then return end

    local iTaunt = RoachHook.Config["misc.b_taunt.i_selected"]
    if(iLastTaunt == nil) then iLastTaunt = iTaunt end

    if(RoachHook.Config["misc.b_taunt"]) then
        if(iLastTaunt != iTaunt) then
            LocalPlayer():AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
            bStartedTaunt = false
        end

        if(LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP) then
            bWasInNoclip = true
        end

        if(LocalPlayer():IsOnGround() && bWasInNoclip && LocalPlayer():GetMoveType() != MOVETYPE_NOCLIP) then
            bWasInNoclip = false
            bStartedTaunt = false
        end

        if(!bStartedTaunt) then
            LocalPlayer():AnimRestartGesture(GESTURE_SLOT_CUSTOM, taunts[iTaunt], false)
            iLastTaunt = iTaunt
        end
        
        bStartedTaunt = true
    else
        if(bStartedTaunt) then
            LocalPlayer():AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
        end

        bStartedTaunt = false
    end
end)
RoachHook.Detour.hook.Add("PostPlayerDraw", "AnimationFixPost", function()
    if(plr == RoachHook.Detour.LocalPlayer()) then
        
    end
end)
local lastTickCount = nil
RoachHook.Detour.hook.Add("PrePlayerDraw", "AnimationFix", function(plr)
    if(plr == RoachHook.Detour.LocalPlayer()) then
        if(RoachHook.DrawingFake) then return end

        if(RoachHook.Config["antiaim.b_enable"] && RoachHook.Config["ragebot.b_enable"]) then
            plr:InvalidateBoneCache()
    
                plr:SetPoseParameter("aim_yaw", 0)
                plr:SetPoseParameter("head_yaw", 0)
    
                plr:SetPoseParameter("aim_pitch", math.Clamp(RoachHook.AntiAimData.real.x, -89, 89))
                plr:SetPoseParameter("head_pitch", math.Clamp(RoachHook.AntiAimData.real.x, -89, 89))
    
                local vel = plr:GetVelocity():Length2D()
                local velScale = math.Clamp(vel / 60, 0, 1)
                local velocity = (plr:GetVelocity():Angle() - Angle(0, RoachHook.AntiAimData.real.y, 0)):Forward() * velScale
    
                plr:SetPoseParameter("move_x", velocity.x)
                plr:SetPoseParameter("move_y", -velocity.y)
    
                plr:SetRenderAngles(Angle(0, RoachHook.AntiAimData.real.y, 0))
                
            plr:SetupBones()
        end
    else
        if(!plr || !plr:Alive() || plr:IsDormant()) then return end
        if(RoachHook.Config["ragebot.b_team_check"] && plr:Team() == RoachHook.Detour.LocalPlayer()) then return end
        if(RoachHook.Config["misc.b_ignore." .. RoachHook.Helpers.GetPlayerListID(plr)]) then return end
        if(!RoachHook.Config["misc.b_resolve." .. RoachHook.Helpers.GetPlayerListID(plr)]) then return end
        
        local resolver_pitches = {
            nil,
            -89,
            0,
            89,
        }
        local resolver_yaws = {
            nil,
            -90,
            90,
            180,
            0,
            RoachHook.Modules.Big.RandomInt(-180, 180),
        }

        local iPitch = RoachHook.Config["misc.b_resolve.i_pitch." .. RoachHook.Helpers.GetPlayerListID(plr)]
        local iYaw = RoachHook.Config["misc.b_resolve.i_yaw." .. RoachHook.Helpers.GetPlayerListID(plr)]

        local plrNewPitch = iPitch > 1 && resolver_pitches[iPitch] || plr:EyeAngles().x
        local plrNewYaw = plr:EyeAngles().y + (iYaw > 1 && resolver_yaws[iYaw] || 0)

        plr:InvalidateBoneCache()

            if(iPitch > 1) then
                plr:SetPoseParameter("aim_pitch", plrNewPitch)
                plr:SetPoseParameter("head_pitch", plrNewPitch)
            end

            if(iYaw > 1) then
                plr:SetPoseParameter("aim_yaw", 0)
                plr:SetPoseParameter("head_yaw", 0)
                
                local vel = plr:GetVelocity():Length2D()
                local velScale = math.Clamp(vel / 60, 0, 1)
                local velocity = (plr:GetVelocity():Angle() - Angle(0, plrNewYaw, 0)):Forward() * velScale
    
                plr:SetPoseParameter("move_x", velocity.x)
                plr:SetPoseParameter("move_y", -velocity.y)
    
                plr:SetRenderAngles(Angle(0, plrNewYaw, 0))
            end
            
        plr:SetupBones()
    end
end)