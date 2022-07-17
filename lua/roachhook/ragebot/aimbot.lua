local Ragebot = {}
Ragebot.Targetting = {}
Ragebot.Targets = {}
// ???
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
        "ValveBiped.Bip01_Spine3",  -- some of the models doesn't have these
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
        "ValveBiped.Bip01_L_Toe0",  -- some of the models doesn't have these
        "ValveBiped.Bip01_R_Toe0",
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
    ["brick"] = 7.75,
    ["wood_panel"] = 35,
    ["wood_solid"] = 15,
    ["plaster"] = 10,
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

    //print(util.GetSurfacePropName(trc[1].SurfaceProps), math.Round(trc[1].HitPos:Distance(trc[2].HitPos), 1))
    local pen = rhpens[util.GetSurfacePropName(trc[1].SurfaceProps)] || 8
    local pen = pen * ((RoachHook.Config["ragebot.b_autowall.i_strength"] || 100) / 100)

    return math.Round(trc[1].HitPos:Distance(trc[2].HitPos), 1) <= pen
end
local function SWCSAutowall(p0, p1, plr)
    if(!RoachHook.Config["swcs.b_aw"]) then return true end
    local weapon = LocalPlayer():GetActiveWeapon()

    // maybe one day lmao
    return false
end

local function GetBoneData(plr, bone)
    if(isstring(bone)) then
        bone = plr:LookupBone(bone)
    end
    if(!bone) then
        return nil
    end

    if(RoachHook.Features.Ragebot.BoneData && RoachHook.Features.Ragebot.BoneData[plr:EntIndex()] && RoachHook.Features.Ragebot.BoneData[plr:EntIndex()][bone]) then
        return RoachHook.Features.Ragebot.BoneData[plr:EntIndex()][bone]
    end

    -- print("Couldn't get bone data [" .. bone .. "], generating new input...")
    
    local mins, maxs = Vector(), Vector()

    local hitbox = RoachHook.Helpers.BoneToHitbox(plr, bone)
    if(hitbox) then
        mins, maxs = plr:GetHitBoxBounds(hitbox, 0)
    end

    local pos, angle = plr:GetBonePosition(bone)

    return {
        pos = pos,
        angle = angle,
        mins = mins,
        maxs = maxs
    }
end

function Ragebot:CanHit(plr)
    local hitboxes = Ragebot:GetHitboxes()
    local me = LocalPlayer()
    local eye = me:EyePos()
    local bAutowall = RoachHook.Config["ragebot.b_autowall"]
    local weapon = LocalPlayer():GetActiveWeapon()

    for h=1,#hitboxes do
        local hitbox = hitboxes[h]
        if(!hitbox) then continue end

        -- local bone = plr:LookupBone(hitbox)
        -- if(!bone) then continue end

        -- local pos, angle = plr:GetBonePosition(bone)
        -- if(!pos || !angle) then continue end

        local boneData = GetBoneData(plr, hitbox)
        if(!boneData) then
            -- print("[hitbox] error occured while trying to get bone data of: " .. tostring(hitbox))
            continue
        end

        local trc = util.TraceLine({
            start = eye,
            endpos = boneData.pos,
            filter = me,
            mask = MASK_SHOT,
        })

        if((trc.Hit && IsValid(trc.Entity) && trc.Entity:GetClass() == "player") || trc.Fraction >= 0.999) then return boneData.pos end

        if(bAutowall) then
            if(RoachHook.Helpers.IsSWCS(weapon) && SWCSAutowall(eye, boneData.pos, plr)) then return boneData.pos end
            if(SimpleAutowall(eye, boneData.pos, plr)) then return boneData.pos end
        end
    end
    
    local hitboxes = Ragebot:GetMultipointHitboxes()
    local multipointScale = math.Clamp(RoachHook.Config["ragebot.i_multipoint_scale"] / 100, 0.1, 1.0)
    local multipointScans = RoachHook.Config["ragebot.i_multipoint_scans"]

    local multipointScaleStep = multipointScale / multipointScans

    for h=1,#hitboxes do
        local hitbox = hitboxes[h]
        if(!hitbox) then continue end

        -- local bone = plr:LookupBone(hitbox)
        -- if(!bone) then continue end

        -- local pos, angle = plr:GetBonePosition(bone)
        -- if(!pos || !angle) then continue end

        -- local hitbox = RoachHook.Helpers.BoneToHitbox(plr, bone)
        -- if(!hitbox) then continue end

        -- local hMins, hMaxs = plr:GetHitBoxBounds(hitbox, 0)
        -- if(!hMins || !hMaxs) then continue end

        local boneData = GetBoneData(plr, hitbox)
        if(!boneData) then
            -- print("[multipoint] error occured while trying to get bone data of: " .. tostring(hitbox))
            continue
        end

        local lowestLen = 128
        local bestPos = nil
        for x=boneData.mins.x * multipointScale, boneData.maxs.x * multipointScale, ((boneData.maxs.x - boneData.mins.x) / multipointScans) do
            for y=boneData.mins.y * multipointScale, boneData.maxs.y * multipointScale, ((boneData.maxs.y - boneData.mins.y) / multipointScans) do
                for z=boneData.mins.z * multipointScale, boneData.maxs.z * multipointScale, ((boneData.maxs.z - boneData.mins.z) / multipointScans) do
                    local pointPos = Vector(x, y, z)
                    pointPos:Rotate(boneData.angle)
                    local pointLen = pointPos:Length()
                    if(pointLen >= lowestLen) then
                        continue
                    end
                    
                    local multipoint_pos = boneData.pos + pointPos                    
                    local trc = util.TraceLine({
                        start = eye,
                        endpos = multipoint_pos,
                        filter = me,
                        mask = MASK_SHOT,
                    })
        
                    if((trc.Hit && IsValid(trc.Entity) && trc.Entity:GetClass() == "player") || trc.Fraction >= 0.999) then
                        lowestLen = pointLen
                        bestPos = multipoint_pos
                        continue
                    end

                    if(bAutowall) then
                        if(SimpleAutowall(eye, multipoint_pos, plr)) then
                            lowestLen = pointLen
                            bestPos = multipoint_pos
                        end
                    end
                end
            end
        end
        return bestPos

        -- local corners = RoachHook.Helpers.GetCorners(hMins, hMaxs)
        -- for c=1,#corners do
        --     for i=1, multipointScans do
        --         local corner = corners[c] * (multipointScaleStep * i)
        --         corner:Rotate(angle)
    
        --         local multipoint_pos = pos + corner
                
        --         local trc = util.TraceLine({
        --             start = eye,
        --             endpos = multipoint_pos,
        --             filter = me,
        --             mask = MASK_SHOT,
        --         })
    
        --         if(trc.Hit && IsValid(trc.Entity) && trc.Entity:GetClass() == "player") then return multipoint_pos end

        --         if(bAutowall) then
        --             if(SimpleAutowall(eye, multipoint_pos, plr)) then return multipoint_pos end
        --         end
        --     end
        -- end
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

        -- RoachHook.Features.Ragebot.AnimFix(plr)
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

        -- plr:SetupBones()
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

        -- plr:SetupBones()
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

    -- if(iTargettingMethod == 1) then
        return Ragebot.Targetting:Cycle()
    -- elseif(iTargettingMethod == 2) then
    --     return Ragebot.Targetting:Distance()
    -- elseif(iTargettingMethod == 3) then
    --     return Ragebot.Targetting:Health()
    -- elseif(iTargettingMethod == 4) then
    --     return Ragebot.Targetting:FOV()
    -- end
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
local function GetLerpTime()
	local Interp = GetConVar("cl_interp"):GetFloat();
	local UpdateRate = GetConVar("cl_updaterate"):GetFloat();
	local InterpRatio = GetConVar("cl_interp_ratio"):GetInt();
	local MaxUpdateRate = GetConVar("sv_maxupdaterate"):GetInt();
	local MinUpdateRate = GetConVar("sv_minupdaterate"):GetInt();
	local ClientMinInterpRatio = GetConVar("sv_client_min_interp_ratio"):GetFloat();
	local ClientMaxInterpRatio = GetConVar("sv_client_max_interp_ratio"):GetFloat();
 
	local ClampInterpRatio = math.Clamp(InterpRatio, ClientMinInterpRatio, ClientMaxInterpRatio);
	local ClampUpdateRate = math.Clamp(UpdateRate, MinUpdateRate, MaxUpdateRate);
 
	local lerp = ClampInterpRatio / ClampUpdateRate;
 
	if (lerp <= Interp) then
        lerp = Interp;
    end
 
	return lerp;
end
local function GetPredictedVector(plr)
    local ticksDifference = RoachHook.Helpers.TICKS_TO_TIME(GetLerpTime())
    return Vector() //plr:GetVelocity() * ticksDifference
end
local weapon_recoil_view_punch_extra = GetConVar("weapon_recoil_view_punch_extra")
local function SWCSGetRecoil(self)
    return self:GetAimPunchAngle() // lol
    -- local owner = self:GetPlayerOwner()
    -- if not owner then return end
    -- local iMode = self:GetWeaponMode()

    -- local iIndex = math.floor(self:GetRecoilIndex())
    -- local fAngle, fMagnitude = self:GetRecoilOffset(iMode, iIndex)

    -- local angleVel = Angle()
    -- angleVel.y = -math.sin(math.rad(fAngle)) * fMagnitude
    -- angleVel.p = -math.cos(math.rad(fAngle)) * fMagnitude
    -- angleVel = angleVel + self:GetAimPunchAngleVel()
    -- -- return angleVel

    -- local viewPunch = self:GetViewPunchAngle()
    -- local fViewPunchMagnitude = fMagnitude * weapon_recoil_view_punch_extra:GetFloat()
    -- viewPunch.y = viewPunch.y - math.sin(math.rad(fAngle)) * fViewPunchMagnitude
    -- viewPunch.p = viewPunch.p - math.cos(math.rad(fAngle)) * fViewPunchMagnitude
    -- viewPunch:Normalize()

    -- return angleVel + viewPunch
end
local function ClampMovementSpeed(cmd, speed)
	local final_speed = speed;

	-- g_cl.m_cmd->m_buttons |= IN_SPEED;

	local squirt = math.sqrt((cmd:GetForwardMove() * cmd:GetForwardMove()) + (cmd:GetSideMove() * cmd:GetSideMove()));

	if (squirt > speed) then
		local squirt2 = math.sqrt((cmd:GetForwardMove() * cmd:GetForwardMove()) + (cmd:GetSideMove() * cmd:GetSideMove()));

		local cock1 = cmd:GetForwardMove() / squirt2;
		local cock2 = cmd:GetSideMove() / squirt2;

		local Velocity = LocalPlayer():GetVelocity():Length2D();

		if (final_speed + 1.0 <= Velocity) then
			cmd:SetForwardMove(0)
			cmd:SetSideMove(0)
		else
			cmd:SetForwardMove(cock1 * final_speed)
			cmd:SetSideMove(cock2 * final_speed)
        end
    end
end
local function SWCSCanShootRevoler()
    local weapon = LocalPlayer():GetActiveWeapon()
    if(!weapon) then
        return false
    end

    if(weapon:GetClass() != "weapon_swcs_revolver") then
        return true
    end

    return weapon:GetPostponeFireReadyTime() <= CurTime()
end
local function SWCSAutoRevolver(cmd)
    local weapon = LocalPlayer():GetActiveWeapon()
    if(!weapon) then
        return
    end

    if(weapon:GetClass() != "weapon_swcs_revolver") then
        return
    end

    if(weapon:Clip1() <= 0) then
        return
    end

    local m_flPostponeFireReadyTime = weapon:GetPostponeFireReadyTime()
    local inf = math.huge
    if(m_flPostponeFireReadyTime >= inf) then
        cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_ATTACK))
    elseif(m_flPostponeFireReadyTime <= CurTime()) then
        cmd:RemoveKey(IN_ATTACK)
        cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_ATTACK2))
    else
        cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_ATTACK2))
    end
end

local function GenerateShotMatrix(plr, pointHit)
    local hitboxData = {}
    for _type, hitboxes in pairs(hitbox) do
        for id, hitboxName in ipairs(hitboxes) do
            local bone = plr:LookupBone(hitboxName)
            if(!bone) then continue end

            hitboxData[#hitboxData + 1] = GetBoneData(plr, bone)
        end
    end

    
    RoachHook.ShotMatrixes[#RoachHook.ShotMatrixes + 1] = {
        start = LocalPlayer():GetShootPos(),
        hit = pointHit,
        hitbox = hitboxData,
        color = Color(RoachHook.Config["ragebot.b_shot_matrix.color"].r, RoachHook.Config["ragebot.b_shot_matrix.color"].g, RoachHook.Config["ragebot.b_shot_matrix.color"].b, RoachHook.Config["ragebot.b_shot_matrix.color"].a),
        timeLeft = RoachHook.Config["ragebot.b_shot_matrix.fl_time"],
    }
end

local function SWCSHitChance(angles, ent, chance)
    local weapon = LocalPlayer():GetActiveWeapon();

	if (!weapon) then
		return false;
    end

	local forward, right, up = angles:Forward(), angles:Right(), angles:Up();
	local src = LocalPlayer():EyePos();

	local cHits = 0;
	local cNeededHits = math.floor(256.0 * (chance / 100.0));

	weapon:UpdateAccuracyPenalty();
	local weap_spread = weapon:GetSpread();
	local weap_inaccuracy = weapon:GetInaccuracy();

	for i=0, 255 do
		local a = g_ursRandom:RandomFloat(0.0, 1.0);
		local b = g_ursRandom:RandomFloat(0.0, 2.0 * math.pi);
		local c = g_ursRandom:RandomFloat(0.0, 1.0);
		local d = g_ursRandom:RandomFloat(0.0, 2.0 * math.pi);

		local inaccuracy = a * weap_inaccuracy;
		local spread = c * weap_spread;

		if (weapon:GetClass() == "weapon_swcs_revolver") then
			a = 1.0 - c * c;
        end

		local spreadView = Vector((math.cos(b) * inaccuracy) + (math.cos(d) * spread), (math.sin(b) * inaccuracy) + (math.sin(d) * spread), 0), direction;

        local direction = Vector()
		direction.x = forward.x + (spreadView.x * right.x) + (spreadView.y * up.x);
		direction.y = forward.y + (spreadView.x * right.y) + (spreadView.y * up.y);
		direction.z = forward.z + (spreadView.x * right.z) + (spreadView.y * up.z);
		direction:Normalize();

		local viewAnglesSpread = direction:Angle();
		-- Math::VectorAngles(direction, up, viewAnglesSpread);
		-- Math::ClampAngles(viewAnglesSpread);

		local viewForward = viewAnglesSpread:Forward();
		viewForward:Normalize();

		viewForward = src + (viewForward * weapon:GetRange());

        local tr = util.TraceLine({
            start = src,
            endpos = viewForward,
            mask = MASK_SHOT,
            collisiongroup = COLLISION_GROUP_PLAYER,
            ignoreworld = true,
            filter = LocalPlayer()
        })

		if (tr.Entity == ent) then
			cHits = cHits + 1;
        end

        -- debugoverlay.Line(tr.StartPos, tr.HitPos, engine.TickInterval() * 2.0, color_white, true)

		if (math.floor(((cHits) / 256.0) * 100.0) >= chance) then
			return true;
        end

		if ((256 - i + cHits) < cNeededHits) then
			return false;
        end
    end
	return false;
end

RoachHook.Features.Ragebot.Aimbot = function(cmd)
    if(!RoachHook.Config["ragebot.b_enable"]) then return end

    SWCSAutoRevolver(cmd)
    Ragebot:UpdateTargets()
    local pos, plr = Ragebot:GetTarget()
    if(!pos || !plr) then return end
    
    if(RagebotCanFire() && bDidSwitch && !bSendPacket) then
        local angle = ((pos + GetPredictedVector(plr)) - LocalPlayer():EyePos()):Angle()
        local weapon = LocalPlayer():GetActiveWeapon()
        if(RoachHook.Helpers.IsSWCS(weapon)) then
            if(RoachHook.Config["swcs.b_no_recoil"]) then
                local recoil = SWCSGetRecoil(weapon)
                if(recoil) then
                    angle = angle - recoil
                end
            end

            if(!SWCSCanShootRevoler(cmd)) then
                return
            end

            if(!SWCSHitChance(angle, plr, RoachHook.Config["swcs.i_hc"])) then
                return
            end
        end
        
        cmd:SetViewAngles(angle)
        cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_ATTACK))
        GenerateShotMatrix(plr, pos)
        -- debugoverlay.Cross(pos, 8, engine.TickInterval() * 2.0, color_white, true)
        if(!RoachHook.Config["ragebot.b_silent"]) then
            RoachHook.SilentAimbot = angle
        end


        -- if(RoachHook.Config["misc.b_logs.logs"] && RoachHook.Config["misc.b_logs.logs"][2]) then
        --     RoachHook.Helpers.AddLog({
        --         {"[RoachHook " .. RoachHook.CheatVer .. "]", RoachHook.GetMenuTheme()},
        --         {" Fired shot at: ", Color(255, 255, 255)},
        --         {"<b>" .. plr:Name() .. "</b>", team.GetColor(plr:Team())},
        --     })
        -- end

        return
    else
        bDidSwitch = true
    end
end