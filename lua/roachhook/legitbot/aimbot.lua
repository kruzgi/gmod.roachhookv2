local bones = {
    ["head"] = {
        "ValveBiped.Bip01_Head1"
    },
    ["body"] = {
        "ValveBiped.Bip01_Pelvis",
        "ValveBiped.Bip01_Spine",
        "ValveBiped.Bip01_Spine1",
        "ValveBiped.Bip01_Spine2",
        "ValveBiped.Bip01_Spine3",
        "ValveBiped.Bip01_Spine4"
    },
    ["arms"] = {
        "ValveBiped.Bip01_L_UpperArm",
        "ValveBiped.Bip01_L_Forearm",
    },
    ["legs"] = {
        "ValveBiped.Bip01_L_Calf",
        "ValveBiped.Bip01_L_Foot"
    }
}

local function LegitbotCheckValidity(plr)
    local target = RoachHook.Config["legitbot.target"]
    if(!target) then return false end
    local me = RoachHook.Detour.LocalPlayer()
    if(target[1] && plr:Team() == me:Team()) then return false end
    if(target[2] && plr:Team() != me:Team()) then return false end
    if(target[3] && (plr:IsSuperAdmin() || plr:IsAdmin())) then return false end
    if(target[4] && plr:GetMoveType() == MOVETYPE_NOCLIP) then return false end
    if(target[5] && plr:HasGodMode()) then return false end
    if(target[6] && plr:IsFrozen()) then return false end
    if(target[7] && plr:IsBot()) then return false end
    if(RoachHook.Config["misc.b_ignore." .. RoachHook.Helpers.GetPlayerListID(v)]) then return false end

    return true
end
local function CheckVis(me, plr, pos)
    local trc = util.TraceLine({
        start = me:EyePos(),
        endpos = pos,
        filter = me,
        mask = MASK_SHOT,
    })

    if(trc.Hit && IsValid(trc.Entity) && trc.Entity:GetClass() == "player") then return true end
    return false
end
RoachHook.Features.Legitbot.Aimbot = function(cmd)
    if(!RoachHook.Config["legitbot.b_enable"] || !RoachHook.Config["legitbot.b_enable.key"]) then return end
    local boundToShoot = input.LookupKeyBinding(RoachHook.Config["legitbot.b_enable.key"].key) == "+attack"
    if(boundToShoot) then
        if(!cmd:KeyDown(IN_ATTACK)) then return end
    else
        if(!RoachHook.PressedVars["legitbot.b_enable.key"]) then return end
    end

    local hitboxes = RoachHook.Config["legitbot.hitbox"]
    local maxFOV = RoachHook.Config["legitbot.i_fov"]
    local minFOV = RoachHook.Config["legitbot.i_deadzone_fov"]

    local selectedHitboxes = {}

    if(hitboxes[1]) then
        for k,v in pairs(bones["head"]) do
            selectedHitboxes[#selectedHitboxes + 1] = v
        end
    end
    
    if(hitboxes[2]) then
        for k,v in pairs(bones["body"]) do
            selectedHitboxes[#selectedHitboxes + 1] = v
        end
    end
    
    if(hitboxes[3]) then
        for k,v in pairs(bones["arms"]) do
            selectedHitboxes[#selectedHitboxes + 1] = v
        end
    end

    if(hitboxes[4]) then
        for k,v in pairs(bones["legs"]) do
            selectedHitboxes[#selectedHitboxes + 1] = v
        end
    end

    local ViewAngles = cmd:GetViewAngles()
    local eyePos = RoachHook.Detour.LocalPlayer():EyePos()
    
    local flLowestFOV = 180
    local plr = nil
    local pos = nil
    for k,v in ipairs(player.GetAll()) do
        if(v:IsDormant() || v == RoachHook.Detour.LocalPlayer() || !v:Alive()) then continue end
        if(!LegitbotCheckValidity(v)) then continue end

        local closestBoneFOV = 180
        local closestBone = nil
        local closestBonePos = nil

        for k, bone in pairs(selectedHitboxes) do
            local bone = v:LookupBone(bone)
            if(!bone) then continue end
            
            local bonePos = v:GetBonePosition(bone)
            local vis = CheckVis(RoachHook.Detour.LocalPlayer(), v, bonePos)
            if(!vis) then continue end

            local angle = (bonePos - eyePos):Angle()
            local fov = Vector(math.NormalizeAngle(angle.x - ViewAngles.x), math.NormalizeAngle(angle.y - ViewAngles.y), 0):Length2D()

            if(fov < closestBoneFOV) then
                closestBoneFOV = fov
                closestBone = bone
                closestBonePos = bonePos
            end
        end

        if(closestBoneFOV < flLowestFOV) then
            flLowestFOV = closestBoneFOV
            plr = v
            pos = closestBonePos
        end
    end

    if(!pos || !pos || flLowestFOV > maxFOV || flLowestFOV <= minFOV) then return end

    local angle = (pos - eyePos):Angle()
    local angLerp = LerpAngle(1 - (RoachHook.Config["legitbot.i_smooth"] / 100), cmd:GetViewAngles(), angle)
    angLerp.x = math.Clamp(angLerp.x, -89, 89)
    angLerp.y = math.NormalizeAngle(angLerp.y)
    angLerp.z = 0

    if(RoachHook.Config["legitbot.b_mouse_sim"]) then
        local scr = pos:ToScreen()
        if(!scr.visible) then return end

        RoachHook.SilentAimbot = angLerp
        if(RoachHook.Config["legitbot.i_smooth"] <= 0) then
            input.SetCursorPos(scr.x, scr.y)
        else
            local x, y = Lerp(1 - (RoachHook.Config["legitbot.i_smooth"] / 100), ScrW() / 2, scr.x), Lerp(1 - (RoachHook.Config["legitbot.i_smooth"] / 100), ScrH() / 2, scr.y)
    
            input.SetCursorPos(x, y)
        end
    else
        RoachHook.SilentAimbot = angLerp
        cmd:SetViewAngles(angLerp)
    end
end