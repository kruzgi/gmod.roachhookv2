local KnifeBase = "weapon_swcs_knife"
local KNIFE_RANGE_LONG = 48
local KNIFE_RANGE_SHORT = 32

local function GetKnifeBotCorners(min, max)
    min.x = min.x * 0.8
    min.y = min.y * 0.8
    max.x = max.x * 0.8
    max.y = max.y * 0.8
    
    return {
        Vector(min.x, min.y, min.z),
        Vector(min.x, max.y, min.z),
        Vector(max.x, max.y, min.z),
        Vector(max.x, min.y, min.z),
        Vector(max.x, max.y, max.z),
        Vector(min.x, max.y, max.z),
        Vector(min.x, min.y, max.z),
        Vector(max.x, min.y, max.z),
        
        -- Vector(min.x, min.y, (max.z - min.z) / 2),
        -- Vector(min.x, max.y, (max.z - min.z) / 2),
        -- Vector(max.x, max.y, (max.z - min.z) / 2),
        -- Vector(max.x, min.y, (max.z - min.z) / 2),
        -- Vector(max.x, max.y, (max.z - min.z) / 2),
        -- Vector(min.x, max.y, (max.z - min.z) / 2),
        -- Vector(min.x, min.y, (max.z - min.z) / 2),
        -- Vector(max.x, min.y, (max.z - min.z) / 2),
    }
end
local function SWEP_SwingOrStab(self, weaponMode, vForward)
	local owner = self:GetPlayerOwner()
	if not owner then return end

	local fRange = (weaponMode == Primary_Mode) and KNIFE_RANGE_LONG or KNIFE_RANGE_SHORT

	local vecSrc	= owner:GetShootPos()
	local vecEnd	= vecSrc + vForward * fRange

	local tr = util.TraceLine({
		start = vecSrc,
		endpos = vecEnd,
		mask = MASK_SOLID,
		collisiongroup = COLLISION_GROUP_NONE,
		filter = owner
	})
	if not tr.Hit then
		util.TraceHull({
			start = vecSrc,
			endpos = vecEnd,
			mask = MASK_SOLID,
			collisiongroup = COLLISION_GROUP_NONE,
			filter = owner,
			mins = vector_origin,
			maxs = vector_origin,
			output = tr
		})
	end

	local bDidHit = tr.Fraction < 1

	local bFirstSwing = (self:GetNextPrimaryFire() + 0.4) < CurTime()
	if bFirstSwing then
		// self:SetSwingLeft(true)
	end

	local fPrimDelay, fSecDelay

	if weaponMode == Secondary_Mode then
		fPrimDelay = bDidHit and 1.1 or 1
		fSecDelay = fPrimDelay
	else -- swing
		fPrimDelay = bDidHit and 0.5 or 0.4
		fSecDelay = 0.5
	end

	local bBackStab = false
    local fDamage = 0

	if bDidHit then
		local ent = tr.Entity

		if ent:IsValid() and (ent:IsPlayer() or ent:IsNPC()) then
			local vTargetForward = ent:GetAngles():Forward()

			local vecLOS = (ent:GetPos() - owner:GetPos())
			vecLOS.z = 0
			vecLOS:Normalize()

			vTargetForward.z = 0
			local flDot = vecLOS:Dot(vTargetForward)

			if flDot > .475 then
				bBackStab = true
			end
		end

		if weaponMode == Secondary_Mode then
			if bBackStab then
				fDamage = 180
			else
				fDamage = 65
			end
		else
			if bBackStab then
				fDamage = 90
			elseif bFirstSwing then
				fDamage = 40
			else
				fDamage = 25
			end
		end

		-- if SERVER then
		-- 	local info = DamageInfo()
		-- 	info:SetInflictor(owner)
		-- 	info:SetAttacker(owner)
		-- 	info:SetDamage(fDamage)
		-- 	info:SetDamageType(DMG_SLASH)
		-- 	info:SetDamagePosition(tr.HitPos)

		-- 	local force = vForward:GetNormal() * GetConVar("phys_pushscale"):GetFloat()
		-- 	info:SetDamageForce(force)

		-- 	if ent:IsPlayer() then
		-- 		ent:SetLastHitGroup(HITGROUP_GENERIC)
		-- 	end

		-- 	ent:TakeDamageInfo(info)
		-- end

		-- if ent:IsValid() or ent == game.GetWorld() then
		-- 	if ( ent:IsPlayer() or ent:IsNPC()  ) then
		-- 		-- when gmod fixes _G.EmitSound to allow lua sound scripts
		-- 		-- uncomment this
		-- 		--EmitSound((weaponMode == Secondary_Mode) and "Weapon_Knife_CSGO.Stab" or "Weapon_Knife_CSGO.Hit", tr.HitPos, self:EntIndex())
		-- 		self:EmitSound((weaponMode == Secondary_Mode) and "Weapon_Knife_CSGO.Stab" or "Weapon_Knife_CSGO.Hit")
		-- 	else
		-- 		--EmitSound("Weapon_Knife_CSGO.HitWall", tr.HitPos, self:EntIndex())
		-- 		self:EmitSound("Weapon_Knife_CSGO.HitWall")
		-- 	end
		-- end

		-- if SERVER then
		-- 	SuppressHostEvents(owner)
		-- end

		-- if SERVER or (CLIENT and IsFirstTimePredicted()) then
		-- 	if ent:IsPlayer() or ent:IsNPC() then
		-- 		util.ImpactTrace(tr, DMG_GENERIC)
		-- 	else
		-- 		util.ImpactTrace(tr, DMG_SLASH)
		-- 	end
		-- end
	else
        // return false, false, -1
		-- self:EmitSound("Weapon_Knife_CSGO.Slash")

		-- if ( weaponMode == Secondary_Mode ) then
		-- 	self:SetWeaponAnim( ACT_VM_MISSCENTER2 );
		-- else
		-- 	self:SetWeaponAnim( ACT_VM_MISSCENTER );
		-- end
	end

	//owner:SetAnimation(PLAYER_ATTACK1)

    return bDidHit, bBackStab, fDamage
end
local function CanShoot(mode)
    local me = RoachHook.Detour.LocalPlayer()
    if(!me || !IsValid(me)) then return false end
    local myWeapon = me:GetActiveWeapon()
    if(!myWeapon || !IsValid(myWeapon)) then return false end
    if(!myWeapon:IsScripted()) then return false end
    if(weapons.Get(myWeapon:GetClass()).Base != KnifeBase) then return false end
    
    if(mode == Primary_Mode) then        
        return myWeapon:GetNextPrimaryFire() <= RoachHook.ServerTime
    elseif(mode == Secondary_Mode) then
        return myWeapon:GetNextSecondaryFire() <= RoachHook.ServerTime
    else
        return false
    end
end

local lines = {}
RoachHook.Features.SWCS.KnifeBot = function(cmd)
    if(!RoachHook.Config["swcs.b_knife_bot"]) then return end

    local me = LocalPlayer()
    local weapon = me:GetActiveWeapon()
    local eye = me:GetShootPos()
    local targets = RoachHook.Config["swcs.b_knife_bot.target"]
    local mode = RoachHook.Config["swcs.b_knife_bot.i_mode"]
    local targetTeam = targets[1]
    local targetEnemy = targets[2]
    local targetNPC = targets[3]
    local myTeam = me:Team()

    if(mode == 1) then
        if(!CanShoot(Primary_Mode) || !CanShoot(Secondary_Mode)) then
            return
        end
    elseif(mode == 2) then
        if(!CanShoot(Secondary_Mode)) then
            return
        end
    end

    for k,v in ipairs(ents.GetAll()) do
        if(v:IsDormant()) then continue end
        if(!v:IsNPC() && !v:IsPlayer()) then continue end
        if(v:IsNPC() && !targetNPC) then continue end
        if(v:IsPlayer() && v:Team() == myTeam && !targetTeam) then continue end
        if(v:IsPlayer() && v:Team() != myTeam && !targetEnemy) then continue end
        if(v:GetPos():Distance(eye) > 128) then continue end // some sort of optimization

        if(v == me) then continue end

        local pos = v:GetPos()
        local corners = GetKnifeBotCorners(v:OBBMins(), v:OBBMaxs())
        local hp = v:Health()

        for k,p in ipairs(corners) do
            local vpos = pos + p
            local norm = vpos - eye
            norm:Normalize()

            local dist = eye:Distance(vpos)
            local stabType = "none"
            if(dist < KNIFE_RANGE_SHORT) then
                stabType = "right"
            elseif(dist < KNIFE_RANGE_LONG) then
                stabType = "left"
            end

            local angle = (vpos - eye):Angle()
            if(mode == 1) then      // default
                local canHit, canBackstab, fDamage = SWEP_SwingOrStab(weapon, Primary_Mode, norm)
                local canHit2, canBackstab2, fDamage2 = SWEP_SwingOrStab(weapon, Secondary_Mode, norm)

                local key = nil

                if(canHit && !canBackstab && stabType == "left" && fDamage >= hp) then
                    key = IN_ATTACK
                elseif(canHit2 && !canBackstab2 && stabType == "right" && fDamage2 >= hp) then
                    key = IN_ATTACK2
                elseif(canHit2 && canBackstab2 && stabType == "right" && fDamage2 >= hp) then
                    key = IN_ATTACK2
                elseif(canHit && canBackstab && stabType == "left" && fDamage >= hp) then
                    key = IN_ATTACK
                elseif(canHit && !canBackstab && stabType == "left" && fDamage < hp) then
                    key = IN_ATTACK
                end

                if(key) then
                    lines[#lines + 1] = {
                        eye, vpos, pos, corners
                    }
                    cmd:SetViewAngles(angle)
                    cmd:SetButtons(bit.bor(cmd:GetButtons(), key))
                    bSendPacket = true
                end
            elseif(mode == 2) then  // backstab
                local canHit, canBackstab, fDamage = SWEP_SwingOrStab(weapon, Primary_Mode, norm)
                local canHit2, canBackstab2, fDamage2 = SWEP_SwingOrStab(weapon, Secondary_Mode, norm)

                local key = nil

                if(canHit2 && canBackstab2 && stabType == "right" && fDamage2 >= hp) then
                    -- print("right")
                    key = IN_ATTACK2
                elseif(canHit && canBackstab && stabType == "left" && fDamage >= hp) then
                    -- print("left")
                    key = IN_ATTACK
                end
                -- print(key)

                if(key) then
                    cmd:SetViewAngles(angle)
                    cmd:SetButtons(bit.bor(cmd:GetButtons(), key))
                    bSendPacket = true
                end

                break;
            end
        end
    end
end

local function bb(b)
    local s = 255 / #lines
    return b * s, b * s, b * s
end
RoachHook.OverlayHook[#RoachHook.OverlayHook + 1] = function()
    for k,v in ipairs(lines) do
        local p0 = v[1]:ToScreen()
        local p1 = v[2]:ToScreen()
        if(!p0.visible || !p1.visible) then
            continue 
        end

        surface.SetDrawColor(bb(k))
        surface.DrawLine(p0.x, p0.y, p1.x, p1.y)

        for k,c in ipairs(v[4]) do
            local pos = (v[3] + c):ToScreen()
            if(!pos.visible) then
                continue 
            end

            surface.DrawRect(pos.x - 1, pos.y - 1, 2, 2)
        end
    end
end