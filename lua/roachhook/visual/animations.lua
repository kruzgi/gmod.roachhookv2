local tauntTimer = CurTime()
local tauntSZID = {ACT_GMOD_GESTURE_BOW, ACT_GMOD_TAUNT_MUSCLE, ACT_GMOD_GESTURE_BECON, ACT_GMOD_TAUNT_LAUGH, ACT_GMOD_TAUNT_PERSISTENCE, ACT_GMOD_GESTURE_DISAGREE, ACT_GMOD_GESTURE_AGREE, ACT_GMOD_GESTURE_WAVE, ACT_GMOD_TAUNT_DANCE}

local cvar_gamemode = GetConVar("gamemode")
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
local function Taunter(plr)
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
end
local lastTickCount = nil

local function WallDetectionPlayer(plr)
    local eye = plr:GetShootPos()
    local head = plr:GetBonePosition(plr:LookupBone("ValveBiped.Bip01_Head1"))
    eye.z = head.z

    local lowestFraction = 1
    local lowestFractionAngle = nil
    for i=0, 360, 360 / 8 do
        local ang = Angle(0, i, 0)
        local trc = util.TraceLine({
            start = eye,
            endpos = eye + ang:Forward() * 24,
            mask = MASK_SHOT,
            collisiongroup = COLLISION_GROUP_DEBRIS,
        })

        if(trc.Fraction < lowestFraction) then
            lowestFraction = trc.Fraction
            lowestFractionAngle = ang.y
        end
    end

    return lowestFractionAngle
end

RoachHook.Features.Ragebot.BoneData = {}
local function RotatePlayer(plr, p, y)
    local origin = plr:GetNetworkOrigin()
    local rotationAngle = Angle(0, y - plr:EyeAngles().y, 0)

    // pointless, doesn't even change the hitboxes lol
    // plr:SetPoseParameter("aim_yaw", 0.0)
    // plr:SetPoseParameter("head_yaw", 0.0)
    // plr:InvalidateBoneCache()
    // plr:SetupBones()
    
    local numHitBoxSets = plr:GetHitboxSetCount()
    for hboxset=0, numHitBoxSets - 1 do
        local numHitBoxes = plr:GetHitBoxCount(hboxset)
            
        for hitbox=0, numHitBoxes - 1 do
            local bone = plr:GetHitBoxBone(hitbox, hboxset)
        
            local pos, angle = plr:GetBonePosition(bone)

            angle.y = angle.y + rotationAngle.y

            local offset = pos - origin
            offset:Rotate(rotationAngle)

            pos = origin + offset

            local mins, maxs = plr:GetHitBoxBounds(hitbox, hboxset)

            RoachHook.Features.Ragebot.BoneData[plr:EntIndex()][bone] = {
                pos = pos,
                angle = angle,
                mins = mins,
                maxs = maxs
            }
        end
    end

    -- PrintTable(RoachHook.Features.Ragebot.BoneData)
end

function RoachHook.Features.Ragebot.AnimFix(plr, velocity, maxSeqGroundSpeed)
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
        [1] = plr:EyeAngles().y,                            // Disabled
        [2] = plr:EyeAngles().y - 90,                       // Right
        [3] = plr:EyeAngles().y + 90,                       // Left
        [4] = plr:EyeAngles().y + 180,                      // Backwards
        [5] = 0,                                            // Forwards
        [6] = 0,                                            // WallDetection
        [7] = 0,                                            // Reverse WallDetection
        [8] = 0,                                            // AtTargets Backwards
        [9] = 0,                                            // AtTargets Forwards
        [10] = 0,                                           // AtTargets Sideways
        [11] = plr:EyeAngles().y + math.random(-180, 180),  // Random Yaw
        [12] = nil,                                         // Random Mode
    }

    local iPitch = RoachHook.Config["misc.b_resolve.i_pitch." .. RoachHook.Helpers.GetPlayerListID(plr)]
    local iYaw = RoachHook.Config["misc.b_resolve.i_yaw." .. RoachHook.Helpers.GetPlayerListID(plr)]

    if(iYaw == 6) then  // Wall Detection
        resolver_yaws[6] = WallDetectionPlayer(plr)
        if(resolver_yaws[6]) then
            debugoverlay.Line(plr:GetPos(), plr:GetPos() + Angle(0, resolver_yaws[6], 0):Forward() * 26, 1.0, color_white, true)
        end
    elseif(iYaw == 7) then  // Reverse WallDetection
        local wd = WallDetectionPlayer(plr)
        if(wd) then
            resolver_yaws[6] = math.NormalizeAngle(wd + 180)
        end
    elseif(iYaw == 12) then
        iYaw = math.random(2, 10)
    end

    local plrNewPitch = iPitch > 1 && resolver_pitches[iPitch] || plr:EyeAngles().x
    local plrNewYaw = resolver_yaws[iYaw] || plr:EyeAngles().y

    RotatePlayer(plr, plrNewPitch, plrNewYaw)
end

local function RunSandboxAnims(ply, velocity, maxseqgroundspeed)
    local len = velocity:Length()
	local movement = 1.0

	if ( len > 0.2 ) then
		movement = ( len / maxseqgroundspeed )
	end

	local rate = math.min( movement, 2 )

	-- if we're under water we want to constantly be swimming..
	if ( ply:WaterLevel() >= 2 ) then
		rate = math.max( rate, 0.5 )
	elseif ( !ply:IsOnGround() && len >= 1000 ) then
		rate = 0.1
	end

	ply:SetPlaybackRate( rate )

	-- We only need to do this clientside..
	if ( CLIENT ) then
		if ( ply:InVehicle() ) then
			--
			-- This is used for the 'rollercoaster' arms
			--
			local Vehicle = ply:GetVehicle()
			local Velocity = Vehicle:GetVelocity()
			local fwd = Vehicle:GetUp()
			local dp = fwd:Dot( Vector( 0, 0, 1 ) )

			ply:SetPoseParameter( "vertical_velocity", ( dp < 0 && dp || 0 ) + fwd:Dot( Velocity ) * 0.005 )

			-- Pass the vehicles steer param down to the player
			local steer = Vehicle:GetPoseParameter( "vehicle_steer" )
			steer = steer * 2 - 1 -- convert from 0..1 to -1..1
			if ( Vehicle:GetClass() == "prop_vehicle_prisoner_pod" ) then steer = 0 ply:SetPoseParameter( "aim_yaw", math.NormalizeAngle( ply:GetAimVector():Angle().y - Vehicle:GetAngles().y - 90 ) ) end
			ply:SetPoseParameter( "vehicle_steer", steer )

		end
		GAMEMODE:GrabEarAnimation( ply )
		GAMEMODE:MouthMoveAnimation( ply )
	end
end

function GAMEMODE:UpdateAnimation(plr, velocity, maxSeqGroundSpeed)
    local hResult = self.BaseClass.UpdateAnimation(self, plr, velocity, maxSeqGroundSpeed)

    if(plr == LocalPlayer()) then
        Taunter(plr)
        return hResult
    end
    
    RoachHook.Features.Ragebot.BoneData[plr:EntIndex()] = {}
    RoachHook.Features.Ragebot.AnimFix(plr, velocity, maxSeqGroundSpeed)
    RunSandboxAnims(plr, velocity, maxSeqGroundSpeed)
    return hResult;
end