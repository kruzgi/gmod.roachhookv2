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

RoachHook.Features.Legitbot.Aimbot = function(cmd)
    if(!RoachHook.Config["legitbot.b_enable"] || !RoachHook.PressedVars["legitbot.b_enable.key"]) then return end

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

        local closestBoneFOV = 180
        local closestBone = nil
        local closestBonePos = nil

        for k, bone in pairs(selectedHitboxes) do
            local bone = v:LookupBone(bone)
            if(!bone) then continue end
            
            local bonePos = v:GetBonePosition(bone)
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

    RoachHook.SilentAimbot = angLerp
    cmd:SetViewAngles(angLerp)
end