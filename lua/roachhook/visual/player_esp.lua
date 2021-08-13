local playerFlags = {}
local playerBars = {}

local function DrawCorneredBox(x, y, w, h)
    // TOP LEFT
    surface.DrawLine(x, y, x + w / 3, y)
    surface.DrawLine(x, y, x, y + h / 3)

    // TOP RIGHT
    surface.DrawLine(x + w - w / 3, y, x + w, y)
    surface.DrawLine(x + w, y, x + w, y + h / 3)

    // BOTTOM LEFT
    surface.DrawLine(x, y + h, x + w / 3, y + h)
    surface.DrawLine(x, y + h - h / 3, x, y + h)

    // BOTTOM RIGHT
    surface.DrawLine(x + w - w / 3, y + h, x + w, y + h)
    surface.DrawLine(x + w, y + h - h / 3, x + w, y + h)
end
local function DrawOutlinedCorneredBox(x, y, w, h)
    // TOP LEFT
    surface.DrawRect(x, y, math.floor(w / 3) + 3, 3)
    surface.DrawRect(x, y, 3, math.floor(h / 3) + 2)

    // TOP RIGHT
    surface.DrawRect(x + w - (math.floor(w / 3) + 2), y, math.floor(w / 3) + 3, 3)
    surface.DrawRect(x + w - 2, y, 3, math.floor(h / 3) + 2)
end

local function DrawBBOX(v, bbox, team)
    if(!RoachHook.Config["player." .. team .. ".b_bbox"]) then return end

    local clr = RoachHook.Config["player." .. team .. ".b_bbox.color"]
    if(!clr) then return end
    clr.a = v:IsDormant() && clr.a / 8 || clr.a
    local borderClr = RoachHook.Config["player." .. team .. ".b_bbox.outline.color"]
    if(!borderClr) then return end
    borderClr.a = v:IsDormant() && borderClr.a / 8 || borderClr.a

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
local function AddPlayerFlags(v, team)
    if(!RoachHook.Config["player." .. team .. ".b_flags"]) then return end
    local flagos = {
        "Usergroup",
        "Ping",
        "SteamID",
        "Traitor Finder",
    }
    local flagsClr = {
        ["Usergroup"] = RoachHook.Config["player." .. team .. ".b_flags.selected_flags.color.1"],
        ["Ping"] = RoachHook.Config["player." .. team .. ".b_flags.selected_flags.color.2"],
        ["SteamID"] = RoachHook.Config["player." .. team .. ".b_flags.selected_flags.color.3"],
        ["Traitor Finder"] = RoachHook.Config["player." .. team .. ".b_flags.selected_flags.color.4"],
    }
    local flagsText = {
        ["Usergroup"] = v:GetUserGroup(),
        ["Ping"] = v:Ping() .. "ms",
        ["SteamID"] = v:SteamID(),
        ["Traitor Finder"] = RoachHook.Helpers.IsTraitor(v) && "Traitor" || nil
    }
    local pos = poss[RoachHook.Config["player." .. team .. ".b_flags.i_pos"]]
    local flags = RoachHook.Config["player." .. team .. ".b_flags.selected_flags"]
    
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
        
        surface.SetDrawColor(Color(0, 0, 0, 96))
        surface.DrawRect(x, y, w, h)

        if(v.flip) then
            surface.SetDrawColor(v.clr || color_white)
            surface.DrawRect(x, y + (h - (h * v.value)), w, h * v.value)

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
            surface.DrawRect(x, y, w, h * v.value)
            
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
        
        surface.SetDrawColor(Color(0, 0, 0, 192))
        surface.DrawOutlinedRect(x, y, w, h)

        id = id + 1
    end
    local id = 0
    for k,v in pairs(bars.right) do
        local x, y, w, h = bbox.x + bbox.w + (id * 5) + 1, bbox.y, 4, bbox.h
        local x, y, w, h = math.floor(x), math.floor(y), math.floor(w), math.floor(h) 
        
        surface.SetDrawColor(Color(0, 0, 0, 96))
        surface.DrawRect(x, y, w, h)

        if(v.flip) then
            surface.SetDrawColor(v.clr || color_white)
            surface.DrawRect(x, y + (h - (h * v.value)), w, h * v.value)
            
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
            surface.DrawRect(x, y, w, h * v.value)
            
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
        
        surface.SetDrawColor(Color(0, 0, 0, 192))
        surface.DrawOutlinedRect(x, y, w, h)

        id = id + 1
    end
    local id = 1
    for k,v in pairs(bars.top) do
        local x, y, w, h = bbox.x, bbox.y - (5 * id), bbox.w, 4
        local x, y, w, h = math.floor(x), math.floor(y), math.floor(w), math.floor(h) 
        
        surface.SetDrawColor(Color(0, 0, 0, 96))
        surface.DrawRect(x, y, w, h)

        if(v.flip) then
            surface.SetDrawColor(v.clr || color_white)
            surface.DrawRect(x + (w - (w * v.value)), y, w * v.value, h)
            
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
            surface.DrawRect(x, y, w * v.value, h)
            
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
        
        surface.SetDrawColor(Color(0, 0, 0, 192))
        surface.DrawOutlinedRect(x, y, w, h)

        id = id + 1
    end
    local id = 0
    for k,v in pairs(bars.bottom) do
        local x, y, w, h = bbox.x, bbox.y + bbox.h + (5 * id) + 1, bbox.w, 4
        local x, y, w, h = math.floor(x), math.floor(y), math.floor(w), math.floor(h) 
        
        surface.SetDrawColor(Color(0, 0, 0, 96))
        surface.DrawRect(x, y, w, h)

        if(v.flip) then
            surface.SetDrawColor(v.clr || color_white)
            surface.DrawRect(x + (w - (w * v.value)), y, w * v.value, h)

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
            surface.DrawRect(x, y, w * v.value, h)

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
        
        surface.SetDrawColor(Color(0, 0, 0, 192))
        surface.DrawOutlinedRect(x, y, w, h)

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

        if(v == LocalPlayer()) then                     // Local
            if(!(RoachHook.Config["misc.camera.b_thirdperson"] && RoachHook.PressedVars["misc.camera.b_thirdperson.key"])) then continue end
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