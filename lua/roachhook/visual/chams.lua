local mats = {
    RoachHook.Materials.chams.none,
    RoachHook.Materials.chams.textured,
    RoachHook.Materials.chams.textured, //flat
    RoachHook.Materials.chams.wireframe,
    RoachHook.Materials.chams.metalic,
}
local overlay = {
    RoachHook.Materials.chams.none,
    RoachHook.Materials.chams.wireframe,
    Material("models/props_combine/portalball001_sheet"),
}

hook.Add("PrePlayerDraw", "LocalPlayerChams", function(plr)
    if(plr != RoachHook.Detour.LocalPlayer()) then return end
    if(RoachHook.DrawingFake) then return end
    if(!system.HasFocus() && RoachHook.Config["misc.b_alt_tab_hide_visuals"]) then return end

    if(RoachHook.Config["player.local_chams.b_enable"]) then
        local clr = RoachHook.Config["player.local_chams.b_enable.color"]
        local mat = RoachHook.Config["player.local_chams.b_enable.mat"]
        
        render.MaterialOverride(mats[mat])
        render.SuppressEngineLighting(mat == 3)
        render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
        render.SetBlend(clr.a / 255)
    end
end)
hook.Add("PostPlayerDraw", "LocalPlayerChamsFix", function(plr)
    if(plr != RoachHook.Detour.LocalPlayer()) then return end
    if(RoachHook.DrawingFake) then return end

    render.SetColorModulation(1, 1, 1)
    render.SetBlend(1)
    render.MaterialOverride(RoachHook.Materials.chams.none)
    render.SuppressEngineLighting(false)
end)

local plrTransColor = Color(255, 255, 255, 0)
local function RenderChams()
    if(!system.HasFocus() && RoachHook.Config["misc.b_alt_tab_hide_visuals"]) then
        for k,v in ipairs(player.GetAll()) do
            v:SetColor(color_white)
            v:SetRenderMode(RENDERMODE_TRANSCOLOR)
        end

        return
    end

    -- Local Chams (LocalPlayer Chams, Fake Chams)
    cam.Start3D()
        
        local plr = RoachHook.Detour.LocalPlayer()
        
        if(RoachHook.Config["player.local_chams.b_enable"] && RoachHook.Config["player.local_chams.b_enable.b_overlay"]) then
            local clr = RoachHook.Config["player.local_chams.b_enable.b_overlay.color"]
            local mat = RoachHook.Config["player.local_chams.b_enable.b_overlay.mat"]
            
            if(mat != 1) then
                RoachHook.DrawingFake = true
    
                render.MaterialOverride(overlay[mat])
                render.SuppressEngineLighting(mat == 3)
                render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
                render.SetBlend(clr.a / 255)
                plr:DrawModel()
                
                RoachHook.DrawingFake = false
            end
        end

        if(RoachHook.Config["player.local_chams.b_enable"] && RoachHook.Config["player.local_chams.b_fake"]) then
            local clr = RoachHook.Config["player.local_chams.b_fake.color"]
            local mat = RoachHook.Config["player.local_chams.b_fake.mat"]
            
            local anglesDiff = math.abs(RoachHook.AntiAimData.real.y - RoachHook.AntiAimData.fake.y)
            if(anglesDiff > 5) then
                plr:InvalidateBoneCache()
    
                    plr:SetPoseParameter("aim_yaw", 0)
                    plr:SetPoseParameter("head_yaw", 0)
    
                    local pitch = (math.Clamp(RoachHook.AntiAimData.fake.x, -89, 89) + 89) / (89 * 2)
    
                    local aPMin, aPMax = plr:GetPoseParameterRange(plr:LookupPoseParameter("aim_pitch"))
                    local hPMin, hPMax = plr:GetPoseParameterRange(plr:LookupPoseParameter("head_pitch"))
                    if(pitch && aPMin && aPMax) then
                        plr:SetPoseParameter("aim_pitch", math.Remap(pitch, 0, 1, aPMin, aPMax))
                    end

                    if(pitch && hPMin && hPMax) then
                        plr:SetPoseParameter("head_pitch", math.Remap(pitch, 0, 1, hPMin, hPMax))
                    end
    
                    local vel = plr:GetVelocity():Length2D()
                    local velScale = math.Clamp(vel / 60, 0, 1)
                    local velocity = (plr:GetVelocity():Angle() - Angle(0, RoachHook.AntiAimData.fake.y, 0)):Forward() * velScale
    
                    plr:SetPoseParameter("move_x", velocity.x)
                    plr:SetPoseParameter("move_y", -velocity.y)
    
                    plr:SetRenderAngles(Angle(0, RoachHook.AntiAimData.fake.y, 0))
                    
                plr:SetupBones()
                
                RoachHook.DrawingFake = true
    
                render.MaterialOverride(mats[mat])
                render.SuppressEngineLighting(mat == 3)
                render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
                render.SetBlend(clr.a / 255)
                plr:DrawModel()
                
                if(RoachHook.Config["player.local_chams.b_fake.b_overlay"]) then
                    local clr = RoachHook.Config["player.local_chams.b_fake.b_overlay.color"]
                    local mat = RoachHook.Config["player.local_chams.b_fake.b_overlay.mat"]
    
                    if(mat != 1) then
                        render.MaterialOverride(overlay[mat])
                        render.SuppressEngineLighting(mat == 3)
                        render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
                        render.SetBlend(clr.a / 255)
                        plr:DrawModel()
                    end
                end
                
                RoachHook.DrawingFake = false
            end
        end

        render.SetColorModulation(1, 1, 1)
        render.SetBlend(1)
        render.MaterialOverride(RoachHook.Materials.chams.none)
        render.SuppressEngineLighting(false)

    cam.End3D()
    
    local me = RoachHook.Detour.LocalPlayer()
    
    -- Invisible Chams
    cam.Start3D()

        cam.IgnoreZ(true)

        for k,v in ipairs(player.GetAll()) do
            v:SetColor(color_white)
            v:SetRenderMode(RENDERMODE_TRANSCOLOR)

            if(!v:Alive() || v:IsDormant()) then continue end

            if(v == me) then continue end
                
            if(v:Team() == me:Team() && RoachHook.Config["player.team.chams.enable"]) then
                local clr = RoachHook.Config["player.team.chams.invisible_chams.color"]
                local mat = RoachHook.Config["player.team.chams.invisible_chams.mat"]

                render.MaterialOverride(mats[mat])
                render.SuppressEngineLighting(mat == 3)
                render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
                render.SetBlend((clr.a - 0.01) / 255)

                v:SetColor(plrTransColor)
                v:DrawModel()

                if(RoachHook.Config["player.team.chams.invisible_overlay"]) then
                    local clr = RoachHook.Config["player.team.chams.invisible_overlay.color"]
                    local mat = RoachHook.Config["player.team.chams.invisible_overlay.mat"]
    
                    if(mat != 1) then
                        render.MaterialOverride(overlay[mat])
                        render.SuppressEngineLighting(false)
                        render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
                        render.SetBlend((clr.a - 0.01) / 255)
        
                        v:SetColor(plrTransColor)
                        v:DrawModel()
                    end
                end
            elseif(v:Team() != me:Team() && RoachHook.Config["player.enemy.chams.enable"]) then
                local clr = RoachHook.Config["player.enemy.chams.invisible_chams.color"]
                local mat = RoachHook.Config["player.enemy.chams.invisible_chams.mat"]

                render.MaterialOverride(mats[mat])
                render.SuppressEngineLighting(mat == 3)
                render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
                render.SetBlend((clr.a - 0.01) / 255)

                v:SetColor(plrTransColor)
                v:DrawModel()

                if(RoachHook.Config["player.enemy.chams.invisible_overlay"]) then
                    local clr = RoachHook.Config["player.enemy.chams.invisible_overlay.color"]
                    local mat = RoachHook.Config["player.enemy.chams.invisible_overlay.mat"]
    
                    if(mat != 1) then
                        render.MaterialOverride(overlay[mat])
                        render.SuppressEngineLighting(false)
                        render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
                        render.SetBlend((clr.a - 0.01) / 255)
        
                        v:SetColor(plrTransColor)
                        v:DrawModel()
                    end
                end
            end
        end
        
        cam.IgnoreZ(false)

    cam.End3D()

    -- Visible Chams
    cam.Start3D()

        for k,v in ipairs(player.GetAll()) do
            v:SetColor(color_white)
            v:SetRenderMode(RENDERMODE_TRANSCOLOR)
            
            if(!v:Alive() || v:IsDormant()) then continue end

            if(v == me) then continue end
                
            if(v:Team() == me:Team() && RoachHook.Config["player.team.chams.enable"]) then
                local clr = RoachHook.Config["player.team.chams.visible_chams.color"]
                local mat = RoachHook.Config["player.team.chams.visible_chams.mat"]

                render.MaterialOverride(mats[mat])
                render.SuppressEngineLighting(mat == 3)
                render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
                render.SetBlend(clr.a / 255)

                v:SetColor(Color(255, 255, 255, 0))
                v:DrawModel()
                
                if(RoachHook.Config["player.team.chams.visible_overlay"]) then
                    local clr = RoachHook.Config["player.team.chams.visible_overlay.color"]
                    local mat = RoachHook.Config["player.team.chams.visible_overlay.mat"]
    
                    if(mat != 1) then
                        render.MaterialOverride(overlay[mat])
                        render.SuppressEngineLighting(false)
                        render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
                        render.SetBlend(clr.a / 255)
        
                        v:SetColor(Color(255, 255, 255, 0))
                        v:DrawModel()
                    end
                end
            elseif(v:Team() != me:Team() && RoachHook.Config["player.enemy.chams.enable"]) then
                local clr = RoachHook.Config["player.enemy.chams.visible_chams.color"]
                local mat = RoachHook.Config["player.enemy.chams.visible_chams.mat"]

                render.MaterialOverride(mats[mat])
                render.SuppressEngineLighting(mat == 3)
                render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
                render.SetBlend(clr.a / 255)

                v:SetColor(Color(255, 255, 255, 0))
                v:DrawModel()
                
                if(RoachHook.Config["player.enemy.chams.visible_overlay"]) then
                    local clr = RoachHook.Config["player.enemy.chams.visible_overlay.color"]
                    local mat = RoachHook.Config["player.enemy.chams.visible_overlay.mat"]
    
                    if(mat != 1) then
                        render.MaterialOverride(overlay[mat])
                        render.SuppressEngineLighting(false)
                        render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
                        render.SetBlend(clr.a / 255)
        
                        v:SetColor(Color(255, 255, 255, 0))
                        v:DrawModel()
                    end
                end
            end
        end

    cam.End3D()
end
hook.Add("RenderScreenspaceEffects", "Chams", function()
    if(RoachHook.Config["misc.b_obs_proof"]) then return end
    
    for k,v in ipairs(RoachHook.RenderScreenspaceEffectsHook) do v() end
    RenderChams()
end)

RoachHook.OverlayHook[#RoachHook.OverlayHook + 1] = function()
    if(!RoachHook.Config["misc.b_obs_proof"] || gui.IsGameUIVisible()) then return end
    
    RenderChams()
end