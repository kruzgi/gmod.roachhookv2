local timeHoldingSpaceOnGround = 0
RoachHook.Features.Misc.Bunnyhop = function(cmd)
    if(!RoachHook.Config["misc.b_bhop"]) then return end
    if(RoachHook.ActiveItem && RoachHook.ActiveItem._type == "RoachHook.Textbox") then return end

    local badmovetypes = {
        [MOVETYPE_NOCLIP] = true,
        [MOVETYPE_LADDER] = true,
        [MOVETYPE_OBSERVER] = true,
    }
    if(badmovetypes[LocalPlayer():GetMoveType()]) then return end
    if(!LocalPlayer():Alive()) then return end
    if(LocalPlayer():IsOnGround()) then
        if(timeHoldingSpaceOnGround > 1) then
            timeHoldingSpaceOnGround = 0
            cmd:RemoveKey(IN_JUMP)
        end

        if(cmd:KeyDown(IN_JUMP)) then
            timeHoldingSpaceOnGround = timeHoldingSpaceOnGround + 1
        end

        return
    end

    local in_water = LocalPlayer():WaterLevel() >= 2
    if(in_water) then return end

    cmd:RemoveKey(IN_JUMP)
end
local function AutostraferLegit(cmd)
    if(!input.IsKeyDown(input.GetKeyCode(input.LookupBinding("+jump", true)))) then return end

    cmd:SetForwardMove(0)

    if(cmd:GetMouseX() > 0) then
        cmd:SetSideMove(10000)
    elseif(cmd:GetMouseX() < 0) then
        cmd:SetSideMove(-10000)
    else
        cmd:SetSideMove(0)
    end
end
local old_yaw = 0.0
local function AutostraferDirectional(cmd)
    if(!input.IsKeyDown(input.GetKeyCode(input.LookupBinding("+jump", true)))) then return end

        local get_velocity_degree = function(velocity)
            local tmp = math.deg(math.atan(30.0 / velocity))
                
            if (tmp > 90.0) then
                return 90.0
            elseif (tmp < 0.0) then
                return 0.0
            else
                return tmp
            end
        end

        local M_RADPI = 57.295779513082
        local side_speed = 10000
        local velocity = LocalPlayer():GetVelocity()
        velocity.z = 0.0

        local forwardmove = cmd:GetForwardMove()
        local sidemove = cmd:GetSideMove()

        if (!forwardmove || !sidemove) then
            return
        end

        local flip = cmd:TickCount() % 2 == 0

        local turn_direction_modifier = flip && 1.0 || -1.0
        local viewangles = Angle(RoachHook.SilentAimbot.x, RoachHook.SilentAimbot.y, RoachHook.SilentAimbot.z)

        if (forwardmove || sidemove) then
            cmd:SetForwardMove(0)
            cmd:SetSideMove(0)

            local turn_angle = math.atan2(-sidemove, forwardmove)
            viewangles.y = viewangles.y + (turn_angle * M_RADPI)
        elseif (forwardmove) then
            cmd:SetForwardMove(0)
        end

        local strafe_angle = math.deg(math.atan(15 / velocity:Length2D()))

        if (strafe_angle > 90) then
            strafe_angle = 90
        elseif (strafe_angle < 0) then
            strafe_angle = 0
        end

        local temp = Vector(0, viewangles.y - old_yaw, 0)
        temp.y = math.NormalizeAngle(temp.y)

        local yaw_delta = temp.y
        old_yaw = viewangles.y

        local abs_yaw_delta = math.abs(yaw_delta)

        if (abs_yaw_delta <= strafe_angle || abs_yaw_delta >= 30) then
            local velocity_angles = velocity:Angle()

            temp = Vector(0, viewangles.y - velocity_angles.y, 0)
            temp.y = math.NormalizeAngle(temp.y)

            local velocityangle_yawdelta = temp.y
            local velocity_degree = get_velocity_degree(velocity:Length2D() * 128)

            if (velocityangle_yawdelta <= velocity_degree || velocity:Length2D() <= 15) then
                if (-velocity_degree <= velocityangle_yawdelta || velocity:Length2D() <= 15) then
                    viewangles.y = viewangles.y + (strafe_angle * turn_direction_modifier)
                    cmd:SetSideMove(side_speed * turn_direction_modifier)
                else
                    viewangles.y = velocity_angles.y - velocity_degree
                    cmd:SetSideMove(side_speed)
                end
            else
                viewangles.y = velocity_angles.y + velocity_degree
                cmd:SetSideMove(-side_speed)
            end
        elseif (yaw_delta > 0) then
            cmd:SetSideMove(-side_speed)
        elseif (yaw_delta < 0) then
            cmd:SetSideMove(side_speed)
        end

        local move = Vector(cmd:GetForwardMove(), cmd:GetSideMove(), 0)
        local speed = move:Length()

        local angles_move = move:Angle()

        local normalized_x = math.modf(RoachHook.SilentAimbot.x + 180, 360) - 180
        local normalized_y = math.modf(RoachHook.SilentAimbot.y + 180, 360) - 180

        local yaw = math.rad(normalized_y - viewangles.y + angles_move.y)

        if (normalized_x >= 90 || normalized_x <= -90 || RoachHook.SilentAimbot.x >= 90 && RoachHook.SilentAimbot.x <= 200 || RoachHook.SilentAimbot.x <= -90 && RoachHook.SilentAimbot.x <= 200) then
            cmd:SetForwardMove(-math.cos(yaw) * speed)
        else
            cmd:SetForwardMove(math.cos(yaw) * speed)
        end

        cmd:SetSideMove(math.sin(yaw) * speed)
end
local function AutostraferRage(cmd)
    if(!input.IsKeyDown(input.GetKeyCode(input.LookupBinding("+jump", true)))) then return end

    cmd:SetForwardMove(0)

    if(LocalPlayer():IsOnGround()) then
        cmd:SetForwardMove(10000)
    else
        cmd:SetForwardMove(5850 / LocalPlayer():GetVelocity():Length2D())
        cmd:SetSideMove((cmd:CommandNumber() % 2 == 0) && -400 || 400)
    end
end
local bCircleStrafing = false
RoachHook.Features.Misc.Autostrafer = function(cmd)
    if(!RoachHook.Config["misc.b_autostrafer"] || bCircleStrafing) then return end

    local badmovetypes = {
        [MOVETYPE_NOCLIP] = true,
        [MOVETYPE_LADDER] = true,
        [MOVETYPE_OBSERVER] = true,
    }
    if(badmovetypes[LocalPlayer():GetMoveType()]) then return end
    if(!LocalPlayer():Alive()) then return end

    local autostraferMode = RoachHook.Config["misc.b_autostrafer.type"]

    if(autostraferMode == 1) then
        AutostraferLegit(cmd)
    elseif(autostraferMode == 2) then
        AutostraferDirectional(cmd)
    elseif(autostraferMode == 3) then
        AutostraferRage(cmd)
    end
end

local m_circle_yaw = 0
local m_previous_yaw = 0
local flip = false
RoachHook.Features.Misc.CircleStrafer = function(cmd)
    if(!RoachHook.Config["misc.b_c_strafe"] || !RoachHook.PressedVars["misc.b_c_strafe.key"]) then m_circle_yaw = 0 bCircleStrafing = false return end
    bCircleStrafing = true

	local get_angle_from_speed = function(speed)
		local ideal_angle = math.deg(math.atan2(30, speed))
		local ideal_angle = math.Clamp(ideal_angle, 0, 90)
		return ideal_angle
	end

	local get_velocity_step = function(velocity, speed, circle_yaw)
		local velocity_degree = math.deg(math.atan2(velocity.x, velocity.y))
		local step = 1

		local start = RoachHook.Detour.LocalPlayer():GetPos()
        local goal = start

		while (true) do
			goal.x = goal.x + (math.cos(math.rad(velocity_degree + circle_yaw)) * speed)
			goal.y = goal.y + (math.sin(math.rad(velocity_degree + circle_yaw)) * speed)
			goal = goal * FrameTime()

            local trace = util.TraceHull({
                start = start,
                endpos = goal,
                mins = Vector(-32, -32, 0),
                maxs = Vector(32, 32, 32),
                filter = RoachHook.Detour.LocalPlayer(),
                mask = MASK_PLAYERSOLID
            })

			if (trace.Fraction < 1 || trace.AllSolid || trace.StartSolid) then
				break
            end

			step = step - FrameTime()

			if (step == 0) then
				break
            end

			start = goal
			velocity_degree = velocity_degree + (velocity_degree + circle_yaw)
		end

		return step
	end

	local set_button_state = function()
        cmd:RemoveKey(IN_MOVELEFT)
        cmd:RemoveKey(IN_MOVERIGHT)
        cmd:RemoveKey(IN_FORWARD)
        cmd:RemoveKey(IN_BACK)

		if (cmd:GetSideMove() < 0) then
            cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_MOVELEFT))
		else
            cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_MOVERIGHT))
        end

		if (cmd:GetForwardMove() < 0) then
            cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_BACK))
		else
            cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_FORWARD))
        end
	end

	if (RoachHook.Detour.LocalPlayer():GetMoveType() != MOVETYPE_WALK || RoachHook.Detour.LocalPlayer():IsOnGround()) then
		return
    end

	local velocity = RoachHook.Detour.LocalPlayer():GetVelocity()
	velocity.z = 0

	local turn_direction_modifier = flip && 1 || -1
	flip = !flip

	if (cmd:GetForwardMove() > 0) then
        cmd:SetForwardMove(0)
    end

	local speed = velocity:Length2D()

	// circle strafe
    
    local ideal_speed_angle = get_angle_from_speed(speed)
    m_circle_yaw = math.NormalizeAngle(m_circle_yaw + ideal_speed_angle)
    local step = get_velocity_step(velocity, speed, ideal_speed_angle)

    if (step != 0) then
        m_circle_yaw = m_circle_yaw + (((FrameTime() * 128) * step) * step)
    end

    cmd:SetSideMove(-10000)
    set_button_state()

    local aaaaa = cmd:GetViewAngles().x > 89 || cmd:GetViewAngles().x < -89
    local speed = 10000
    local yaw = math.rad(math.NormalizeAngle(m_circle_yaw))
    cmd:SetForwardMove((math.cos(yaw) * speed) * ( aaaaa && -1 || 1 ))
    cmd:SetSideMove(math.sin(yaw) * speed)

    /*
        auto ideal_move_angle = RAD2DEG(std::atan2(15, speed))
        std::clamp(ideal_move_angle, 0, 90)

        auto yaw_delta = Math::NormalizeFloat(G::UserCmd->viewangles.y - m_previous_yaw)
        auto abs_yaw_delta = abs(yaw_delta)
        m_circle_yaw = m_previous_yaw = G::UserCmd->viewangles.y

        if (yaw_delta > 0)
            G::UserCmd->sidemove = -450

        else if (yaw_delta < 0)
            G::UserCmd->sidemove = 450

        if (abs_yaw_delta <= ideal_move_angle || abs_yaw_delta >= 30) {
            QAngle velocity_angles
            Math::VectorAngles(velocity, velocity_angles)

            auto velocity_angle_yaw_delta = Math::NormalizeFloat(G::UserCmd->viewangles.y - velocity_angles.y)
            auto velocity_degree = get_angle_from_speed(speed) * 2

            if (velocity_angle_yaw_delta <= velocity_degree || speed <= 15) {
                if (-(velocity_degree) <= velocity_angle_yaw_delta || speed <= 15) {
                    G::UserCmd->viewangles.y += (ideal_move_angle * turn_direction_modifier)
                    G::UserCmd->sidemove = 450 * turn_direction_modifier
                end

                else {
                    G::UserCmd->viewangles.y = velocity_angles.y - velocity_degree
                    G::UserCmd->sidemove = 450
                end
            end

            else {
                G::UserCmd->viewangles.y = velocity_angles.y + velocity_degree
                G::UserCmd->sidemove = -450
            end
        end

        set_button_state()
    */
end