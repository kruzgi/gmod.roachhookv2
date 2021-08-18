local bForceFakelag = false
RoachHook.Features.Ragebot.Fakelag = function()
    if(RoachHook.Config["fakelag.b_enable"]) then
        local iWishTicks = RoachHook.Config["fakelag.i_mode.ticks"]
        local velocity = LocalPlayer():GetVelocity():Length()
        if(velocity < 5 && !RoachHook.Config["fakelag.b_always"] && !bForceFakelag) then iWishTicks = 1 end

        local movetype = LocalPlayer():GetMoveType()
        if(movetype == MOVETYPE_LADDER || movetype == MOVETYPE_NOCLIP || movetype == MOVETYPE_OBSERVER) then iWishTicks = 1 end

        if(RoachHook.Config["fakelag.b_fakeduck"] && RoachHook.PressedVars["fakelag.b_fakeduck.key"]) then
            bSendPacket = RoachHook.Modules.Big.GetChokedPackets() >= 14
            RoachHook.iWishTicks = 14
            return
        end
        
        local bFakeFlick = RoachHook.Config["antiaim.b_fake_flick"] && RoachHook.PressedVars["antiaim.b_fake_flick.key"]
        if(bFakeFlick) then
            bSendPacket = RoachHook.Modules.Big.GetChokedPackets() >= 1
            RoachHook.iWishTicks = 1
            return
        end

        local iMode = RoachHook.Config["fakelag.i_mode"]
        if(iMode == 1) then
            bSendPacket = RoachHook.Modules.Big.GetChokedPackets() >= iWishTicks
        elseif(iMode == 2) then
            bSendPacket = RoachHook.Modules.Big.GetChokedPackets() >= (engine.TickCount() % (iWishTicks + 2) <= 2 && 1 || iWishTicks)
        elseif(iMode == 3) then
            if(velocity < 200) then
                // keep ticks
            elseif(velocity < 300) then
                iWishTicks = iWishTicks * 0.8
            elseif(velocity < 500) then
                iWishTicks = iWishTicks * 0.5
            elseif(velocity < 700) then
                iWishTicks = iWishTicks * 0.3
            end

            local iWishTicks = math.Clamp(math.ceil(iWishTicks), 1, 14)
            
            bSendPacket = RoachHook.Modules.Big.GetChokedPackets() >= iWishTicks
        elseif(iMode == 4) then
            bSendPacket = RoachHook.Modules.Big.GetChokedPackets() >= math.random(1, iWishTicks)
        end

        RoachHook.iWishTicks = iWishTicks
    else
        bSendPacket = RoachHook.Modules.Big.GetChokedPackets() >= 1
    end
end
RoachHook.Features.Ragebot.FakeDuck = function(cmd)
    if(!RoachHook.Config["fakelag.b_enable"]) then return end
    if(!RoachHook.Config["fakelag.b_fakeduck"]) then return end
    if(!RoachHook.PressedVars["fakelag.b_fakeduck.key"]) then return end

    local iMode = RoachHook.Config["fakelag.b_fakeduck.i_mode"]
    if(iMode == 1) then
        if(RoachHook.Modules.Big.GetChokedPackets() >= 7) then
            cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_DUCK))
        else
            cmd:RemoveKey(IN_DUCK)
        end
    elseif(iMode == 2) then
        if(!bSendPacket) then
            cmd:RemoveKey(IN_DUCK)
        else
            cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_DUCK))
        end
    end
end

local function GetDistanceAtTargetsYaw()
    local flLowestDist = math.huge
    local flBestYaw = RoachHook.SilentAimbot.y

    local plrs = player.GetAll()
    for k=0, #plrs do
        local v = plrs[k]
        if(!v) then continue end
        if(!v:Alive() || v:IsDormant() || v == LocalPlayer()) then continue end
        
        if(RoachHook.Config["ragebot.b_team_check"] && v:Team() == LocalPlayer():Team()) then continue end
        if(RoachHook.Config["misc.b_ignore." .. RoachHook.Helpers.GetPlayerListID(v)]) then continue end

        local flDistance = LocalPlayer():GetPos():Distance(v:GetPos())
        if(flDistance < flLowestDist) then
            flLowestDist = flDistance

            flBestYaw = (v:GetPos() - LocalPlayer():GetPos()):Angle().y
        end
    end

    return flBestYaw
end
local function GetFOVAtTargetsYaw()
    local flLowestFOV = math.huge
    local flBestYaw = RoachHook.SilentAimbot.y

    local plrs = player.GetAll()
    for k=0, #plrs do
        local v = plrs[k]
        if(!v) then continue end
        if(!v:Alive() || v:IsDormant() || v == LocalPlayer()) then continue end
        
        if(RoachHook.Config["ragebot.b_team_check"] && v:Team() == LocalPlayer():Team()) then continue end
        if(RoachHook.Config["misc.b_ignore." .. RoachHook.Helpers.GetPlayerListID(v)]) then continue end
        
        local flAngle = (v:GetPos() - LocalPlayer():GetPos()):Angle()
        local flFOV = Vector(flAngle.x - RoachHook.SilentAimbot.x, flAngle.y - RoachHook.SilentAimbot.y, 0):Length2D()
        
        if(flFOV < flLowestFOV) then
            flLowestFOV = flFOV
            flBestYaw = flAngle.y
        end
    end

    return flBestYaw
end
local rhpens = {
    ["default"] = 7.6,
    ["concrete"] = 8.9,
    ["brick"] = 7.75
}
local function SimpleAutowall(p0, p1, plr)
    local myWeapon = plr:GetActiveWeapon()
    if(!myWeapon || !IsValid(myWeapon) || !myWeapon.IsScripted) then return false end
    if(!myWeapon:IsScripted()) then return false end

    local trc = {
        util.TraceLine({
            start = p0,
            endpos = p1,
            filter = plr,
            mask = MASK_SHOT,
        }),
        util.TraceLine({
            start = p1,
            endpos = p0,
            filter = RoachHook.Detour.LocalPlayer(),
            mask = MASK_SHOT,
        }),
    }

    local pen = rhpens[util.GetSurfacePropName(trc[1].SurfaceProps)] || 8

    return math.Round(trc[1].HitPos:Distance(trc[2].HitPos), 1) <= pen
end
local function WallDetection()
    local me = RoachHook.Detour.LocalPlayer()
    local eye = me:GetShootPos()
    local head = me:GetBonePosition(me:LookupBone("ValveBiped.Bip01_Head1"))
    eye.z = head.z

    local lowestFraction = 1
    local lowestFractionAngle = nil
    for i=0, 360, 360 / RoachHook.Config["antiaim.i_yaw_modifier.scans"] do
        local ang = Angle(0, i, 0)
        local trc = util.TraceLine({
            start = eye,
            endpos = eye + ang:Forward() * 24,
            mask = MASK_SHOT,
            filter = player.GetAll(),
        })

        if(trc.Fraction < lowestFraction) then
            lowestFraction = trc.Fraction
            lowestFractionAngle = ang.y
        end
    end

    return lowestFractionAngle
end
local function EdgeAA()

end

RoachHook.bFakeFlick_Timer = 0
local bDidSwitch = false
RoachHook.aaLBYTimer = 0
local LBYSide = false
RoachHook.LBYTime = 1.1
RoachHook.Features.Ragebot.AntiAim = function(cmd)
    if(!RoachHook.Config["antiaim.b_enable"]) then return end

    local badmovetypes = {
        [MOVETYPE_NOCLIP] = true,
        [MOVETYPE_LADDER] = true,
        [MOVETYPE_OBSERVER] = true,
    }
    if(badmovetypes[LocalPlayer():GetMoveType()]) then return end
    if(!LocalPlayer():Alive()) then
        cmd:SetViewAngles(RoachHook.SilentAimbot)
        return
    end
    if(cmd:KeyDown(IN_USE)) then
        cmd:SetViewAngles(RoachHook.SilentAimbot)
        return
    end
    if(cmd:KeyDown(IN_ATTACK) && RoachHook.Helpers.CanFire() && ((bDidSwitch && !bSendPacket) || LocalPlayer():GetActiveWeapon():GetClass() == "weapon_physgun")) then
        bDidSwitch = false

        cmd:SetViewAngles(RoachHook.SilentAimbot)
        return
    else
        bDidSwitch = true
        cmd:RemoveKey(IN_ATTACK)
    end

    local base_yaw = {
        RoachHook.SilentAimbot.y,
        GetDistanceAtTargetsYaw(),
        GetFOVAtTargetsYaw(),
        RoachHook.Config["antiaim.i_base_yaw.static_yaw"]
    }
    local pitch = {
        RoachHook.SilentAimbot.x,
        -89,
        -180,
        bSendPacket && -89 || 89,
        89,
        180,
        bSendPacket && 89 || -89,
        0,
        bSendPacket && 0 || -89,
        bSendPacket && 0 || 89,
        cmd:TickCount() % 2 == 0 && -89 || 89,
        cmd:TickCount() % 2 == 0 && -180 || 180,
        math.random(-89, 89),
        RoachHook.Config["antiaim.i_pitch.static_yaw"]
    }
    local yaw = {
        0,
        180,
        -90,
        90,
        math.random(-180, 180),
        (RoachHook.ServerTime || 0) * ((bSendPacket && RoachHook.Config["antiaim.i_fake_yaw.spin_speed"] || RoachHook.Config["antiaim.i_real_yaw.spin_speed"]) * 10),
        0,
        0,
        bSendPacket && RoachHook.Config["antiaim.i_fake_yaw.custom"] || RoachHook.Config["antiaim.i_real_yaw.custom"],
    }

    local iBaseYaw = RoachHook.Config["antiaim.i_base_yaw"]
    local iPitch = RoachHook.Config["antiaim.i_pitch"]
    local iYawReal = RoachHook.Config["antiaim.i_real_yaw"]
    local iYawFake = RoachHook.Config["antiaim.i_fake_yaw"]
    local iMod = RoachHook.Config["antiaim.i_yaw_modifier"]
    
    if(bSendPacket) then
        yaw[7] = yaw[iYawReal] + 90 + ((((RoachHook.ServerTime || 0) * RoachHook.Config["antiaim.i_fake_yaw.spin_speed"]) * 10) % 180)
        yaw[8] = yaw[iYawReal] + 90 + math.random(-90, 90)
    else
        yaw[7] = yaw[iYawFake] + 90 + ((((RoachHook.ServerTime || 0) * RoachHook.Config["antiaim.i_real_yaw.spin_speed"]) * 10) % 180)
        yaw[8] = yaw[iYawFake] + 90 + math.random(-90, 90)
    end

    local mod = nil
    if(iMod == 2) then
        mod = WallDetection()
    end
    local mod_add = yaw[iYawReal] - yaw[iYawFake]

    local bFakeFlick = RoachHook.Config["antiaim.b_fake_flick"] && RoachHook.PressedVars["antiaim.b_fake_flick.key"]
    if(bFakeFlick) then
        if(bSendPacket) then
            if(RoachHook.bFakeFlick_Timer <= RoachHook.ServerTime) then
                if(mod) then
                    cmd:SetViewAngles(Angle(
                        pitch[iPitch],
                        mod + mod_add,
                        0
                    ))
                else
                    cmd:SetViewAngles(Angle(
                        pitch[iPitch],
                        base_yaw[iBaseYaw] + yaw[iYawFake],
                        0
                    ))
                end
                RoachHook.AntiAim_WasLBY = true
                RoachHook.bFakeFlick_Timer = RoachHook.ServerTime + (RoachHook.Config["antiaim.b_fake_flick.fl_time"] || 1)
            else
                if(mod) then
                    cmd:SetViewAngles(Angle(
                        pitch[iPitch],
                        mod,
                        0
                    ))
                else
                    cmd:SetViewAngles(Angle(
                        pitch[iPitch],
                        base_yaw[iBaseYaw] + yaw[iYawReal],
                        0
                    ))
                end
            end
        else
            if(mod) then
                cmd:SetViewAngles(Angle(
                    pitch[iPitch],
                    mod,
                    0
                ))
            else
                cmd:SetViewAngles(Angle(
                    pitch[iPitch],
                    base_yaw[iBaseYaw] + yaw[iYawReal],
                    0
                ))
            end
            
            local lbytime = RoachHook.LBYTime
            if(LocalPlayer():GetVelocity():Length2D() > 5) then
                RoachHook.aaLBYTimer = CurTime() - lbytime
                lbytime = math.huge
            end
            
            if(RoachHook.aaLBYTimer + lbytime <= CurTime()) then
                cmd:SetViewAngles(Angle(
                    89,
                    cmd:GetViewAngles().y + (120 * (LBYSide && -1 || 1)),
                    0
                ))
                RoachHook.aaLBYTimer = CurTime()
                LBYSide = !LBYSide
                RoachHook.AntiAim_WasLBY = true
            end
        end
        
        return
    end

    if(bSendPacket) then
        if(mod) then
            cmd:SetViewAngles(Angle(
                pitch[iPitch],
                mod + mod_add,
                0
            ))
        else
            cmd:SetViewAngles(Angle(
                pitch[iPitch],
                base_yaw[iBaseYaw] + yaw[iYawFake],
                0
            ))
        end
    else        
        if(mod) then
            cmd:SetViewAngles(Angle(
                pitch[iPitch],
                mod,
                0
            ))
        else
            cmd:SetViewAngles(Angle(
                pitch[iPitch],
                base_yaw[iBaseYaw] + yaw[iYawReal],
                0
            ))
        end
        
        local lbytime = RoachHook.LBYTime
        if(LocalPlayer():GetVelocity():Length2D() > 5) then
            RoachHook.aaLBYTimer = CurTime() - lbytime
            lbytime = math.huge
        end

        if(RoachHook.aaLBYTimer + lbytime <= CurTime()) then
            cmd:SetViewAngles(Angle(
                89,
                cmd:GetViewAngles().y + (120 * (LBYSide && -1 || 1)),
                0
            ))
            RoachHook.aaLBYTimer = CurTime()
            LBYSide = !LBYSide

            RoachHook.AntiAim_WasLBY = true
        end
    end
end