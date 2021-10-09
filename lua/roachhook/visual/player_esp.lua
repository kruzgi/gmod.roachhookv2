local playerFlags = {}
local playerBars = {}

local function DrawBBOX(v, bbox, team)
    if(!RoachHook.Config["player." .. team .. ".b_bbox"]) then return end

    local clr = RoachHook.Config["player." .. team .. ".b_bbox.color"]
    if(!clr) then return end
    clr.a = v:IsDormant() && clr.a / 8 || clr.a
    local borderClr = RoachHook.Config["player." .. team .. ".b_bbox.outline.color"]
    if(!borderClr) then return end
    borderClr.a = v:IsDormant() && borderClr.a / 8 || borderClr.a

    local typ = RoachHook.Config["player." .. team .. ".b_bbox.type"] || 1

    if(typ == 1) then
        if(RoachHook.Config["player." .. team .. ".b_bbox.outline"]) then
            surface.SetDrawColor(borderClr)
            surface.DrawOutlinedRect(bbox.x, bbox.y, bbox.w, bbox.h)
            surface.DrawOutlinedRect(bbox.x + 2, bbox.y + 2, bbox.w - 4, bbox.h - 4)
    
            surface.SetDrawColor(clr)
            surface.DrawOutlinedRect(bbox.x + 1, bbox.y + 1, bbox.w - 2, bbox.h - 2)
        else
            surface.SetDrawColor(clr)
            surface.DrawOutlinedRect(bbox.x, bbox.y, bbox.w, bbox.h)
        end
    elseif(typ == 2) then
        if(RoachHook.Config["player." .. team .. ".b_bbox.outline"]) then
            local x, y, w, h = bbox.x, bbox.y, bbox.w, bbox.h

            local cW, cH = w / 3, h / 3
            local cW, cH = math.floor(cW), math.floor(cH)
            
            surface.SetDrawColor(borderClr)

            surface.DrawRect(x, y, cW, 3)
            surface.DrawRect(x + w - cW, y, cW, 3)

            surface.DrawRect(x, y, 3, cH)
            surface.DrawRect(x + w - 3, y, 3, cH)

            surface.DrawRect(x, y + h - 3, cW, 3)
            surface.DrawRect(x + w - cW, y + h - 3, cW, 3)

            surface.DrawRect(x, y + h - (cH + 3), 3, cH)
            surface.DrawRect(x + w - 3, y + h - (cH + 3), 3, cH)
            
            surface.SetDrawColor(clr)
            
            surface.DrawRect(x + 1, y + 1, cW - 2, 1)
            surface.DrawRect(x + 1, y + 1, 1, cH - 2)

            surface.DrawRect(x + w - cW + 1, y + 1, cW - 2, 1)
            surface.DrawRect(x + w - 2, y + 1, 1, cH - 2)

            surface.DrawRect(x + 1, y + h - 2, cW - 2, 1)
            surface.DrawRect(x + 1, y + h - (cH + 2), 1, cH)

            surface.DrawRect(x + w - (cW - 1), y + h - 2, cW - 2, 1)
            surface.DrawRect(x + w - 2, y + h - (cH + 2), 1, cH)
        else
            local x, y, w, h = bbox.x, bbox.y, bbox.w, bbox.h

            local cW, cH = w / 3, h / 3
            local cW, cH = math.floor(cW), math.floor(cH)

            surface.SetDrawColor(clr)

            surface.DrawRect(x, y, cW, 1)
            surface.DrawRect(x + w - cW, y, cW, 1)

            surface.DrawRect(x, y, 1, cH)
            surface.DrawRect(x + w - 1, y, 1, cH)

            surface.DrawRect(x, y + h - 1, cW, 1)
            surface.DrawRect(x + w - cW, y + h - 1, cW, 1)

            surface.DrawRect(x, y + h - (cH + 1), 1, cH)
            surface.DrawRect(x + w - 1, y + h - (cH + 1), 1, cH)
        end
    elseif(typ == 3) then
        local pos = v:GetPos()
        local mins, maxs = v:GetCollisionBounds()
        local corners = RoachHook.Helpers.GetCorners(mins, maxs)

        local screenPositions = {}
        for k,c in ipairs(corners) do
            local corner = c
            corner:Rotate(v == RoachHook.Detour.LocalPlayer() && Angle(0, RoachHook.SilentAimbot.y, 0) || v:GetRenderAngles())

            local corner = corner + pos
            screenPositions[k] = corner:ToScreen()
        end

        surface.SetDrawColor(clr)

        surface.DrawLine(screenPositions[1].x, screenPositions[1].y, screenPositions[2].x, screenPositions[2].y)
        surface.DrawLine(screenPositions[2].x, screenPositions[2].y, screenPositions[3].x, screenPositions[3].y)
        surface.DrawLine(screenPositions[3].x, screenPositions[3].y, screenPositions[4].x, screenPositions[4].y)
        surface.DrawLine(screenPositions[4].x, screenPositions[4].y, screenPositions[1].x, screenPositions[1].y)

        surface.DrawLine(screenPositions[1].x, screenPositions[1].y, screenPositions[7].x, screenPositions[7].y)
        surface.DrawLine(screenPositions[2].x, screenPositions[2].y, screenPositions[6].x, screenPositions[6].y)
        surface.DrawLine(screenPositions[3].x, screenPositions[3].y, screenPositions[5].x, screenPositions[5].y)
        surface.DrawLine(screenPositions[4].x, screenPositions[4].y, screenPositions[8].x, screenPositions[8].y)
        
        surface.DrawLine(screenPositions[5].x, screenPositions[5].y, screenPositions[6].x, screenPositions[6].y)
        surface.DrawLine(screenPositions[6].x, screenPositions[6].y, screenPositions[7].x, screenPositions[7].y)
        surface.DrawLine(screenPositions[7].x, screenPositions[7].y, screenPositions[8].x, screenPositions[8].y)
        surface.DrawLine(screenPositions[8].x, screenPositions[8].y, screenPositions[5].x, screenPositions[5].y)
    end
end
local poss = {"left", "top", "right", "bottom"}
local function DrawHealthBar(v, team)
    if(!RoachHook.Config["player." .. team .. ".b_hp_bar"]) then return end
    local pos = poss[RoachHook.Config["player." .. team .. ".b_hp_bar.i_pos"]]

    local clr = RoachHook.Config["player." .. team .. ".b_hp_bar.color"]
    if(!clr) then return end

    local hp = v:Health()

    if(hp <= 0) then return end

    playerBars[v:EntIndex()][pos][#playerBars[v:EntIndex()][pos] + 1] = {
        value = math.Clamp(hp / 100, 0, 1),
        clr = clr,
        flip = pos != "bottom" && pos != "top",
        format = function(i) return tostring(hp) end,
    }
end
local function DrawArmorBar(v, team)
    if(!RoachHook.Config["player." .. team .. ".b_ap_bar"]) then return end
    local pos = poss[RoachHook.Config["player." .. team .. ".b_ap_bar.i_pos"]]

    local clr = RoachHook.Config["player." .. team .. ".b_ap_bar.color"]
    if(!clr) then return end

    local ap = v:Armor()

    if(ap <= 0) then return end

    playerBars[v:EntIndex()][pos][#playerBars[v:EntIndex()][pos] + 1] = {
        value = math.Clamp(ap / 100, 0, 1),
        clr = clr,
        flip = pos != "bottom" && pos != "top",
        format = function(i) return tostring(ap) end,
    }
end
local function DrawAmmoBar(v, team)
    if(!RoachHook.Config["player." .. team .. ".b_ammo_bar"]) then return end
    local pos = poss[RoachHook.Config["player." .. team .. ".b_ammo_bar.i_pos"]]

    local clr = RoachHook.Config["player." .. team .. ".b_ammo_bar.color"]
    if(!clr) then return end

    local weapon = v:GetActiveWeapon()
    if(!weapon) then return end

    if(!weapon || !weapon.GetMaxClip1 || !weapon.Clip1) then return end

    local ammo = weapon:Clip1()
    local ammomax = weapon:GetMaxClip1()

    if(ammo <= 0) then return end

    playerBars[v:EntIndex()][pos][#playerBars[v:EntIndex()][pos] + 1] = {
        value = math.Clamp(ammo / ammomax, 0, 1),
        clr = clr,
        flip = pos != "bottom" && pos != "top",
        format = function(i) return string.format("%d / %d", ammo, ammomax) end,
    }
end
local function AddPlayerFlags(v, teamm)
    if(!RoachHook.Config["player." .. teamm .. ".b_flags"]) then return end
    local flagos = {
        "Usergroup",
        "Ping",
        "SteamID",
        "Traitor Finder",
    }
    local flagsClr = {
        ["Usergroup"] = RoachHook.Config["player." .. teamm .. ".b_flags.selected_flags.color.1"],
        ["Ping"] = RoachHook.Config["player." .. teamm .. ".b_flags.selected_flags.color.2"],
        ["SteamID"] = RoachHook.Config["player." .. teamm .. ".b_flags.selected_flags.color.3"],
        ["Traitor Finder"] = RoachHook.Config["player." .. teamm .. ".b_flags.selected_flags.color.4"],
    }
    local flagsText = {
        ["Usergroup"] = v:GetUserGroup(),
        ["Ping"] = v:Ping() .. "ms",
        ["SteamID"] = v:IsBot() && "BOT" || (v:SteamID() || "unknown steamid"),
        ["Traitor Finder"] = RoachHook.Helpers.IsTraitor(v) && "Traitor" || nil
    }
    local pos = poss[RoachHook.Config["player." .. teamm .. ".b_flags.i_pos"]]
    local flags = RoachHook.Config["player." .. teamm .. ".b_flags.selected_flags"]
    
    for k,f in pairs(flags) do
        if(!f) then continue end

        if(flagsText[flagos[k]]) then
            playerFlags[v:EntIndex()][pos][#playerFlags[v:EntIndex()][pos] + 1] = {
                text = flagsText[flagos[k]],
                clr = flagsClr[flagos[k]] || color_white,
            }
        end
    end
end
local function DrawName(v, team)
    if(!RoachHook.Config["player." .. team .. ".b_name"]) then return end
    local clr = RoachHook.Config["player." .. team .. ".b_name.color"]
    local pos = poss[RoachHook.Config["player." .. team .. ".b_name.i_pos"]]

    playerFlags[v:EntIndex()][pos][#playerFlags[v:EntIndex()][pos] + 1] = {
        text = v:Name(),
        clr = clr,
    }
end

local DrawAboveBars = {}
local function DrawBars(v, bbox)
    local bars = playerBars[v:EntIndex()]
    DrawAboveBars = {}

    local id = 1
    for k,v in pairs(bars.left) do
        local x, y, w, h = bbox.x - (id * 5), bbox.y, 4, bbox.h
        local x, y, w, h = math.floor(x), math.floor(y), math.floor(w), math.floor(h) 
        
        surface.SetDrawColor(Color(0, 0, 0, 128))
        surface.DrawRect(x, y, w, h)

        if(v.flip) then
            surface.SetDrawColor(v.clr || color_white)
            surface.DrawRect(x + 1, y + (h - (h * v.value)), w - 2, h * v.value)

            if(v.format) then
                DrawAboveBars[#DrawAboveBars + 1] = function()
                    draw.SimpleTextOutlined(
                        v.format(),
                        "ESP.Text1",
                        x + w / 2,
                        y + (h - (h * v.value)),
                        color_white,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        1,
                        color_black
                    )
                end
            end
        else
            surface.SetDrawColor(v.clr || color_white)
            surface.DrawRect(x + 1, y, w - 2, h * v.value)
            
            if(v.format) then
                DrawAboveBars[#DrawAboveBars + 1] = function()
                    draw.SimpleTextOutlined(
                        v.format(),
                        "ESP.Text1",
                        x + w / 2,
                        y + (h * v.value),
                        color_white,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        1,
                        color_black
                    )
                end
            end
        end

        id = id + 1
    end
    local id = 0
    for k,v in pairs(bars.right) do
        local x, y, w, h = bbox.x + bbox.w + (id * 5) + 1, bbox.y, 4, bbox.h
        local x, y, w, h = math.floor(x), math.floor(y), math.floor(w), math.floor(h) 
        
        surface.SetDrawColor(Color(0, 0, 0, 128))
        surface.DrawRect(x, y, w, h)

        if(v.flip) then
            surface.SetDrawColor(v.clr || color_white)
            surface.DrawRect(x + 1, y + (h - (h * v.value)), w - 2, h * v.value)
            
            if(v.format) then
                DrawAboveBars[#DrawAboveBars + 1] = function()
                    draw.SimpleTextOutlined(
                        v.format(),
                        "ESP.Text1",
                        x + w / 2,
                        y + (h - (h * v.value)),
                        color_white,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        1,
                        color_black
                    )
                end
            end
        else
            surface.SetDrawColor(v.clr || color_white)
            surface.DrawRect(x + 1, y, w - 2, h * v.value)
            
            if(v.format) then
                DrawAboveBars[#DrawAboveBars + 1] = function()
                    draw.SimpleTextOutlined(
                        v.format(),
                        "ESP.Text1",
                        x + w / 2,
                        y + (h * v.value),
                        color_white,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        1,
                        color_black
                    )
                end
            end
        end

        id = id + 1
    end
    local id = 1
    for k,v in pairs(bars.top) do
        local x, y, w, h = bbox.x, bbox.y - (5 * id), bbox.w, 4
        local x, y, w, h = math.floor(x), math.floor(y), math.floor(w), math.floor(h) 
        
        surface.SetDrawColor(Color(0, 0, 0, 128))
        surface.DrawRect(x, y, w, h)

        if(v.flip) then
            surface.SetDrawColor(v.clr || color_white)
            surface.DrawRect(x + (w - (w * v.value)), y + 1, w * v.value, h - 2)
            
            if(v.format) then
                DrawAboveBars[#DrawAboveBars + 1] = function()
                    draw.SimpleTextOutlined(
                        v.format(),
                        "ESP.Text1",
                        x + (w - (w * v.value)),
                        y + h / 2,
                        color_white,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        1,
                        color_black
                    )
                end
            end
        else
            surface.SetDrawColor(v.clr || color_white)
            surface.DrawRect(x, y + 1, w * v.value, h - 2)
            
            if(v.format) then
                DrawAboveBars[#DrawAboveBars + 1] = function()
                    draw.SimpleTextOutlined(
                        v.format(),
                        "ESP.Text1",
                        x + (w * v.value),
                        y + h / 2,
                        color_white,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        1,
                        color_black
                    )
                end
            end
        end

        id = id + 1
    end
    local id = 0
    for k,v in pairs(bars.bottom) do
        local x, y, w, h = bbox.x, bbox.y + bbox.h + (5 * id) + 1, bbox.w, 4
        local x, y, w, h = math.floor(x), math.floor(y), math.floor(w), math.floor(h) 
        
        surface.SetDrawColor(Color(0, 0, 0, 128))
        surface.DrawRect(x, y, w, h)

        if(v.flip) then
            surface.SetDrawColor(v.clr || color_white)
            surface.DrawRect(x + (w - (w * v.value)), y + 1, w * v.value, h - 2)

            if(v.format) then
                DrawAboveBars[#DrawAboveBars + 1] = function()
                    draw.SimpleTextOutlined(
                        v.format(),
                        "ESP.Text1",
                        x + (w - (w * v.value)),
                        y + h / 2,
                        color_white,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        1,
                        color_black
                    )
                end
            end
        else
            surface.SetDrawColor(v.clr || color_white)
            surface.DrawRect(x, y + 1, w * v.value, h - 2)

            if(v.format) then
                DrawAboveBars[#DrawAboveBars + 1] = function()
                    draw.SimpleTextOutlined(
                        v.format(),
                        "ESP.Text1",
                        x + (w * v.value),
                        y + h / 2,
                        color_white,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        1,
                        color_black
                    )
                end
            end
        end

        id = id + 1
    end

    for k,v in pairs(DrawAboveBars) do
        v()
    end
end
local function DrawFlags(v, bbox)
    local flags = playerFlags[v:EntIndex()]
    local bars = playerBars[v:EntIndex()]

    for k,v in pairs(flags.right) do
        local x, y = bbox.x + bbox.w + 3 + (#bars.right * 6), bbox.y + (14 * (k - 1))

        draw.SimpleTextOutlined(
            v.text,
            "ESP.Text1",
            x,
            y,
            v.clr,
            nil,
            nil,
            1,
            color_black
        )
    end
    for k,v in pairs(flags.left) do
        local x, y = bbox.x - (3 + (#bars.left * 6)), bbox.y + (14 * (k - 1))

        draw.SimpleTextOutlined(
            v.text,
            "ESP.Text1",
            x,
            y,
            v.clr,
            TEXT_ALIGN_RIGHT,
            nil,
            1,
            color_black
        )
    end
    for k,v in pairs(flags.top) do
        local x, y = bbox.x + bbox.w / 2, bbox.y - (14 * (k - 1) + 3 + (#bars.top * 6))

        draw.SimpleTextOutlined(
            v.text,
            "ESP.Text1",
            x,
            y,
            v.clr,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_BOTTOM,
            1,
            color_black
        )
    end
    for k,v in pairs(flags.bottom) do
        local x, y = bbox.x + bbox.w / 2, bbox.y + bbox.h + (14 * (k - 1)) + (#bars.bottom * 6)

        draw.SimpleTextOutlined(
            v.text,
            "ESP.Text1",
            x,
            y,
            v.clr,
            TEXT_ALIGN_CENTER,
            nil,
            1,
            color_black
        )
    end
end

RoachHook.OverlayHook[#RoachHook.OverlayHook + 1] = function()
    local players = player.GetAll()
    for k=0, #players do
        local v = players[k]
        if(!v) then continue end
        if(!v:Alive()) then continue end
        if(v:GetNoDraw()) then continue end
        
        playerFlags[v:EntIndex()] = {
            top = {},
            left = {},
            bottom = {},
            right = {},
        }
        playerBars[v:EntIndex()] = {
            top = {},
            left = {},
            bottom = {},
            right = {},
        }

        if(v == LocalPlayer()) then    // Local
            if(!RoachHook.Config["player.local_esp.b_enable"]) then continue end
            
            local bbox = RoachHook.Helpers.GetRotatedAABB(v, v:GetRenderAngles(), v:GetPos())
            if(!bbox) then continue end
    
            DrawBBOX(v, bbox, "local_esp")
            DrawHealthBar(v, "local_esp")
            DrawArmorBar(v, "local_esp")
            DrawAmmoBar(v, "local_esp")
            DrawName(v, "local_esp")
            AddPlayerFlags(v, "local_esp")

            DrawBars(v, bbox, "local_esp")
            DrawFlags(v, bbox, "local_esp")
        elseif(v:Team() == LocalPlayer():Team()) then   // Team
            if(!RoachHook.Config["player.team_esp.b_enable"]) then continue end
            
            local bbox = RoachHook.Helpers.GetRotatedAABB(v, v:GetRenderAngles(), v:GetPos())
            if(!bbox) then continue end
    
            DrawBBOX(v, bbox, "team_esp")
            DrawHealthBar(v, "team_esp")
            DrawArmorBar(v, "team_esp")
            DrawAmmoBar(v, "team_esp")
            DrawName(v, "team_esp")
            AddPlayerFlags(v, "team_esp")

            DrawBars(v, bbox, "team_esp")
            DrawFlags(v, bbox, "team_esp")
        elseif(v:Team() != LocalPlayer():Team()) then   // Enemy
            if(!RoachHook.Config["player.enemy_esp.b_enable"]) then continue end
            
            local bbox = RoachHook.Helpers.GetRotatedAABB(v, v:GetRenderAngles(), v:GetPos())
            if(!bbox) then continue end
    
            DrawBBOX(v, bbox, "enemy_esp")
            DrawHealthBar(v, "enemy_esp")
            DrawArmorBar(v, "enemy_esp")
            DrawAmmoBar(v, "enemy_esp")
            DrawName(v, "enemy_esp")
            AddPlayerFlags(v, "enemy_esp")

            DrawBars(v, bbox, "enemy_esp")
            DrawFlags(v, bbox, "enemy_esp")
        end
    end
end