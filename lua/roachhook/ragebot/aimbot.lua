local Ragebot = {}
Ragebot.Targetting = {}
Ragebot.Targets = {}
local function optimizedTableHasValue(tbl, val)
    for i=0, #tbl do
        if(tbl[i] && tbl[i] == val) then return true end
    end
    return false
end
local hitbox = {
    ["head"] = {
        "ValveBiped.Bip01_Head1",
    },
    ["body"] = {
        "ValveBiped.Bip01_Pelvis",
        "ValveBiped.Bip01_Spine",
        "ValveBiped.Bip01_Spine1",
        "ValveBiped.Bip01_Spine2",
        "ValveBiped.Bip01_Spine3",
        "ValveBiped.Bip01_Spine4",
    },
    ["arms"] = {
        "ValveBiped.Bip01_L_Clavicle",
        "ValveBiped.Bip01_L_UpperArm",
        "ValveBiped.Bip01_L_Forearm",
        "ValveBiped.Bip01_R_Clavicle",
        "ValveBiped.Bip01_R_UpperArm",
        "ValveBiped.Bip01_R_Forearm",
    },
    ["hands"] = {
        "ValveBiped.Bip01_L_Hand",
        "ValveBiped.Bip01_R_Hand",
    },
    ["legs"] = {
        "ValveBiped.Bip01_L_Thigh",
        "ValveBiped.Bip01_L_Calf",
        "ValveBiped.Bip01_R_Thigh",
        "ValveBiped.Bip01_R_Calf",
    },
    ["feet"] = {
        "ValveBiped.Bip01_L_Foot",
        "ValveBiped.Bip01_R_Foot",
    },
}
function Ragebot:GetHitboxes()
    local hitboxes = RoachHook.Config["ragebot.hitboxes"]
    local selected_hitboxes = {}
    
    if(hitboxes[1]) then
        table.Add(selected_hitboxes, hitbox["head"])
    end
    if(hitboxes[2]) then
        table.Add(selected_hitboxes, hitbox["body"])
    end
    if(hitboxes[3]) then
        table.Add(selected_hitboxes, hitbox["arms"])
    end
    if(hitboxes[4]) then
        table.Add(selected_hitboxes, hitbox["hands"])
    end
    if(hitboxes[5]) then
        table.Add(selected_hitboxes, hitbox["legs"])
    end
    if(hitboxes[6]) then
        table.Add(selected_hitboxes, hitbox["feet"])
    end
    return selected_hitboxes
end
function Ragebot:GetMultipointHitboxes()
    if(!RoachHook.Config["ragebot.b_multipoints"]) then return {} end

    local multipoint_hitboxes = RoachHook.Config["ragebot.multipoint_hitboxes"]
    local selected_hitboxes = {}
    
    if(multipoint_hitboxes[1]) then
        table.Add(selected_hitboxes, hitbox["head"])
    end
    if(multipoint_hitboxes[2]) then
        table.Add(selected_hitboxes, hitbox["body"])
    end
    if(multipoint_hitboxes[3]) then
        table.Add(selected_hitboxes, hitbox["arms"])
    end
    if(multipoint_hitboxes[4]) then
        table.Add(selected_hitboxes, hitbox["hands"])
    end
    if(multipoint_hitboxes[5]) then
        table.Add(selected_hitboxes, hitbox["legs"])
    end
    if(multipoint_hitboxes[6]) then
        table.Add(selected_hitboxes, hitbox["feet"])
    end
    return selected_hitboxes
end
local rhpens = {
    ["default"] = 7.6,
    ["concrete"] = 8.9,
    ["brick"] = 7.75
}
local function SimpleAutowall(p0, p1, plr)
    local me = RoachHook.Detour.LocalPlayer()
    if(!me || !IsValid(me) || !me.GetActiveWeapon) then return false end
    local myWeapon = me:GetActiveWeapon()
    if(!myWeapon || !IsValid(myWeapon) || !myWeapon.IsScripted) then return false end
    if(!myWeapon:IsScripted()) then return false end

    local trc = {
        util.TraceLine({
            start = p0,
            endpos = p1,
            filter = me,
            mask = MASK_SHOT,
        }),
        util.TraceLine({
            start = p1,
            endpos = p0,
            filter = plr,
            mask = MASK_SHOT,
        }),
    }

    local pen = rhpens[util.GetSurfacePropName(trc[1].SurfaceProps)] || 8
    local pen = pen * ((RoachHook.Config["ragebot.b_autowall.i_strength"] || 100) / 100)

    return math.Round(trc[1].HitPos:Distance(trc[2].HitPos), 1) <= pen
end
function Ragebot:CanHit(plr)
    local hitboxes = Ragebot:GetHitboxes()
    local me = LocalPlayer()
    local eye = me:EyePos()
    local bAutowall = RoachHook.Config["ragebot.b_autowall"]

    for h=1,#hitboxes do
        local hitbox = hitboxes[h]
        if(!hitbox) then continue end

        local bone = plr:LookupBone(hitbox)
        if(!bone) then continue end

        local pos, angle = plr:GetBonePosition(bone)
        if(!pos || !angle) then continue end

        local trc = util.TraceLine({
            start = eye,
            endpos = pos,
            filter = me,
            mask = MASK_SHOT,
        })

        if(trc.Hit && IsValid(trc.Entity) && trc.Entity:GetClass() == "player") then return pos end

        if(bAutowall) then
            if(SimpleAutowall(eye, pos, plr)) then return pos end
        end
    end
    
    local hitboxes = Ragebot:GetMultipointHitboxes()
    local multipointScale = RoachHook.Config["ragebot.i_multipoint_scale"] / 100
    local multipointScans = RoachHook.Config["ragebot.i_multipoint_scans"]

    local multipointScaleStep = multipointScale / multipointScans

    for h=1,#hitboxes do
        local hitbox = hitboxes[h]
        if(!hitbox) then continue end

        local bone = plr:LookupBone(hitbox)
        if(!bone) then continue end

        local pos, angle = plr:GetBonePosition(bone)
        if(!pos || !angle) then continue end

        local hitbox = RoachHook.Helpers.BoneToHitbox(plr, bone)
        if(!hitbox) then continue end

        local hMins, hMaxs = plr:GetHitBoxBounds(hitbox, 0)
        if(!hMins || !hMaxs) then continue end

        local corners = RoachHook.Helpers.GetCorners(hMins, hMaxs)
        for c=1,#corners do
            for i=1, multipointScans do
                local corner = corners[c] * (multipointScaleStep * i)
                corner:Rotate(angle)
    
                local multipoint_pos = pos + corner
                
                local trc = util.TraceLine({
                    start = eye,
                    endpos = multipoint_pos,
                    filter = me,
                    mask = MASK_SHOT,
                })
    
                if(trc.Hit && IsValid(trc.Entity) && trc.Entity:GetClass() == "player") then return multipoint_pos end

                if(bAutowall) then
                    if(SimpleAutowall(eye, multipoint_pos, plr)) then return multipoint_pos end
                end
            end
        end
    end

    return false
end
function Ragebot.Targetting:Cycle()
    local iMaxFOV = RoachHook.Config["ragebot.i_fov"]
    local me = LocalPlayer()
    local myEye = me:EyePos()

    for i=0, #Ragebot.Targets do
        local plr = Ragebot.Targets[i]
        if(!plr) then continue end

        plr:SetupBones()
        local pos = Ragebot:CanHit(plr)
        if(pos) then
            local angle = (pos - myEye):Angle()
            local fov = math.abs(math.NormalizeAngle(Vector(angle.x - RoachHook.SilentAimbot.x, angle.y - RoachHook.SilentAimbot.y):Length2D()))
            
            if(fov <= iMaxFOV) then
                return pos, plr
            end
        end
    end
end
function Ragebot.Targetting:Distance()
    
end
function Ragebot.Targetting:Health()
    local iMaxFOV = RoachHook.Config["ragebot.i_fov"]
    local me = LocalPlayer()
    local myEye = me:EyePos()

    local lowestHP = math.huge
    local pPos = nil
    local pPlayer = nil

    for i=0, #Ragebot.Targets do
        local plr = Ragebot.Targets[i]
        if(!plr) then continue end

        plr:SetupBones()
        local pos = Ragebot:CanHit(plr)
        if(pos) then
            local angle = (pos - myEye):Angle()
            local fov = math.abs(math.NormalizeAngle(Vector(angle.x - RoachHook.SilentAimbot.x, angle.y - RoachHook.SilentAimbot.y):Length2D()))

            local hp = plr:Health()
            if(hp < lowestHP && fov <= iMaxFOV) then
                lowestHP = hp
                pPos = pos
                pPlayer = plr
            end
        end
    end
    
    return pPos, pPlayer
end
function Ragebot.Targetting:FOV()
    local iMaxFOV = RoachHook.Config["ragebot.i_fov"]
    local me = LocalPlayer()
    local myEye = me:EyePos()

    local lowestFOV = math.huge
    local pPos = nil
    local pPlayer = nil

    for i=0, #Ragebot.Targets do
        local plr = Ragebot.Targets[i]
        if(!plr) then continue end

        plr:SetupBones()
        local pos = Ragebot:CanHit(plr)
        if(pos) then
            local angle = (pos - myEye):Angle()
            local fov = math.abs(math.NormalizeAngle(Vector(angle.x - RoachHook.SilentAimbot.x, angle.y - RoachHook.SilentAimbot.y):Length2D()))

            if(fov < lowestFOV && fov <= iMaxFOV) then
                lowestFOV = fov
                pPos = pos
                pPlayer = plr
            end
        end
    end
    
    return pPos, pPlayer
end

function Ragebot:UpdateTargets()
    Ragebot.Targets = {}
    local players = player.GetAll()
    local me = LocalPlayer()
    local myTeam = me:Team()
    for i=0, #players do
        local plr = players[i]
        if(!plr || plr == me || !plr:Alive() || plr:IsDormant()) then continue end
        if(RoachHook.Config["ragebot.b_team_check"] && plr:Team() == myTeam) then continue end
        if(RoachHook.Config["misc.b_ignore." .. RoachHook.Helpers.GetPlayerListID(plr)]) then continue end

        Ragebot.Targets[#Ragebot.Targets + 1] = plr
    end
end
function Ragebot:GetTarget()
    local iTargettingMethod = RoachHook.Config["ragebot.targetting"]

    if(iTargettingMethod == 1) then
        return Ragebot.Targetting:Cycle()
    elseif(iTargettingMethod == 2) then
        return Ragebot.Targetting:Distance()
    elseif(iTargettingMethod == 3) then
        return Ragebot.Targetting:Health()
    elseif(iTargettingMethod == 4) then
        return Ragebot.Targetting:FOV()
    end
end

local function RagebotCanFire()
    local me = RoachHook.Detour.LocalPlayer()
    if(!me || !IsValid(me)) then return false end
    local myWeapon = me:GetActiveWeapon()
    if(!myWeapon || !IsValid(myWeapon)) then return false end
    if(myWeapon:Clip1() <= 0) then return false end
    return RoachHook.Helpers.CanFire()
end

local bDidSwitch = false
RoachHook.Features.Ragebot.Aimbot = function(cmd)
    if(!RoachHook.Config["ragebot.b_enable"]) then return end

    Ragebot:UpdateTargets()
    local pos, plr = Ragebot:GetTarget()
    if(!pos || !plr) then return end
    
    if(RagebotCanFire() && ((bDidSwitch && !bSendPacket) || LocalPlayer():GetActiveWeapon():GetClass() == "weapon_physgun")) then
        local angle = (pos - LocalPlayer():EyePos()):Angle()
        cmd:SetViewAngles(angle)
        cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_ATTACK))
        if(!RoachHook.Config["ragebot.b_silent"]) then
            RoachHook.SilentAimbot = angle
        end

        if(RoachHook.Config["misc.b_logs.logs"] && RoachHook.Config["misc.b_logs.logs"][2]) then
            RoachHook.Helpers.AddLog({
                {"[RoachHook " .. RoachHook.CheatVer .. "]", RoachHook.GetMenuTheme()},
                {" Fired shot at: ", Color(255, 255, 255)},
                {"<b>" .. plr:Name() .. "</b>", team.GetColor(plr:Team())},
            })
        end

        return
    else
        bDidSwitch = true
    end
end