RoachHook.Features.Misc.MoneyAimbot = function(cmd)
    if(!RoachHook.Config["misc.fun.b_money_aimbot"]) then return end

    local bAutoPickup = RoachHook.Config["misc.fun.b_money_aimbot.b_auto_pickup"]
    local iMaxFOV = RoachHook.Config["misc.fun.b_money_aimbot.i_fov"]
    local iMinimumMoney = RoachHook.Config["misc.fun.b_money_aimbot.i_min_dolars"]

    local moneysFound = ents.FindByClass("spawned_money")
    local eye = LocalPlayer():EyePos()
    local lowestFOV = math.huge
    local bestMoney = nil
    for i=0, #moneysFound do
        local money = moneysFound[i]
        if(!money) then continue end
        if(!money.Getamount) then continue end
        if(money:Getamount() < iMinimumMoney) then continue end

        local angle = (money:GetPos() - eye):Angle()
        local diff = RoachHook.SilentAimbot - angle
        local fov = math.NormalizeAngle(Vector(diff.x, diff.y, 0):Length2D())
        local dist = money:GetPos():Distance(eye)
        if(fov < lowestFOV && dist < 85) then
            lowestFOV = fov
            bestMoney = money
        end
    end
    
    if(bestMoney && lowestFOV <= iMaxFOV) then
        local angle = (bestMoney:GetPos() - eye):Angle()
        cmd:SetViewAngles(angle)
        if(!RoachHook.Config["misc.fun.b_money_aimbot.b_silent"]) then
            RoachHook.SilentAimbot = angle
        end

        if(bAutoPickup) then
            if(cmd:KeyDown(IN_USE)) then
                RunConsoleCommand("-use")
            else
                RunConsoleCommand("+use")
            end
        end
    end
end