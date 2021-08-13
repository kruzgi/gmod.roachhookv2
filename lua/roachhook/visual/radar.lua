local Radar = {
    rotation = 0,
    dist = 5,
    circle = RoachHook.Circles.New(CIRCLE_FILLED, 30, 0, 0),

    Internal = {
        bMouseClicked = false,
        bCanDrag = true,
    
        iAddX = nil,
        iAddY = nil,
    }
}

local function Drag(x, y, size)
    if(!RoachHook.bMenuVisible) then Radar.canDrag = false end
    if(!input.IsMouseDown(MOUSE_LEFT)) then Radar.canDrag = true end
    if(!Radar.canDrag) then return end

    local mX, mY = gui.MousePos()
    local bHovered = Vector(x - mX, y - mY, 0):Length2D() < size / 2
    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(!bHovered) then
            Radar.Internal.bCanDrag = false
        elseif(bHovered && Radar.Internal.bCanDrag && !Radar.Internal.bMouseClicked) then
            local mouseX, mouseY = gui.MousePos()

            Radar.Internal.bMouseClicked = true
            Radar.Internal.iAddX = RoachHook.Config["radar.position"].x - mouseX
            Radar.Internal.iAddY = RoachHook.Config["radar.position"].y - mouseY
        end
    else
        Radar.Internal.bCanDrag = true
        Radar.Internal.bMouseClicked = false
    end

    if(Radar.Internal.bMouseClicked) then
        local mouseX, mouseY = gui.MousePos()

        RoachHook.Config["radar.position"].x = mouseX + Radar.Internal.iAddX
        RoachHook.Config["radar.position"].y = mouseY + Radar.Internal.iAddY
    end
end

RoachHook.OverlayHook[#RoachHook.OverlayHook + 1] = function()
    if(!RoachHook.Config["misc.radar.b_enable"]) then return end
    if(!RoachHook.Config["radar.position"]) then
        RoachHook.Config["radar.position"] = {
            x = 0,
            y = 0,
        }
    end

    local clr = RoachHook.Config["misc.radar.b_enable.color"]
    Radar.rotation = RoachHook.SilentAimbot.y - 90

    Radar.dist = 30 - RoachHook.Config["misc.radar.i_zoom"]

    local scale = ((RoachHook.Config["misc.radar.i_scl"] || 100) / 100)

    local size = 200 * scale
    local x, y = RoachHook.Config["radar.position"].x + size / 2, RoachHook.Config["radar.position"].y + size / 2
    
    Drag(x, y, size)
    RoachHook.Config["radar.position"].x = math.Clamp(RoachHook.Config["radar.position"].x, 0, ScrW() - size)
    RoachHook.Config["radar.position"].y = math.Clamp(RoachHook.Config["radar.position"].y, 0, ScrH() - size)

    if(RoachHook.Config["misc.radar.b_bg"]) then
        local clr = RoachHook.Config["misc.radar.b_bg.color"]
        
        surface.SetDrawColor(clr)
        draw.NoTexture()
        Radar.circle:SetX(x)
        Radar.circle:SetY(y)
        Radar.circle:SetRadius(size / 2)

        Radar.circle()
    end

    local forw, rig = Angle(0, RoachHook.Config["misc.radar.b_rot"] && RoachHook.SilentAimbot.y - 90 || 0, 0):Forward() * (size / 2), Angle(0, RoachHook.Config["misc.radar.b_rot"] && RoachHook.SilentAimbot.y - 90 || 0, 0):Right() * (size / 2)

    surface.SetDrawColor(clr)
    surface.DrawLine(x, y, x + forw.x, y + forw.y)
    surface.DrawLine(x, y, x - forw.x, y - forw.y)
    surface.DrawLine(x, y, x + rig.x, y + rig.y)
    surface.DrawLine(x, y, x - rig.x, y - rig.y)
    surface.DrawCircle(x, y, size / 2, clr.r, clr.g, clr.b)

    local filter = RoachHook.Config["misc.radar.filter"]

    if(filter[1]) then
        local players = player.GetAll()
        for k = 0, #players do
            local plr = players[k]
            if(!plr) then continue end
            if(!plr:Alive()) then continue end
            if(plr == LocalPlayer()) then continue end
    
            local diff = plr:GetPos() - LocalPlayer():GetPos()
            local dist = diff:Length2D()
            local ang = diff:Angle()
            ang:Normalize()
            if(RoachHook.Config["misc.radar.b_rot"]) then
                ang.y = (Radar.rotation - ang.y)
            end
            
            local pos = (ang:Forward() * dist) / Radar.dist
    
            if(pos:Length2D() > 100) then continue end
            
            local clr = RoachHook.Config["misc.radar.b_team_clrs"] && team.GetColor(plr:Team()) || RoachHook.Config["misc.radar.filter.color.1"]
    
            surface.DrawCircle(x + (pos.x * scale), y + (pos.y * scale), 4 * scale, clr.r, clr.g, clr.b)
        end
    end

    if(filter[2]) then
        local npcs = ents.GetAll()
        for k = 0, #npcs do
            local npc = npcs[k]
            if(!npc) then continue end
            if(!npc:IsNPC()) then continue end
            if(npc:Health() <= 0) then continue end
    
            local diff = npc:GetPos() - LocalPlayer():GetPos()
            local dist = diff:Length2D()
            local ang = diff:Angle()
            ang:Normalize()
            if(RoachHook.Config["misc.radar.b_rot"]) then
                ang.y = (Radar.rotation - ang.y)
            end
            
            local pos = (ang:Forward() * dist) / Radar.dist
    
            if(pos:Length2D() > 100) then continue end
            
            local clr = RoachHook.Config["misc.radar.filter.color.2"]

            surface.DrawCircle(x + (pos.x * scale), y + (pos.y * scale), 4 * scale, clr.r, clr.g, clr.b)
        end
    end

    if(filter[3]) then
        for k=1, #RoachHook.MapEntities do
            if(!RoachHook.Config["misc.radar.filter.sents"][k]) then continue end
            local entities = ents.FindByClass(RoachHook.MapEntities[k])
            for k = 0, #entities do
                local ent = entities[k]
                if(!ent) then continue end
        
                local diff = ent:GetPos() - LocalPlayer():GetPos()
                local dist = diff:Length2D()
                local ang = diff:Angle()
                ang:Normalize()
                if(RoachHook.Config["misc.radar.b_rot"]) then
                    ang.y = (Radar.rotation - ang.y)
                end
                
                local pos = (ang:Forward() * dist) / Radar.dist
        
                if(pos:Length2D() > 100) then continue end
                
                local clr = RoachHook.Config["misc.radar.filter.color.3"]
    
                surface.DrawCircle(x + (pos.x * scale), y + (pos.y * scale), 4 * scale, clr.r, clr.g, clr.b)
            end
        end
    end
    
    //local angleDirection = (Radar.rotation - RoachHook.SilentAimbot.y) + 180
    
    local sz = 6 * scale

    draw.RoundedBox(sz, x - (sz / 2), y - (sz / 2), sz, sz, team.GetColor(LocalPlayer():Team()))
end