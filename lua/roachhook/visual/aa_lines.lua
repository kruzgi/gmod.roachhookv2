RoachHook.OverlayHook[#RoachHook.OverlayHook + 1] = function()
    if(!RoachHook.Config["visual.b_aa_lines"]) then return end

    local me = RoachHook.Detour.LocalPlayer()
    if(!me || !me:Alive()) then return end
    local pos = me:GetPos()
    if(!pos) then return end
    
    local screenPos = pos:ToScreen()
    if(!screenPos.visible) then return end

    local realPos = pos + Angle(0, RoachHook.AntiAimData.nonLBYReal.y, 0):Forward() * 30
    local fakePos = pos + Angle(0, RoachHook.AntiAimData.fake.y, 0):Forward() * 30
    -- local lbyPos = pos + Angle(0, RoachHook.AntiAimData.LBY.y, 0):Forward() * 30

    local screenRealPos = realPos:ToScreen()
    local screenFakePos = fakePos:ToScreen()
    -- local screenLBYPos = lbyPos:ToScreen()
    if(!screenRealPos.visible || !screenFakePos.visible/* || !screenLBYPos.visible*/) then return end

    surface.SetDrawColor(255, 0, 0)
    surface.DrawLine(screenPos.x, screenPos.y, screenFakePos.x, screenFakePos.y)
    
    surface.SetDrawColor(0, 255, 0)
    surface.DrawLine(screenPos.x, screenPos.y, screenRealPos.x, screenRealPos.y)

    -- surface.SetDrawColor(0, 0, 255)
    -- surface.DrawLine(screenPos.x, screenPos.y, screenLBYPos.x, screenLBYPos.y)
end