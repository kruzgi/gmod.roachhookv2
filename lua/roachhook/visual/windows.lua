local ACDetectionFrame = {
    anticheats = {}
}
local adminUserGroups = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["moderator"] = true,
    ["mod"] = true,
    ["staff"] = true,
    ["senior-mod"] = true,
    ["senior-moderator"] = true,
    ["senior-admin"] = true,
    ["senior-administrator"] = true,
}
local obs_modes = {
    [OBS_MODE_NONE] = "None",
    [OBS_MODE_DEATHCAM] = "Deathcam",
    [OBS_MODE_FREEZECAM] = "Freezecam",
    [OBS_MODE_FIXED] = "Fixed",
    [OBS_MODE_IN_EYE] = "Firstperson",
    [OBS_MODE_CHASE] = "Thirdperson",
    [OBS_MODE_ROAMING] = "Noclip",
}

local szClickedItem = nil

local function GetSpectators()
    local spectators = {}
    local plrs = player.GetAll()
    for k=0, #plrs do
        local v = plrs[k]
        if(!v) then continue end
        local mode = v:GetObserverMode()
        local target = v:GetObserverTarget()

        if(RoachHook.Config["misc.b_specs_window.self"]) then
            if(target == LocalPlayer() && mode != OBS_MODE_NONE) then
                spectators[#spectators + 1] = v
            end
        else
            if(target == LocalPlayer() || (target == LocalPlayer():GetObserverTarget() && !LocalPlayer():Alive()) && mode != OBS_MODE_NONE) then
                spectators[#spectators + 1] = v
            end
        end
    end

    return spectators
end
local function Spectators()
    if(!RoachHook.Config["windows.spectators_data"]) then
        RoachHook.Config["windows.spectators_data"] = {
            w = 200,
            mouseClicked = false,
            canClick = true,
            avatars = {}
        }
    end
    if(!RoachHook.Config["misc.b_specs_window"]) then
        RoachHook.Config["windows.spectators_data"].canClick = true
        RoachHook.Config["windows.spectators_data"].mouseClicked = false

        return
    end

    local w, h = RoachHook.Config["windows.spectators_data"].w * RoachHook.DPIScale, 15 * RoachHook.DPIScale
    if(!RoachHook.Config["windows.spectators_data"].x || !RoachHook.Config["windows.spectators_data"].y) then
        RoachHook.Config["windows.spectators_data"].x, RoachHook.Config["windows.spectators_data"].y = 560, 0
    end
    
    local x, y = RoachHook.Config["windows.spectators_data"].x, RoachHook.Config["windows.spectators_data"].y

    local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)

    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(!bHovered && RoachHook.Config["windows.spectators_data"].canClick) then
            RoachHook.Config["windows.spectators_data"].canClick = false
        elseif(bHovered && RoachHook.Config["windows.spectators_data"].canClick) then
            if(!szClickedItem) then
                RoachHook.Config["windows.spectators_data"].mouseDX = x - gui.MouseX()
                RoachHook.Config["windows.spectators_data"].mouseDY = y - gui.MouseY()

                szClickedItem = "spec"
            end
        end
    else
        RoachHook.Config["windows.spectators_data"].canClick = true
        if(szClickedItem == "spec") then
            szClickedItem = nil
        end
    end

    local fx, fy = RoachHook.frame.x, RoachHook.frame.y
    local fw, fh = RoachHook.frame.w * RoachHook.DPIScale, RoachHook.frame.h * RoachHook.DPIScale
    local frameHovered = RoachHook.Helpers.MouseInBox(fx, fy, fw, fh)
    if(szClickedItem == "spec" && RoachHook.bMenuVisible && !frameHovered) then
        local x, y = gui.MouseX(), gui.MouseY()

        RoachHook.Config["windows.spectators_data"].x = x + RoachHook.Config["windows.spectators_data"].mouseDX
        RoachHook.Config["windows.spectators_data"].y = y + RoachHook.Config["windows.spectators_data"].mouseDY

        RoachHook.Config["windows.spectators_data"].x = math.Clamp(RoachHook.Config["windows.spectators_data"].x, 0, ScrW() - w)
        RoachHook.Config["windows.spectators_data"].y = math.Clamp(RoachHook.Config["windows.spectators_data"].y, 0, ScrH() - h)
    end

    local clr = RoachHook.GetMenuTheme()
    
    draw.NoTexture()

    surface.SetDrawColor(Color(0, 0, 0, 255 * 0.6))
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(clr)
    surface.DrawRect(x, y, w, 2)
    surface.SetDrawColor(Color(255, 255, 255, 32))
    surface.SetMaterial(RoachHook.Materials.gradient.left)
    surface.DrawTexturedRect(x, y, w, 2)

    draw.SimpleTextOutlined(
        "Spectators",
        "Indicators.MainText",
        x + w / 2,
        y + h / 2 - 1,
        Color(255, 255, 255),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER,
        1,
        Color(0, 0, 0)
    )
    
    local specs = GetSpectators()
    for k=0, #specs do
        local v = specs[k]
        if(!v) then continue end
        if(!RoachHook.Config["windows.spectators_data"][v:EntIndex()] && !v:IsBot() && v:SteamID64()) then
            RoachHook.GetPlayerAvatar(v:SteamID64(), function(mat)
                RoachHook.Config["windows.spectators_data"][v:EntIndex()] = mat
            end)
        end

        if(RoachHook.Config["windows.spectators_data"][v:EntIndex()]) then
            surface.SetDrawColor(Color(0, 0, 0))
            surface.DrawRect(
                x + (5 * RoachHook.DPIScale),
                y + ((h + (3 * RoachHook.DPIScale)) * k),
                h,
                h
            )

            surface.SetDrawColor(Color(255, 255, 255))
            surface.SetMaterial(RoachHook.Config["windows.spectators_data"][v:EntIndex()])
            surface.DrawTexturedRect(
                x + (5 * RoachHook.DPIScale) + 1,
                y + ((h + (3 * RoachHook.DPIScale)) * k) + 1,
                h - 2,
                h - 2
            )
        end

        draw.SimpleTextOutlined(
            RoachHook.Helpers.ClampText(v:Name(), 24),
            "Indicators.MainText",
            x + (5 * RoachHook.DPIScale) + (RoachHook.Config["windows.spectators_data"][v:EntIndex()] && (h + (5 * RoachHook.DPIScale)) || 0),
            y + ((h + (3 * RoachHook.DPIScale)) * k) + h / 2 - 1,
            adminUserGroups[v:GetUserGroup()] && Color(255, 0, 0) || Color(255, 255, 255),
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER,
            1,
            Color(0, 0, 0)
        )
        draw.SimpleTextOutlined(
            obs_modes[v:GetObserverMode()],
            "Indicators.MainText",
            x + w - (5 * RoachHook.DPIScale),
            y + ((h + (3 * RoachHook.DPIScale)) * k) + h / 2 - 1,
            Color(255, 255, 255),
            TEXT_ALIGN_RIGHT,
            TEXT_ALIGN_CENTER,
            1,
            Color(0, 0, 0)
        )
    end
end
local function Admins()
    if(!RoachHook.Config["windows.admins_data"]) then
        RoachHook.Config["windows.admins_data"] = {
            w = 200,
            canClick = true,
        }
    end
    if(!RoachHook.Config["misc.b_admins_window"]) then
        RoachHook.Config["windows.admins_data"].canClick = true

        return
    end

    local w, h = RoachHook.Config["windows.admins_data"].w * RoachHook.DPIScale, 15 * RoachHook.DPIScale
    if(!RoachHook.Config["windows.admins_data"].x || !RoachHook.Config["windows.admins_data"].y) then
        RoachHook.Config["windows.admins_data"].x, RoachHook.Config["windows.admins_data"].y = 0, 0
    end
    
    local x, y = RoachHook.Config["windows.admins_data"].x, RoachHook.Config["windows.admins_data"].y

    local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)

    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(!bHovered && RoachHook.Config["windows.admins_data"].canClick) then
            RoachHook.Config["windows.admins_data"].canClick = false
        elseif(bHovered && RoachHook.Config["windows.admins_data"].canClick) then
            if(!szClickedItem) then
                RoachHook.Config["windows.admins_data"].mouseDX = x - gui.MouseX()
                RoachHook.Config["windows.admins_data"].mouseDY = y - gui.MouseY()

                szClickedItem = "admin"
            end
        end
    else
        RoachHook.Config["windows.admins_data"].canClick = true
        
        if(szClickedItem == "admin") then
            szClickedItem = nil
        end
    end

    local fx, fy = RoachHook.frame.x, RoachHook.frame.y
    local fw, fh = RoachHook.frame.w * RoachHook.DPIScale, RoachHook.frame.h * RoachHook.DPIScale
    local frameHovered = RoachHook.Helpers.MouseInBox(fx, fy, fw, fh)
    if(szClickedItem == "admin" && RoachHook.bMenuVisible && !frameHovered) then
        local x, y = gui.MouseX(), gui.MouseY()

        RoachHook.Config["windows.admins_data"].x = x + RoachHook.Config["windows.admins_data"].mouseDX
        RoachHook.Config["windows.admins_data"].y = y + RoachHook.Config["windows.admins_data"].mouseDY

        RoachHook.Config["windows.admins_data"].x = math.Clamp(RoachHook.Config["windows.admins_data"].x, 0, ScrW() - w)
        RoachHook.Config["windows.admins_data"].y = math.Clamp(RoachHook.Config["windows.admins_data"].y, 0, ScrH() - h)
    end

    local clr = RoachHook.GetMenuTheme()
    
    draw.NoTexture()

    surface.SetDrawColor(Color(0, 0, 0, 255 * 0.6))
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(clr)
    surface.DrawRect(x, y, w, 2)
    surface.SetDrawColor(Color(255, 255, 255, 32))
    surface.SetMaterial(RoachHook.Materials.gradient.left)
    surface.DrawTexturedRect(x, y, w, 2)

    draw.SimpleTextOutlined(
        "Admins",
        "Indicators.MainText",
        x + w / 2,
        y + h / 2 - 1,
        Color(255, 255, 255),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER,
        1,
        Color(0, 0, 0)
    )

    local admins = {}
    local plrs = player.GetAll()
    for k=0, #plrs do
        local v = plrs[k]
        if(!v) then continue end
        if(adminUserGroups[v:GetUserGroup()]) then
            admins[#admins + 1] = {
                name = v:Name(),
                group = v:GetUserGroup(),
            }
        end
    end
    
    for k=0, #admins do
        local v = admins[k]
        if(!v) then continue end
        draw.SimpleTextOutlined(
            v.name,
            "Indicators.MainText",
            x + (5 * RoachHook.DPIScale),
            y + h / 2 + ((12 * RoachHook.DPIScale) * k),
            Color(255, 255, 255),
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER,
            1,
            Color(0, 0, 0)
        )
        draw.SimpleTextOutlined(
            v.group,
            "Indicators.MainText",
            x + w - (5 * RoachHook.DPIScale),
            y + h / 2 + ((12 * RoachHook.DPIScale) * k),
            Color(255, 255, 255),
            TEXT_ALIGN_RIGHT,
            TEXT_ALIGN_CENTER,
            1,
            Color(0, 0, 0)
        )
    end
end
local function ACDetection()
    if(!RoachHook.Config["windows.acdetect_data"]) then
        RoachHook.Config["windows.acdetect_data"] = {
            w = 200,
            mouseClicked = false,
            canClick = true,
        }
    end
    if(!RoachHook.Config["misc.b_ac_detection_window"]) then
        RoachHook.Config["windows.acdetect_data"].canClick = true

        return
    end

    RoachHook.Config["windows.acdetect_data"].anticheats = {}
    if(bSecure) then
        RoachHook.Config["windows.acdetect_data"].anticheats[#RoachHook.Config["windows.acdetect_data"].anticheats + 1] = {name = "bSecure", bypassed = true}
    end
    
    local w, h = RoachHook.Config["windows.acdetect_data"].w * RoachHook.DPIScale, 15 * RoachHook.DPIScale
    if(!RoachHook.Config["windows.acdetect_data"].x || !RoachHook.Config["windows.acdetect_data"].y) then
        RoachHook.Config["windows.acdetect_data"].x, RoachHook.Config["windows.acdetect_data"].y = 280, 0
    end
    
    local x, y = RoachHook.Config["windows.acdetect_data"].x, RoachHook.Config["windows.acdetect_data"].y

    local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)

    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(!bHovered && RoachHook.Config["windows.acdetect_data"].canClick) then
            RoachHook.Config["windows.acdetect_data"].canClick = false
        elseif(bHovered && RoachHook.Config["windows.acdetect_data"].canClick) then
            if(!szClickedItem) then
                RoachHook.Config["windows.acdetect_data"].mouseDX = x - gui.MouseX()
                RoachHook.Config["windows.acdetect_data"].mouseDY = y - gui.MouseY()
                
                szClickedItem = "acdet"
            end
        end
    else
        RoachHook.Config["windows.acdetect_data"].canClick = true
        
        if(szClickedItem == "acdet") then
            szClickedItem = nil
        end
    end

    local fx, fy = RoachHook.frame.x, RoachHook.frame.y
    local fw, fh = RoachHook.frame.w * RoachHook.DPIScale, RoachHook.frame.h * RoachHook.DPIScale
    local frameHovered = RoachHook.Helpers.MouseInBox(fx, fy, fw, fh)
    if(szClickedItem == "acdet" && RoachHook.bMenuVisible && !frameHovered) then
        local x, y = gui.MouseX(), gui.MouseY()

        RoachHook.Config["windows.acdetect_data"].x = x + RoachHook.Config["windows.acdetect_data"].mouseDX
        RoachHook.Config["windows.acdetect_data"].y = y + RoachHook.Config["windows.acdetect_data"].mouseDY

        RoachHook.Config["windows.acdetect_data"].x = math.Clamp(RoachHook.Config["windows.acdetect_data"].x, 0, ScrW() - w)
        RoachHook.Config["windows.acdetect_data"].y = math.Clamp(RoachHook.Config["windows.acdetect_data"].y, 0, ScrH() - h)
    end

    local clr = RoachHook.GetMenuTheme()
    
    draw.NoTexture()

    surface.SetDrawColor(Color(0, 0, 0, 255 * 0.6))
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(clr)
    surface.DrawRect(x, y, w, 2)
    surface.SetDrawColor(Color(255, 255, 255, 32))
    surface.SetMaterial(RoachHook.Materials.gradient.left)
    surface.DrawTexturedRect(x, y, w, 2)

    draw.SimpleTextOutlined(
        "Detected Anti-Cheats",
        "Indicators.MainText",
        x + w / 2,
        y + h / 2 - 1,
        Color(255, 255, 255),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER,
        1,
        Color(0, 0, 0)
    )

    for k=0, #ACDetectionFrame.anticheats do
        local v = ACDetectionFrame.anticheats[k]
        if(!v) then continue end
        draw.SimpleTextOutlined(
            v.name,
            "Indicators.MainText",
            x + (5 * RoachHook.DPIScale),
            y + h / 2 + ((12 * RoachHook.DPIScale) * k),
            v.bypassed && Color(0, 255, 0) || Color(255, 0, 0),
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER,
            1,
            Color(0, 0, 0)
        )
        draw.SimpleTextOutlined(
            v.bypassed && "Undetected" || "Detected",
            "Indicators.MainText",
            x + w - (5 * RoachHook.DPIScale),
            y + h / 2 + ((12 * RoachHook.DPIScale) * k),
            v.bypassed && Color(0, 255, 0) || Color(255, 0, 0),
            TEXT_ALIGN_RIGHT,
            TEXT_ALIGN_CENTER,
            1,
            Color(0, 0, 0)
        )
    end
end
local function KeybindState()
    if(!RoachHook.Config["windows.keybindstate_data"]) then
        RoachHook.Config["windows.keybindstate_data"] = {
            w = 200,
            canClick = true,
        }
    end
    if(!RoachHook.Config["misc.b_keybinds"]) then
        RoachHook.Config["windows.keybindstate_data"].canClick = true

        return
    end
    
    local w, h = RoachHook.Config["windows.keybindstate_data"].w * RoachHook.DPIScale, 15 * RoachHook.DPIScale
    if(!RoachHook.Config["windows.keybindstate_data"].x || !RoachHook.Config["windows.keybindstate_data"].y) then
        RoachHook.Config["windows.keybindstate_data"].x, RoachHook.Config["windows.keybindstate_data"].y = 840, 0
    end
    
    local x, y = RoachHook.Config["windows.keybindstate_data"].x, RoachHook.Config["windows.keybindstate_data"].y

    local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)

    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(!bHovered && RoachHook.Config["windows.keybindstate_data"].canClick) then
            RoachHook.Config["windows.keybindstate_data"].canClick = false
        elseif(bHovered && RoachHook.Config["windows.keybindstate_data"].canClick) then
            if(!szClickedItem) then
                RoachHook.Config["windows.keybindstate_data"].mouseDX = x - gui.MouseX()
                RoachHook.Config["windows.keybindstate_data"].mouseDY = y - gui.MouseY()

                szClickedItem = "keys"
            end
        end
    else
        RoachHook.Config["windows.keybindstate_data"].canClick = true
        
        if(szClickedItem == "keys") then
            szClickedItem = nil
        end
    end

    local fx, fy = RoachHook.frame.x, RoachHook.frame.y
    local fw, fh = RoachHook.frame.w * RoachHook.DPIScale, RoachHook.frame.h * RoachHook.DPIScale
    local frameHovered = RoachHook.Helpers.MouseInBox(fx, fy, fw, fh)
    if(szClickedItem == "keys" && RoachHook.bMenuVisible && !frameHovered) then
        local x, y = gui.MouseX(), gui.MouseY()

        RoachHook.Config["windows.keybindstate_data"].x = x + RoachHook.Config["windows.keybindstate_data"].mouseDX
        RoachHook.Config["windows.keybindstate_data"].y = y + RoachHook.Config["windows.keybindstate_data"].mouseDY

        RoachHook.Config["windows.keybindstate_data"].x = math.Clamp(RoachHook.Config["windows.keybindstate_data"].x, 0, ScrW() - w)
        RoachHook.Config["windows.keybindstate_data"].y = math.Clamp(RoachHook.Config["windows.keybindstate_data"].y, 0, ScrH() - h)
    end

    local clr = RoachHook.GetMenuTheme()
    
    draw.NoTexture()

    surface.SetDrawColor(Color(0, 0, 0, 255 * 0.6))
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(clr)
    surface.DrawRect(x, y, w, 2)
    surface.SetDrawColor(Color(255, 255, 255, 32))
    surface.SetMaterial(RoachHook.Materials.gradient.left)
    surface.DrawTexturedRect(x, y, w, 2)

    draw.SimpleTextOutlined(
        "Keybind States",
        "Indicators.MainText",
        x + w / 2,
        y + h / 2 - 1,
        Color(255, 255, 255),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER,
        1,
        Color(0, 0, 0)
    )

    local keyBinds = {}

    for k=0, #RoachHook.PressedVars do
        local v = RoachHook.PressedVars[k]
        if(v) then
            local nameVar = string.Replace(k, ".key", "")
            if(!RoachHook.Config[nameVar]) then continue end
            local menuItem = RoachHook.Helpers.GetMenuItemFromVar(nameVar)
            if(menuItem) then
                keyBinds[#keyBinds + 1] = {
                    name = menuItem.name,
                    state = RoachHook.Config[k].mode
                }
            end
        end
    end

    for k=0, #keyBinds do
        local v = keyBinds[k]
        if(!v) then continue end
        draw.SimpleTextOutlined(
            v.name,
            "Indicators.MainText",
            x + (5 * RoachHook.DPIScale),
            y + h / 2 + ((12 * RoachHook.DPIScale) * k),
            Color(255, 255, 255),
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER,
            1,
            Color(0, 0, 0)
        )
        draw.SimpleTextOutlined(
            v.state,
            "Indicators.MainText",
            x + w - (5 * RoachHook.DPIScale),
            y + h / 2 + ((12 * RoachHook.DPIScale) * k),
            Color(255, 255, 255),
            TEXT_ALIGN_RIGHT,
            TEXT_ALIGN_CENTER,
            1,
            Color(0, 0, 0)
        )
    end
end
local function Indicators()
    if(!RoachHook.Config["windows.indicators_data"]) then
        RoachHook.Config["windows.indicators_data"] = {
            w = 200,
            mouseClicked = false,
            canClick = true,
        }
    end
    if(!RoachHook.Config["misc.b_indicators"]) then
        RoachHook.Config["windows.indicators_data"].canClick = true

        return
    end
    
    local w, h = RoachHook.Config["windows.indicators_data"].w * RoachHook.DPIScale, 15 * RoachHook.DPIScale
    if(!RoachHook.Config["windows.indicators_data"].x || !RoachHook.Config["windows.indicators_data"].y) then
        RoachHook.Config["windows.indicators_data"].x, RoachHook.Config["windows.indicators_data"].y = 0, 40
    end
    
    local x, y = RoachHook.Config["windows.indicators_data"].x, RoachHook.Config["windows.indicators_data"].y

    local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)

    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(!bHovered && RoachHook.Config["windows.indicators_data"].canClick) then
            RoachHook.Config["windows.indicators_data"].canClick = false
        elseif(bHovered && RoachHook.Config["windows.indicators_data"].canClick) then
            if(!szClickedItem) then
                RoachHook.Config["windows.indicators_data"].mouseDX = x - gui.MouseX()
                RoachHook.Config["windows.indicators_data"].mouseDY = y - gui.MouseY()

                szClickedItem = "indi"
            end
        end
    else
        RoachHook.Config["windows.indicators_data"].canClick = true
        
        if(szClickedItem == "indi") then
            szClickedItem = nil
        end
    end

    local fx, fy = RoachHook.frame.x, RoachHook.frame.y
    local fw, fh = RoachHook.frame.w * RoachHook.DPIScale, RoachHook.frame.h * RoachHook.DPIScale
    local frameHovered = RoachHook.Helpers.MouseInBox(fx, fy, fw, fh)
    if(szClickedItem == "indi" && RoachHook.bMenuVisible && !frameHovered) then
        local x, y = gui.MouseX(), gui.MouseY()

        RoachHook.Config["windows.indicators_data"].x = x + RoachHook.Config["windows.indicators_data"].mouseDX
        RoachHook.Config["windows.indicators_data"].y = y + RoachHook.Config["windows.indicators_data"].mouseDY

        RoachHook.Config["windows.indicators_data"].x = math.Clamp(RoachHook.Config["windows.indicators_data"].x, 0, ScrW() - w)
        RoachHook.Config["windows.indicators_data"].y = math.Clamp(RoachHook.Config["windows.indicators_data"].y, 0, ScrH() - h)
    end

    local clr = RoachHook.GetMenuTheme()
    
    draw.NoTexture()

    surface.SetDrawColor(Color(0, 0, 0, 255 * 0.6))
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(clr)
    surface.DrawRect(x, y, w, 2)
    surface.SetDrawColor(Color(255, 255, 255, 32))
    surface.SetMaterial(RoachHook.Materials.gradient.left)
    surface.DrawTexturedRect(x, y, w, 2)

    draw.SimpleTextOutlined(
        "Indicators",
        "Indicators.MainText",
        x + w / 2,
        y + h / 2 - 1,
        Color(255, 255, 255),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER,
        1,
        Color(0, 0, 0)
    )

    local indicatorsToDraw = {}
    if(RoachHook.Config["fakelag.b_enable"]) then
        local fakelagmodes = {
            "Default",
            "Fluctuate",
            "Dynamic",
            "Random",
        }

        indicatorsToDraw[#indicatorsToDraw + 1] = {
            text = "Fakelag - " .. fakelagmodes[RoachHook.Config["fakelag.i_mode"]],
            value = RoachHook.Modules.Big.GetChokedPackets() / RoachHook.iWishTicks
        }
    end
    
    if(RoachHook.Config["antiaim.b_enable"]) then
        local fakeDelta = math.abs(math.NormalizeAngle(RoachHook.AntiAimData.fake.y - RoachHook.AntiAimData.real.y))
        
        indicatorsToDraw[#indicatorsToDraw + 1] = {
            text = "AntiAim",
            value = fakeDelta / 180
        }

        if(LocalPlayer():GetVelocity():Length2D() < 5) then
            local lbyTimer = (CurTime() - RoachHook.aaLBYTimer) / RoachHook.LBYTime
            
            indicatorsToDraw[#indicatorsToDraw + 1] = {
                text = "LBY",
                value = math.Clamp(lbyTimer, 0, 1)
            }
        end
    end

    if(RoachHook.Config["antiaim.b_fake_flick"] && RoachHook.PressedVars["antiaim.b_fake_flick.key"]) then
        local flFakeFlickTime = RoachHook.bFakeFlick_Timer - CurTime()
        
        indicatorsToDraw[#indicatorsToDraw + 1] = {
            text = "Fake Flick",
            value = 1 - math.Clamp(flFakeFlickTime / RoachHook.Config["antiaim.b_fake_flick.fl_time"], 0, 1)
        }
    end

    if(RoachHook.Config["fakelag.b_fakeduck"] && RoachHook.PressedVars["fakelag.b_fakeduck.key"]) then
        local flStandHeight = RoachHook.Detour.LocalPlayer():GetCurrentViewOffset().z / RoachHook.Detour.LocalPlayer():GetViewOffset().z
        
        indicatorsToDraw[#indicatorsToDraw + 1] = {
            text = "Fake Duck",
            value = flStandHeight
        }
    end

    for k,v in ipairs(indicatorsToDraw) do
        draw.SimpleTextOutlined(
            v.text,
            "Indicators.MainText",
            x + (5 * RoachHook.DPIScale),
            y + h / 2 + ((12 * RoachHook.DPIScale) * k),
            Color(255, 255, 255),
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER,
            1,
            Color(0, 0, 0)
        )

        surface.SetFont("Indicators.MainText")
        local textW, textH = surface.GetTextSize(v.text)

        local x, y = x + w / 2, y + h / 2 + ((12 * RoachHook.DPIScale) * k)
        local w, h = w / 2, textH / 2
        local y = y - h / 2
        surface.SetDrawColor(Color(0, 0, 0, 128))
        surface.DrawRect(x, y, w, h)

        surface.SetDrawColor(RoachHook.GetMenuTheme())
        surface.DrawRect(x, y, w * v.value, h)
        
        surface.SetDrawColor(Color(0, 0, 0))

        surface.SetMaterial(RoachHook.Materials.gradient.down)
        surface.DrawTexturedRect(x, y, w * v.value, h)
        
        surface.DrawOutlinedRect(x, y, w, h)
    end
end

RoachHook.OverlayHook[#RoachHook.OverlayHook + 1] = function()
    Spectators()
    Admins()
    ACDetection()
    KeybindState()
    Indicators()

    local fx, fy = RoachHook.frame.x, RoachHook.frame.y
    local fw, fh = RoachHook.frame.w * RoachHook.DPIScale, RoachHook.frame.h * RoachHook.DPIScale
    local frameHovered = RoachHook.Helpers.MouseInBox(fx, fy, fw, fh)
    if(szClickedItem && RoachHook.bMenuVisible && !frameHovered) then
        local x, y = gui.MouseX(), gui.MouseY()

        surface.SetDrawColor(Color(255, 255, 255, 32))
        surface.DrawLine(x, 0, x, ScrH())
        surface.DrawLine(0, y, ScrW(), y)

        local datas = {"windows.spectators_data", "windows.admins_data", "windows.acdetect_data", "windows.keybindstate_data", "windows.indicators_data"}
        for k,v in ipairs(datas) do
            local v = RoachHook.Config[v]
            
            if(v.x && v.y) then
                draw.SimpleTextOutlined(
                    string.format("x : %d y : %d", v.x, v.y),
                    nil,
                    v.x,
                    v.y - (2 * RoachHook.DPIScale),
                    color_white,
                    nil,
                    TEXT_ALIGN_BOTTOM,
                    1,
                    color_black
                )
                draw.SimpleTextOutlined(
                    string.format("x : %d y : %d", v.x + (v.w * RoachHook.DPIScale), v.y),
                    nil,
                    v.x + (v.w * RoachHook.DPIScale),
                    v.y - (2 * RoachHook.DPIScale),
                    color_white,
                    TEXT_ALIGN_RIGHT,
                    TEXT_ALIGN_BOTTOM,
                    1,
                    color_black
                )
            end
        end
    end
end