RoachHook.OverlayHook[#RoachHook.OverlayHook + 1] = function()
    if(!RoachHook.Config["visual.b_oof_arrows"]) then return end

    local me = LocalPlayer()
    local myTeam = me:Team()
    local eye = me:EyePos()

    local clr0, dormClr = Color(RoachHook.Config["visual.b_oof_arrows.color"].r, RoachHook.Config["visual.b_oof_arrows.color"].g, RoachHook.Config["visual.b_oof_arrows.color"].b, RoachHook.Config["visual.b_oof_arrows.color"].a / 2), Color(240, 240, 240, 128)
    local clr1 = RoachHook.Config["visual.b_oof_arrows.color"], Color(240, 240, 240, 128)
    
    local xScale, yScale = ScrW() / 250, ScrH() / 250
    local xScale, yScale = xScale * 100, yScale * 100

    for k,plr in ipairs(player.GetAll()) do
        if(!plr || plr == me || !plr:Alive()) then continue end
        if(RoachHook.Config["ragebot.b_team_check"] && plr:Team() == myTeam) then continue end
        if(RoachHook.Config["misc.b_ignore." .. RoachHook.Helpers.GetPlayerListID(plr)]) then continue end

        local angle = (plr:EyePos() - eye):Angle()
        local addPos = Angle(0, (RoachHook.SilentAimbot.y - angle.y) - 90, 0):Forward()
        
        local pos = Vector(ScrW() / 2, ScrH() / 2, 0) + Vector(addPos.x * xScale, addPos.y * yScale, 0)

        if(math.abs(math.NormalizeAngle(angle.y - RoachHook.SilentAimbot.y)) < 60) then return end
    
        // ARROW

        local arrow = RoachHook.Helpers.GenerateRotatedArrow(pos.x, pos.y, 16, (RoachHook.SilentAimbot.y - angle.y) - 90)
        
        surface.SetDrawColor(plr:IsDormant() && dormClr || clr0)
        draw.NoTexture()
        surface.DrawPoly(arrow)

        surface.SetDrawColor(plr:IsDormant() && dormClr || clr1)
        RoachHook.Helpers.DrawOutlinedPoly(arrow)
    end
end