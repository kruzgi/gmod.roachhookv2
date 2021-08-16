/*
 * its for lua executors so everything will work fine on servers with sv_allowcslua 0 :)
 */
local sv_allowcslua = GetConVar("sv_allowcslua")
function RoachHook_IncludeFile(fil)
    if(sv_allowcslua:GetInt() == 1) then
        return include(fil)
    end

    local content = file.Read(fil, "LUA")
    if(!content) then
        print("ERROR: file: " .. fil .. " not found!")
        return
    end
    local func = CompileString(content, nil, false)()
    return func
end

local bigSetup = {
    ChangeName = function() return end,
    FinishPrediction = function() return end,
    FullUpdate = function() return end,
    GetChokedPackets = function() return 0 end,
    GetInSequenceNumber = function() return 0 end,
    GetLatency = function() return 0 end,
    GetOutSequenceNumber = function() return 0 end,
    GetSpreadVector = function() return Vector() end,
    HookProp = function() return end,
    MD5PseudoRandom = function() return 0 end,
    RandomFloat = function() return 0 end,
    RandomInt = function() return 0 end,
    RandomSeed = function() return 0 end,
    SetChokedPackets = function() return end,
    SetInSequenceNumber = function() return end,
    SetInterpolation = function() return end,
    SetOutSequenceNumber = function() return end,
    StartPrediction = function() return end,
    StringCmd = function() return end,
    TickCount = function() return 0 end,
    UnhookProp = function() return end,
}

bSendPacket = true

file.CreateDir("roachhook")
file.CreateDir("roachhook/net_logger")
file.CreateDir("roachhook/config")
file.CreateDir("roachhook/scripts")

RoachHook = RoachHook || {}
RoachHook.CheatVer = "2.0.5.3"
RoachHook.CheatVerShort = "2"
RoachHook.Detour = table.Copy(_G)
RoachHook.Config = RoachHook.Config || {}
RoachHook.Config["madeby"] = "admin"
RoachHook.Config["cheatver"] = RoachHook.CheatVer
RoachHook.iWishTicks = 0

hook.Add("Think", "LoadName", function()
    local me = RoachHook.Detour.LocalPlayer()
    if(!me || !IsValid(me) || !me.Name) then return end

    RoachHook.Config["madeby"] = me:Name()
    hook.Remove("Think", "LoadName")
end)

RoachHook.AntiAimData = {
    real = Angle(),
    fake = Angle(),
    current = Angle()
}
RoachHook.LastSentPos = Vector()
RoachHook.Features = {}
RoachHook.Features.Misc = {}
RoachHook.Features.Legitbot = {}
RoachHook.Features.Ragebot = {}
RoachHook.Materials = {
    gradient = {
        left    = RoachHook.Detour.Material("vgui/gradient-l"),
        right   = RoachHook.Detour.Material("vgui/gradient-r"),
        up      = RoachHook.Detour.Material("vgui/gradient-u"),
        down    = RoachHook.Detour.Material("vgui/gradient-d"),
    },
    chams = {
        textured = RoachHook.Detour.Material("models/debug/debugwhite"),
        metalic = RoachHook.Detour.CreateMaterial("Metalic", "VertexLitGeneric", {
            ["$basetexture"] = "vgui/white_additive",
            ["$ignorez"] = 0,
            ["$envmap"] = "env_cubemap",
            ["$normalmapalphaenvmapmask"] = 1,
            ["$envmapcontrast"] = 1,
            ["$nofog"] = 1,
            ["$model"] = 1,
            ["$nocull"] = 0,
            ["$selfillum"] = 1,
            ["$halflambert"] = 1,
            ["$znearer"] = 0,
            ["$flat"] = 1,
        }),
        wireframe = RoachHook.Detour.Material("models/wireframe"),
        none = RoachHook.Detour.Material(""),
    }
}

RoachHook.DPIScale = 1.25
RoachHook.iLineHeight = 3
RoachHook.ActiveFrame = nil
RoachHook.ActiveItem = nil
RoachHook.OverlayHook = {}
RoachHook.RenderScreenspaceEffectsHook = {}
RoachHook.DrawBehindMenu = {}
RoachHook.bMenuVisible = false
RoachHook.bMenuVisibleLast = !RoachHook.bMenuVisible
RoachHook.bMenuKeyClicked = false
RoachHook.Modules = {}
RoachHook.Modules.Big = bigSetup
RoachHook.SilentAimbot = RoachHook.SilentAimbot || nil
RoachHook.ServerTime = nil

local moduleLoadTimer = CurTime()
hook.Add("Think", "AntiCrashModules", function()
    if(!LocalPlayer() || !IsValid(LocalPlayer())) then return end
    if(moduleLoadTimer + 0.2 <= CurTime()) then
        require("big")
        RoachHook.Modules.Big = big
        hook.Remove("Think", "AntiCrashModules")
    end
end)

RoachHook.Detour.hook.Add("Move", "UpdateServerTime", function()
    if(!IsFirstTimePredicted()) then return; end
    RoachHook.ServerTime = CurTime();
end);

local menuClr = Color(0, 0, 255)
RoachHook.GetMenuTheme = function()
    if(RoachHook.Config["misc.b_override_color"] == true) then
        return RoachHook.Config["misc.b_override_color.color"]
    else
        return menuClr
    end
end

Menu = {}

// Includes
RoachHook_IncludeFile("roachhook/helpers/helpers.lua")
RoachHook.GetPlayerAvatar = RoachHook_IncludeFile("roachhook/helpers/avatar.lua")
RoachHook_IncludeFile("roachhook/helpers/bsp_parser.lua")
RoachHook.Circles = RoachHook_IncludeFile("roachhook/helpers/circles.lua")

RoachHook.LocalPlayerAvatar = nil
hook.Add("Think", "Load Avatar", function()
    if(LocalPlayer() && IsValid(LocalPlayer()) && LocalPlayer().SteamID64 && LocalPlayer():SteamID64()) then
        RoachHook.GetPlayerAvatar(LocalPlayer():SteamID64(), function(mat)
            RoachHook.LocalPlayerAvatar = mat
        end)
        
        hook.Remove("Think", "Load Avatar")
    end
end)
RoachHook.Keybinds = {}

// UI
RoachHook_IncludeFile("roachhook/menu/frame.lua")
RoachHook_IncludeFile("roachhook/menu/color_picker.lua")
RoachHook_IncludeFile("roachhook/menu/keybind.lua")
RoachHook_IncludeFile("roachhook/menu/checkbox.lua")
RoachHook_IncludeFile("roachhook/menu/listbox.lua")
RoachHook_IncludeFile("roachhook/menu/button.lua")
RoachHook_IncludeFile("roachhook/menu/sliderint.lua")
RoachHook_IncludeFile("roachhook/menu/sliderfloat.lua")
RoachHook_IncludeFile("roachhook/menu/combo.lua")
RoachHook_IncludeFile("roachhook/menu/multi_combo.lua")
RoachHook_IncludeFile("roachhook/menu/textbox.lua")

// Features
RoachHook_IncludeFile("roachhook/visual/windows.lua")
RoachHook_IncludeFile("roachhook/visual/player_esp.lua")
RoachHook_IncludeFile("roachhook/visual/entity_esp.lua")
RoachHook_IncludeFile("roachhook/visual/viewmodel_chams.lua")
RoachHook_IncludeFile("roachhook/visual/radar.lua")
RoachHook_IncludeFile("roachhook/visual/logs.lua")
RoachHook_IncludeFile("roachhook/visual/world.lua")
RoachHook_IncludeFile("roachhook/visual/view.lua")
RoachHook_IncludeFile("roachhook/visual/animations.lua")
RoachHook_IncludeFile("roachhook/visual/chams.lua")

RoachHook_IncludeFile("roachhook/misc/movement.lua")
RoachHook_IncludeFile("roachhook/misc/net_dump.lua")
RoachHook_IncludeFile("roachhook/misc/money_aimbot.lua")
RoachHook_IncludeFile("roachhook/misc/cvar_bypass.lua")
RoachHook_IncludeFile("roachhook/misc/cfg_system.lua")

RoachHook_IncludeFile("roachhook/legitbot/aimbot.lua")
RoachHook_IncludeFile("roachhook/ragebot/run.lua")
// Fonts
RoachHook.UpdateFonts = function()
    RoachHook.Detour.surface.CreateFont("Menu.Title", {
        font = "Noto Sans JP",
        size = math.floor(20 * RoachHook.DPIScale),
        weight = 1337,
    })
    RoachHook.Detour.surface.CreateFont("Menu.TabText", {
        font = "Noto Sans JP",
        size = math.floor(15 * RoachHook.DPIScale),
        weight = 400,
    })
    RoachHook.Detour.surface.CreateFont("Menu.ChecboxText", {
        font = "Noto Sans JP",
        size = math.floor(14 * RoachHook.DPIScale),
        weight = 0,
    })
    RoachHook.Detour.surface.CreateFont("Menu.ListboxText", {
        font = "Noto Sans JP",
        size = math.floor(14 * RoachHook.DPIScale),
        weight = 0,
    })
    RoachHook.Detour.surface.CreateFont("Menu.ButtonText", {
        font = "Noto Sans JP",
        size = math.floor(14 * RoachHook.DPIScale),
        weight = 0,
    })
    RoachHook.Detour.surface.CreateFont("Menu.UnderText", {
        font = "Noto Sans JP",
        size = math.floor(12 * RoachHook.DPIScale),
    })
    RoachHook.Detour.surface.CreateFont("ESP.Text1", {
        font = "Verdana",
        size = 12,
        weight = 0,
        antialias = false,
    })
    RoachHook.Detour.surface.CreateFont("Indicators.MainText", {
        font = "Verdana",
        size = 10 * RoachHook.DPIScale,
        antialias = false,
    })
    
    RoachHook.Detour.surface.CreateFont("RoachHook.CCFont", {
        font = "Tahoma",
        size = 12 * RoachHook.DPIScale,
        antialias = false,
    })
    RoachHook.Detour.surface.CreateFont("RoachHook.CCFont.bold", {
        font = "Arial",
        size = 12 * RoachHook.DPIScale,
        weight = 999999,
        antialias = false,
    })
    RoachHook.Detour.surface.CreateFont("RoachHook.CCFont.italic", {
        font = "Arial",
        size = 12 * RoachHook.DPIScale,
        italic = true,
        antialias = false,
    })
    RoachHook.Detour.surface.CreateFont("RoachHook.CCFont.underline", {
        font = "Arial",
        size = 12 * RoachHook.DPIScale,
        underline = true,
        antialias = false,
    })
    RoachHook.Detour.surface.CreateFont("RoachHook.CCFont.strikethrough", {
        font = "Arial",
        size = 12 * RoachHook.DPIScale,
        strikeout = true,
        antialias = false,
    })
end
RoachHook.UpdateFonts()

// DPI Scaling auto update
local customDPIScale = 125
RoachHook.Detour.hook.Add("Think", "UpdateDPIScaling", function()
    if(!RoachHook.Config["misc.i_selected_dpi_scale"]) then return end
    
    local scales = {
        ScrH() / 1080,
        0.5,
        0.75,
        1,
        1.25,
        1.5,
        2,
        customDPIScale / 100,
    }

    if(!input.IsMouseDown(MOUSE_LEFT)) then
        customDPIScale = RoachHook.Config["misc.i_selected_dpi_scale.custom"]
    end

    if(scales[RoachHook.Config["misc.i_selected_dpi_scale"]] != RoachHook.DPIScale) then
        RoachHook.DPIScale = scales[RoachHook.Config["misc.i_selected_dpi_scale"]]
        RoachHook.UpdateFonts()
    end
end)

local hitboxes = {
    "Head",
    "Body",
    "Arms",
    "Hands",
    "Legs",
    "Feet",
}
local targetting = {
    "Cycle",
    "Distance",
    "Health",
    "FOV"
}
local base_yaw = {
    "Default",
    "At targets (Distance)",
    "At targets (FOV)",
    "Static",
}
local pitch = {
    "Viewangles",
    "Up",
    "Fake Up",
    "Lag Up",
    "Down",
    "Fake Down",
    "Lag Down",
    "Zero",
    "Lag Zero (Up)",
    "Lag Zero (Down)",
    "Jitter (Up, Down)",
    "Fake Jitter (Fake Up, Fake Down)",
    "Random",
    "Custom"
}
local yaw = {
    "Forward",
    "Backward",
    "Right",
    "Left",
    "Random",
    "Spin",
    "180° Spin",
    "180° Random",
    "Custom",
}
local yaw_mod = {
    "None",
    "Wall detection",
    //"Freestanding",
    //"Wall detection + Freestanding"
}
local jitter = {
    "Disabled",
    "Offset",
    "Center",
    "Random",
}
local materials = {
    "Default",
    "Textured",
    "Flat",
    "Wireframe",
    "Metalic",
}
local materials_overlay = {
    "None",
    "Wireframe",
    "Animated",
}

RoachHook.MapEntities = RoachHook.Helpers.GetMapEntities()

local function GetClickedItems(var)
    local num = 0
    local items = RoachHook.Config[var]
    for i=1, #items do
        if(items[i]) then num = num + 1 end
    end
    return num
end

local function GetPlayerNames()
    local players = {}
    for k,v in ipairs(player.GetAll()) do
        if(v==LocalPlayer()) then continue end

        players[#players + 1] = v:Name()
    end

    return players
end

local configs = {}
local scripts = {}
local cfgbw = (420 / 5) - 4
local cfgsx = function(i) return 5 * i end
local configData = {}
// Setup menu
local cvar_gamemode = GetConVar("gamemode")
RoachHook.frame = Menu.NewFrame("roachhook v" .. RoachHook.CheatVerShort, 650, 470, {
    {"Ragebot",     RoachHook.Detour.Material("ragebot.png"), {
        {
            name = "Rage Aimbot",
            items = {
                Menu.NewCheckbox("Enable Ragebot", "ragebot.b_enable", false),
                Menu.NewCheckbox("Silent", "ragebot.b_silent", true, function()
                    return RoachHook.Config["ragebot.b_enable"]
                end),
                Menu.NewCheckbox("Team Check", "ragebot.b_team_check", false, function()
                    return RoachHook.Config["ragebot.b_enable"]
                end),
                Menu.NewCombo("Targetting", "ragebot.targetting", targetting, 1, function()
                    return RoachHook.Config["ragebot.b_enable"]
                end),
                Menu.NewSliderInt("FOV", "ragebot.i_fov", 180, 0, 180, "%d°", function()
                    return RoachHook.Config["ragebot.b_enable"]
                end),
                Menu.NewMultiCombo("Hitboxes", "ragebot.hitboxes", hitboxes, {}, function()
                    return RoachHook.Config["ragebot.b_enable"]
                end),
                Menu.NewCheckbox("Multipoints", "ragebot.b_multipoints", false, function()
                    return RoachHook.Config["ragebot.b_enable"]
                end),
                Menu.NewMultiCombo("Multipoint Hitboxes", "ragebot.multipoint_hitboxes", hitboxes, {}, function()
                    return RoachHook.Config["ragebot.b_enable"] && RoachHook.Config["ragebot.b_multipoints"]
                end),
                Menu.NewSliderInt("Multipoints Scale", "ragebot.i_multipoint_scale", 0, 0, 100, "%d%%", function()
                    return RoachHook.Config["ragebot.b_enable"] && RoachHook.Config["ragebot.b_multipoints"]
                end),
                Menu.NewSliderInt("Multipoints Scans", "ragebot.i_multipoint_scans", 1, 1, 5, "%d", function()
                    return RoachHook.Config["ragebot.b_enable"] && RoachHook.Config["ragebot.b_multipoints"]
                end),
                Menu.NewCheckbox("Autowall", "ragebot.b_autowall", false, function()
                    return RoachHook.Config["ragebot.b_enable"]
                end),
                Menu.NewSliderInt("Autowall Strength", "ragebot.b_autowall.i_strength", 100, 25, 300, "%d%%", function()
                    return RoachHook.Config["ragebot.b_autowall"]
                end)
            }
        },
        {
            name = "Rage Anti-Aim",
            customH = 605,
            items = {
                Menu.NewCheckbox("Enable Anti-Aim", "antiaim.b_enable", false),
                Menu.NewCombo("Base yaw", "antiaim.i_base_yaw", base_yaw, 1, function()
                    return RoachHook.Config["antiaim.b_enable"]
                end),
                Menu.NewSliderInt("Static Yaw", "antiaim.i_base_yaw.static_yaw", 0, -180, 180, "%d°", function()
                    return RoachHook.Config["antiaim.b_enable"] && base_yaw[RoachHook.Config["antiaim.i_base_yaw"]] == "Static"
                end),
                Menu.NewCombo("Pitch", "antiaim.i_pitch", pitch, 1, function()
                    return RoachHook.Config["antiaim.b_enable"]
                end),
                Menu.NewSliderInt("Custom Pitch", "antiaim.i_pitch.static_yaw", 0, -180, 180, "%d°", function()
                    return RoachHook.Config["antiaim.b_enable"] && pitch[RoachHook.Config["antiaim.i_pitch"]] == "Custom"
                end),
                Menu.NewCombo("Real Yaw", "antiaim.i_real_yaw", yaw, 1, function()
                    return RoachHook.Config["antiaim.b_enable"]
                end),
                Menu.NewSliderInt("Real Spin Speed", "antiaim.i_real_yaw.spin_speed", 50, 0, 100, "%d%%", function()
                    return RoachHook.Config["antiaim.b_enable"] && (yaw[RoachHook.Config["antiaim.i_real_yaw"]] == "Spin" || yaw[RoachHook.Config["antiaim.i_real_yaw"]] == "180° Spin")
                end),
                Menu.NewSliderInt("Custom Real Yaw", "antiaim.i_real_yaw.custom", 0, -180, 180, "%d°", function()
                    return RoachHook.Config["antiaim.b_enable"] && yaw[RoachHook.Config["antiaim.i_real_yaw"]] == "Custom"
                end),
                Menu.NewCombo("Fake Yaw", "antiaim.i_fake_yaw", yaw, 1, function()
                    return RoachHook.Config["antiaim.b_enable"]
                end),
                Menu.NewSliderInt("Fake Spin Speed", "antiaim.i_fake_yaw.spin_speed", 50, 0, 100, "%d%%", function()
                    return RoachHook.Config["antiaim.b_enable"] && (yaw[RoachHook.Config["antiaim.i_fake_yaw"]] == "Spin" || yaw[RoachHook.Config["antiaim.i_fake_yaw"]] == "180° Spin")
                end),
                Menu.NewSliderInt("Custom Fake Yaw", "antiaim.i_fake_yaw.custom", 0, -180, 180, "%d°", function()
                    return RoachHook.Config["antiaim.b_enable"] && yaw[RoachHook.Config["antiaim.i_fake_yaw"]] == "Custom"
                end),
                Menu.NewCombo("Yaw Modifier", "antiaim.i_yaw_modifier", yaw_mod, 1, function()
                    return RoachHook.Config["antiaim.b_enable"]
                end),
                Menu.NewSliderInt("Scans", "antiaim.i_yaw_modifier.scans", 10, 2, 30, "%d", function()
                    return RoachHook.Config["antiaim.b_enable"] && RoachHook.Config["antiaim.i_yaw_modifier"] != 1
                end),
                Menu.NewCombo("Jitter", "antiaim.i_jitter", jitter, 1, function()
                    return RoachHook.Config["antiaim.b_enable"]
                end),
                Menu.NewSliderInt("Jitter Yaw", "antiaim.i_jitter.deg", 0, 0, 180, "%d°", function()
                    return RoachHook.Config["antiaim.b_enable"] && RoachHook.Config["antiaim.i_jitter"] != 1
                end),
                Menu.NewCheckbox("Fake Flick", "antiaim.b_fake_flick", false, function()
                    return RoachHook.Config["antiaim.b_enable"]
                end, nil, nil, nil, true, nil, "hold"),
                Menu.NewSliderFloat("Fake Flick Timer", "antiaim.b_fake_flick.fl_time", 1.0, 0.1, 1.5, "%0.1f seconds", 1, function()
                    return RoachHook.Config["antiaim.b_enable"] && RoachHook.Config["antiaim.b_fake_flick"]
                end)
            }
        },
        {
            name = "Fake Lag",
            items = {
                Menu.NewCheckbox("Fakelag", "fakelag.b_enable", false),
                Menu.NewCombo("Fakelag Mode", "fakelag.i_mode", {
                    "Default",
                    "Fluctuate",
                    "Dynamic",
                    "Random",
                }, 1, function()
                    return RoachHook.Config["fakelag.b_enable"]
                end),
                Menu.NewSliderInt("Fakelag Ticks", "fakelag.i_mode.ticks", 1, 1, 23, "%d", function()
                    return RoachHook.Config["fakelag.b_enable"]
                end),
                Menu.NewCheckbox("Always", "fakelag.b_always", false, function()
                    return RoachHook.Config["fakelag.b_enable"]
                end),
                Menu.NewCheckbox("Fake Duck", "fakelag.b_fakeduck", false, function()
                    return RoachHook.Config["fakelag.b_enable"]
                end, nil, nil, nil, true, 0, "hold"),
                Menu.NewCombo("Fake Duck Mode", "fakelag.b_fakeduck.i_mode", {"Default", "Fast"}, 1, function()
                    return RoachHook.Config["fakelag.b_enable"] && RoachHook.Config["fakelag.b_fakeduck"]
                end)
            }
        },
    } },
    {"Legitbot",    RoachHook.Detour.Material("legitbot.png"), {
        {
            name = "Legit Aimbot",
            items = {
                Menu.NewCheckbox("Enable Legitbot", "legitbot.b_enable", false, nil, nil, nil, nil, true, nil, "hold"),
                Menu.NewSliderInt("FOV", "legitbot.i_fov", 0, 0, 180, "%d°", function()
                    return RoachHook.Config["legitbot.b_enable"]
                end),
                Menu.NewSliderFloat("Deathzone FOV", "legitbot.i_deadzone_fov", 0, 0, 5, "%0.2f°", 2, function()
                    return RoachHook.Config["legitbot.b_enable"]
                end),
                Menu.NewSliderInt("Smoothness", "legitbot.i_smooth", 0, 0, 100, "%d%%", function()
                    return RoachHook.Config["legitbot.b_enable"]
                end),
                Menu.NewCheckbox("Simulate Mouse Movement", "legitbot.b_mouse_sim", false, function()
                    return RoachHook.Config["legitbot.b_enable"]
                end),
                Menu.NewMultiCombo("Hitboxes", "legitbot.hitbox", {
                    "Head",
                    "Body",
                    "Arms",
                    "Legs",
                }, {}),
                Menu.NewMultiCombo("Ignore", "legitbot.target", {
                    "Team",
                    "Enemy",
                    "Admin",
                    "Noclip",
                    "Godmode",
                    "Frozen",
                    "Bot",
                }, {true, true}),
            }
        },
        {
            name = "Triggerbot",
            items = {
                
            }
        },
    } },
    {"Visual",      RoachHook.Detour.Material("visual.png"), {
        {
            name = "Entity ESP",
            items = {
                Menu.NewMultiCombo("Entities", "visual.selected_ents", RoachHook.Helpers.GetMapEntities(), {}, nil, function()
                    return RoachHook.Helpers.GetMapEntities()
                end),

                Menu.NewCheckbox("Bounding Box", "visual.selected_ents.b_bbox", false, function()
                    return GetClickedItems("visual.selected_ents") > 0
                end, true, true, Color(255, 255, 255)),
                Menu.NewCheckbox("Bounding Box Outline", "visual.selected_ents.b_bbox.b_outline", false, function()
                    return GetClickedItems("visual.selected_ents") > 0 && RoachHook.Config["visual.selected_ents.b_bbox"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCheckbox("Classname", "visual.selected_ents.b_classname", false, function()
                    return GetClickedItems("visual.selected_ents") > 0
                end, true, true, Color(255, 255, 255)),
                Menu.NewCheckbox("Owner", "visual.selected_ents.b_owner", false, function()
                    return GetClickedItems("visual.selected_ents") > 0
                end, true, true, Color(255, 255, 255)),
                Menu.NewMultiCombo("Flags", "visual.selected_ents.flags", {
                    "Money (money_printer, spawned_money only)",
                    "Health (maybe all entities)",
                    "Distance",
                    "Speed",
                }, {}, function()
                    return GetClickedItems("visual.selected_ents") > 0
                end, nil, true, true, Color(255, 255, 255)),
            }
        },
        {
            name = "Camera",
            items = {
                Menu.NewCheckbox("Free Cam", "misc.camera.b_freecam", false),
                Menu.NewSliderInt("Free Cam Speed", "misc.camera.b_freecam.speed", 15, 5, 300, "%d u/s", function()
                    return RoachHook.Config["misc.camera.b_freecam"]
                end),

                Menu.NewCheckbox("Thirdperson", "misc.camera.b_thirdperson", false, nil, nil, nil, nil, true, nil, "hold"),
                Menu.NewSliderInt("Thirdperson Distance", "misc.camera.b_thirdperson.i_dist", 115, 90, 300, nil, function()
                    return RoachHook.Config["misc.camera.b_thirdperson"]
                end),
                
                Menu.NewSliderInt("FOV", "misc.camera.i_fov", 0, 0, 60, "%d°"),
                Menu.NewCheckbox("Force FOV", "misc.camera.b_force_fov", false),
            }
        },
        {
            name = "Radar",
            items = {
                Menu.NewCheckbox("Enable Radar", "misc.radar.b_enable", false, nil, true, false, Color(255, 255, 255)),
                Menu.NewCheckbox("Radar Background", "misc.radar.b_bg", true, function()
                    return RoachHook.Config["misc.radar.b_enable"]
                end, true, true, Color(0, 0, 0)),
                Menu.NewSliderInt("Radar Zoom", "misc.radar.i_zoom", 5, 0, 30, "%d", function()
                    return RoachHook.Config["misc.radar.b_enable"]
                end),
                Menu.NewCheckbox("Radar Rotation", "misc.radar.b_rot", true, function()
                    return RoachHook.Config["misc.radar.b_enable"]
                end),
                Menu.NewSliderInt("Radar Scale", "misc.radar.i_scl", 100, 50, 200, "%d%%", function()
                    return RoachHook.Config["misc.radar.b_enable"]
                end),
                Menu.NewMultiCombo("Radar Filter", "misc.radar.filter", {
                    "Player",
                    "NPC",
                    "Entity",
                }, {true, false, false}, function()
                    return RoachHook.Config["misc.radar.b_enable"]
                end, nil, true, false, Color(255, 255, 255)),
                Menu.NewMultiCombo("Entities", "misc.radar.filter.sents", RoachHook.MapEntities, {}, function()
                    return RoachHook.Config["misc.radar.b_enable"] && RoachHook.Config["misc.radar.filter"][3]
                end, function()
                    return RoachHook.Helpers.GetMapEntities()
                end),
                Menu.NewCheckbox("Radar Use Team Colors", "misc.radar.b_team_clrs", true, function()
                    return RoachHook.Config["misc.radar.b_enable"] && RoachHook.Config["misc.radar.filter"][1]
                end)
            }
        },
        {
            name = "Overlays",
            items = {
                Menu.NewCheckbox("Anticheat detection window (WIP)", "misc.b_ac_detection_window", false),
                Menu.NewCheckbox("Keybind State", "misc.b_keybinds", false),
                Menu.NewCheckbox("Admins window", "misc.b_admins_window", false),
                Menu.NewCheckbox("Spectators window", "misc.b_specs_window", false),
                Menu.NewCheckbox("Only spectating myself", "misc.b_specs_window.self", true, function()
                    return RoachHook.Config["misc.b_specs_window"]
                end),
                Menu.NewCheckbox("Indicators", "misc.b_indicators", false),
                Menu.NewCheckbox("Logs", "misc.b_logs", false),
                Menu.NewMultiCombo("Log list", "misc.b_logs.logs", {
                    "Misses",
                    "Aimbot Shots",
                    "Player Spawns",
                    "Player Hurt",
                    "Player Death",
                }, {}, function()
                    return RoachHook.Config["misc.b_logs"]
                end),
                Menu.NewCheckbox("AntiAim Lines", "visual.b_aa_lines", false),
            }
        },
        {
            name = "Other",
            items = {
                Menu.NewMultiCombo("Removals", "visual.removals", {
                    "Visual Recoil",
                    "2D Skybox",
                    "OnShot Animation",
                    "Viewmodel Bump while Fake Ducking",
                }, {}),
                Menu.NewCheckbox("World Modulation", "visuals.b_world_modulation", false, nil, true, true, Color(255, 255, 255)),
                Menu.NewCheckbox("Prop Modulation", "visuals.b_prop_modulation", false, nil, true, true, Color(255, 255, 255)),
            },
        }
    } },
    {"Player",      RoachHook.Detour.Material("player.png"), {
        {
            name = "Viewmodel",
            items = {
                Menu.NewCheckbox("Enable Viewmodel Chams", "player.b_viewmodel_chams", false, nil, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Viewmodel Chams Material", "player.b_viewmodel_chams.mat", materials, 1, function()
                    return RoachHook.Config["player.b_viewmodel_chams"]
                end),

                Menu.NewCheckbox("Enable Hand Chams", "player.b_hand_chams", false, nil, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Hands Chams Material", "player.b_hand_chams.mat", materials, 1, function()
                    return RoachHook.Config["player.b_hand_chams"]
                end),

                Menu.NewCheckbox("Override Viewmodel", "player.b_custom_viewmodel", false),
                Menu.NewSliderFloat("Viewmodel X", "player.b_custom_viewmodel.x", 0, -30, 30, nil, 1, function()
                    return RoachHook.Config["player.b_custom_viewmodel"]
                end),
                Menu.NewSliderFloat("Viewmodel Y", "player.b_custom_viewmodel.y", 0, -30, 30, nil, 1, function()
                    return RoachHook.Config["player.b_custom_viewmodel"]
                end),
                Menu.NewSliderFloat("Viewmodel Z", "player.b_custom_viewmodel.z", 0, -30, 30, nil, 1, function()
                    return RoachHook.Config["player.b_custom_viewmodel"]
                end),
                Menu.NewSliderFloat("Viewmodel Roll", "player.b_custom_viewmodel.roll", 0, -180, 180, "%d°", 1, function()
                    return RoachHook.Config["player.b_custom_viewmodel"]
                end),
            }
        },
        {
            name = "Local ESP",
            customH = 600,
            items = {
                Menu.NewCheckbox("Enable ESP", "player.local_esp.b_enable", false),
                Menu.NewCheckbox("Bounding Box", "player.local_esp.b_bbox", false, function()
                    return RoachHook.Config["player.local_esp.b_enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCheckbox("Bounding Box Outline", "player.local_esp.b_bbox.outline", false, function()
                    return RoachHook.Config["player.local_esp.b_enable"] && RoachHook.Config["player.local_esp.b_bbox"]
                end, true, true, Color(0, 0, 0)),
                Menu.NewCheckbox("Name", "player.local_esp.b_name", false, function()
                    return RoachHook.Config["player.local_esp.b_enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Name Position", "player.local_esp.b_name.i_pos", {"Left", "Top", "Right", "Bottom"}, 2, function()
                    return RoachHook.Config["player.local_esp.b_enable"] && RoachHook.Config["player.local_esp.b_name"]
                end),
                Menu.NewCheckbox("Health Bar", "player.local_esp.b_hp_bar", false, function()
                    return RoachHook.Config["player.local_esp.b_enable"]
                end, true, true, Color(0, 255, 0)),
                Menu.NewCombo("Health Bar Position", "player.local_esp.b_hp_bar.i_pos", {"Left", "Top", "Right", "Bottom"}, 1, function()
                    return RoachHook.Config["player.local_esp.b_enable"] && RoachHook.Config["player.local_esp.b_hp_bar"]
                end),
                Menu.NewCheckbox("Armor Bar", "player.local_esp.b_ap_bar", false, function()
                    return RoachHook.Config["player.local_esp.b_enable"]
                end, true, true, Color(225, 225, 225)),
                Menu.NewCombo("Armor Bar Position", "player.local_esp.b_ap_bar.i_pos", {"Left", "Top", "Right", "Bottom"}, 3, function()
                    return RoachHook.Config["player.local_esp.b_enable"] && RoachHook.Config["player.local_esp.b_ap_bar"]
                end),
                Menu.NewCheckbox("Ammo Bar", "player.local_esp.b_ammo_bar", false, function()
                    return RoachHook.Config["player.local_esp.b_enable"]
                end, true, true, Color(0, 128, 255)),
                Menu.NewCombo("Armor Bar Position", "player.local_esp.b_ammo_bar.i_pos", {"Left", "Top", "Right", "Bottom"}, 4, function()
                    return RoachHook.Config["player.local_esp.b_enable"] && RoachHook.Config["player.local_esp.b_ammo_bar"]
                end),
                Menu.NewCheckbox("Flags", "player.local_esp.b_flags", false, function()
                    return RoachHook.Config["player.local_esp.b_enable"]
                end),
                Menu.NewMultiCombo("Flags", "player.local_esp.b_flags.selected_flags", {
                    "Usergroup",
                    "Ping",
                    "SteamID",
                }, {}, function()
                    return RoachHook.Config["player.local_esp.b_enable"] && RoachHook.Config["player.local_esp.b_flags"]
                end, nil, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Flags Position", "player.local_esp.b_flags.i_pos", {"Left", "Top", "Right", "Bottom"}, 4, function()
                    return RoachHook.Config["player.local_esp.b_enable"] && RoachHook.Config["player.local_esp.b_flags"]
                end),
            }
        },
        {
            name = "Local Chams",
            items = {
                Menu.NewCheckbox("Local Chams", "player.local_chams.b_enable", false, nil, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Local Chams Material", "player.local_chams.b_enable.mat", materials, 1, function()
                    return RoachHook.Config["player.local_chams.b_enable"]
                end),
                Menu.NewCheckbox("Local Chams Overlay", "player.local_chams.b_enable.b_overlay", false, function()
                    return RoachHook.Config["player.local_chams.b_enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Local Chams Material Overlay", "player.local_chams.b_enable.b_overlay.mat", materials_overlay, 1, function()
                    return RoachHook.Config["player.local_chams.b_enable"] && RoachHook.Config["player.local_chams.b_enable.b_overlay"]
                end),
                
                Menu.NewCheckbox("Fake Chams", "player.local_chams.b_fake", false, function()
                    return RoachHook.Config["player.local_chams.b_enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Fake Chams Material", "player.local_chams.b_fake.mat", materials, 1, function()
                    return RoachHook.Config["player.local_chams.b_enable"] && RoachHook.Config["player.local_chams.b_fake"]
                end),
                Menu.NewCheckbox("Fake Chams Overlay", "player.local_chams.b_fake.b_overlay", false, function()
                    return RoachHook.Config["player.local_chams.b_enable"] && RoachHook.Config["player.local_chams.b_fake"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Fake Chams Material Overlay", "player.local_chams.b_fake.b_overlay.mat", materials_overlay, 1, function()
                    return RoachHook.Config["player.local_chams.b_enable"] && RoachHook.Config["player.local_chams.b_fake"] && RoachHook.Config["player.local_chams.b_fake.b_overlay"]
                end),
            }
        },
        {
            name = "Team ESP",
            customH = 630,
            items = {
                Menu.NewCheckbox("Enable ESP", "player.team_esp.b_enable", false),
                Menu.NewCheckbox("Bounding Box", "player.team_esp.b_bbox", false, function()
                    return RoachHook.Config["player.team_esp.b_enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCheckbox("Bounding Box Outline", "player.team_esp.b_bbox.outline", false, function()
                    return RoachHook.Config["player.team_esp.b_enable"] && RoachHook.Config["player.team_esp.b_bbox"]
                end, true, true, Color(0, 0, 0)),
                Menu.NewCheckbox("Name", "player.team_esp.b_name", false, function()
                    return RoachHook.Config["player.team_esp.b_enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Name Position", "player.team_esp.b_name.i_pos", {"Left", "Top", "Right", "Bottom"}, 2, function()
                    return RoachHook.Config["player.team_esp.b_enable"] && RoachHook.Config["player.team_esp.b_name"]
                end),
                Menu.NewCheckbox("Health Bar", "player.team_esp.b_hp_bar", false, function()
                    return RoachHook.Config["player.team_esp.b_enable"]
                end, true, true, Color(0, 255, 0)),
                Menu.NewCombo("Health Bar Position", "player.team_esp.b_hp_bar.i_pos", {"Left", "Top", "Right", "Bottom"}, 1, function()
                    return RoachHook.Config["player.team_esp.b_enable"] && RoachHook.Config["player.team_esp.b_hp_bar"]
                end),
                Menu.NewCheckbox("Armor Bar", "player.team_esp.b_ap_bar", false, function()
                    return RoachHook.Config["player.team_esp.b_enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Armor Bar Position", "player.team_esp.b_ap_bar.i_pos", {"Left", "Top", "Right", "Bottom"}, 3, function()
                    return RoachHook.Config["player.team_esp.b_enable"] && RoachHook.Config["player.team_esp.b_ap_bar"]
                end),
                Menu.NewCheckbox("Ammo Bar", "player.team_esp.b_ammo_bar", false, function()
                    return RoachHook.Config["player.team_esp.b_enable"]
                end, true, true, Color(0, 128, 255)),
                Menu.NewCombo("Armor Bar Position", "player.team_esp.b_ammo_bar.i_pos", {"Left", "Top", "Right", "Bottom"}, 4, function()
                    return RoachHook.Config["player.team_esp.b_enable"] && RoachHook.Config["player.team_esp.b_ammo_bar"]
                end),
                Menu.NewCheckbox("Flags", "player.team_esp.b_flags", false, function()
                    return RoachHook.Config["player.team_esp.b_enable"]
                end),
                Menu.NewMultiCombo("Flags", "player.team_esp.b_flags.selected_flags", {
                    "Usergroup",
                    "Ping",
                    "SteamID",
                    "Traitor Finder",
                }, {}, function()
                    return RoachHook.Config["player.team_esp.b_enable"] && RoachHook.Config["player.team_esp.b_flags"]
                end, nil, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Flags Position", "player.team_esp.b_flags.i_pos", {"Left", "Top", "Right", "Bottom"}, 4, function()
                    return RoachHook.Config["player.team_esp.b_enable"] && RoachHook.Config["player.team_esp.b_flags"]
                end),
            }
        },
        {
            name = "Team Chams",
            items = {
                Menu.NewCheckbox("Enable Team Chams", "player.team.chams.enable", false),
                Menu.NewCheckbox("Visible Chams", "player.team.chams.visible_chams", false, function()
                    return RoachHook.Config["player.team.chams.enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Visible Material", "player.team.chams.visible_chams.mat", materials, 1, function()
                    return RoachHook.Config["player.team.chams.enable"] && RoachHook.Config["player.team.chams.visible_chams"]
                end),
                Menu.NewCheckbox("Visible Overlay Chams", "player.team.chams.visible_overlay", false, function()
                    return RoachHook.Config["player.team.chams.enable"] && RoachHook.Config["player.team.chams.visible_chams"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Visible Overlay Material", "player.team.chams.visible_overlay.mat", materials_overlay, 1, function()
                    return RoachHook.Config["player.team.chams.enable"] && RoachHook.Config["player.team.chams.visible_overlay"]
                end),
                Menu.NewCheckbox("Invisible Chams", "player.team.chams.invisible_chams", false, function()
                    return RoachHook.Config["player.team.chams.enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Invisible Material", "player.team.chams.invisible_chams.mat", materials, 1, function()
                    return RoachHook.Config["player.team.chams.enable"] && RoachHook.Config["player.team.chams.invisible_chams"]
                end),
                Menu.NewCheckbox("Invisible Overlay Chams", "player.team.chams.invisible_overlay", false, function()
                    return RoachHook.Config["player.team.chams.enable"] && RoachHook.Config["player.team.chams.invisible_chams"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Invisible Overlay Material", "player.team.chams.invisible_overlay.mat", materials_overlay, 1, function()
                    return RoachHook.Config["player.team.chams.enable"] && RoachHook.Config["player.team.chams.invisible_overlay"]
                end),
            }
        },
        {
            name = "Enemy ESP",
            customH = 600,
            items = {
                Menu.NewCheckbox("Enable ESP", "player.enemy_esp.b_enable", false),
                Menu.NewCheckbox("Bounding Box", "player.enemy_esp.b_bbox", false, function()
                    return RoachHook.Config["player.enemy_esp.b_enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCheckbox("Bounding Box Outline", "player.enemy_esp.b_bbox.outline", false, function()
                    return RoachHook.Config["player.enemy_esp.b_enable"] && RoachHook.Config["player.enemy_esp.b_bbox"]
                end, true, true, Color(0, 0, 0)),
                Menu.NewCheckbox("Name", "player.enemy_esp.b_name", false, function()
                    return RoachHook.Config["player.enemy_esp.b_enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Name Position", "player.enemy_esp.b_name.i_pos", {"Left", "Top", "Right", "Bottom"}, 2, function()
                    return RoachHook.Config["player.enemy_esp.b_enable"] && RoachHook.Config["player.enemy_esp.b_name"]
                end),
                Menu.NewCheckbox("Health Bar", "player.enemy_esp.b_hp_bar", false, function()
                    return RoachHook.Config["player.enemy_esp.b_enable"]
                end, true, true, Color(0, 255, 0)),
                Menu.NewCombo("Health Bar Position", "player.enemy_esp.b_hp_bar.i_pos", {"Left", "Top", "Right", "Bottom"}, 1, function()
                    return RoachHook.Config["player.enemy_esp.b_enable"] && RoachHook.Config["player.enemy_esp.b_hp_bar"]
                end),
                Menu.NewCheckbox("Armor Bar", "player.enemy_esp.b_ap_bar", false, function()
                    return RoachHook.Config["player.enemy_esp.b_enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Armor Bar Position", "player.enemy_esp.b_ap_bar.i_pos", {"Left", "Top", "Right", "Bottom"}, 3, function()
                    return RoachHook.Config["player.enemy_esp.b_enable"] && RoachHook.Config["player.enemy_esp.b_ap_bar"]
                end),
                Menu.NewCheckbox("Ammo Bar", "player.enemy_esp.b_ammo_bar", false, function()
                    return RoachHook.Config["player.enemy_esp.b_enable"]
                end, true, true, Color(0, 128, 255)),
                Menu.NewCombo("Armor Bar Position", "player.enemy_esp.b_ammo_bar.i_pos", {"Left", "Top", "Right", "Bottom"}, 4, function()
                    return RoachHook.Config["player.enemy_esp.b_enable"] && RoachHook.Config["player.enemy_esp.b_ammo_bar"]
                end),
                Menu.NewCheckbox("Flags", "player.enemy_esp.b_flags", false, function()
                    return RoachHook.Config["player.enemy_esp.b_enable"]
                end),
                Menu.NewMultiCombo("Flags", "player.enemy_esp.b_flags.selected_flags", {
                    "Usergroup",
                    "Ping",
                    "SteamID",
                    "Traitor Finder",
                }, {}, function()
                    return RoachHook.Config["player.enemy_esp.b_enable"] && RoachHook.Config["player.enemy_esp.b_flags"]
                end, nil, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Flags Position", "player.enemy_esp.b_flags.i_pos", {"Left", "Top", "Right", "Bottom"}, 4, function()
                    return RoachHook.Config["player.enemy_esp.b_enable"] && RoachHook.Config["player.enemy_esp.b_flags"]
                end),
            }
        },
        {
            name = "Enemy Chams",
            items = {
                Menu.NewCheckbox("Enable Enemy Chams", "player.enemy.chams.enable", false),
                Menu.NewCheckbox("Visible Chams", "player.enemy.chams.visible_chams", false, function()
                    return RoachHook.Config["player.enemy.chams.enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Visible Material", "player.enemy.chams.visible_chams.mat", materials, 1, function()
                    return RoachHook.Config["player.enemy.chams.enable"] && RoachHook.Config["player.enemy.chams.visible_chams"]
                end),
                Menu.NewCheckbox("Visible Overlay Chams", "player.enemy.chams.visible_overlay", false, function()
                    return RoachHook.Config["player.enemy.chams.enable"] && RoachHook.Config["player.enemy.chams.visible_chams"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Visible Overlay Material", "player.enemy.chams.visible_overlay.mat", materials_overlay, 1, function()
                    return RoachHook.Config["player.enemy.chams.enable"] && RoachHook.Config["player.enemy.chams.visible_overlay"]
                end),
                Menu.NewCheckbox("Invisible Chams", "player.enemy.chams.invisible_chams", false, function()
                    return RoachHook.Config["player.enemy.chams.enable"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Invisible Material", "player.enemy.chams.invisible_chams.mat", materials, 1, function()
                    return RoachHook.Config["player.enemy.chams.enable"] && RoachHook.Config["player.enemy.chams.invisible_chams"]
                end),
                Menu.NewCheckbox("Invisible Overlay Chams", "player.enemy.chams.invisible_overlay", false, function()
                    return RoachHook.Config["player.enemy.chams.enable"] && RoachHook.Config["player.enemy.chams.invisible_chams"]
                end, true, true, Color(255, 255, 255)),
                Menu.NewCombo("Invisible Overlay Material", "player.enemy.chams.invisible_overlay.mat", materials_overlay, 1, function()
                    return RoachHook.Config["player.enemy.chams.enable"] && RoachHook.Config["player.enemy.chams.invisible_overlay"]
                end),
            }
        },
    } },
    {"Misc",        RoachHook.Detour.Material("misc.png"), {
        {
            name = "Movement",
            items = {
                Menu.NewCheckbox("Bunnyhop", "misc.b_bhop", false),
                Menu.NewCheckbox("Autostrafer", "misc.b_autostrafer", false),
                Menu.NewCombo("Autostrafer Type", "misc.b_autostrafer.type", {"Legit", "Directional", "Rage"}, 1, function()
                    return RoachHook.Config["misc.b_autostrafer"]
                end),
                Menu.NewCheckbox("Circle Strafer", "misc.b_c_strafe", false, nil, nil, nil, nil, true, 0, "hold"),
            }
        },
        {
            name = "Fun",
            items = {
                Menu.NewCheckbox("Money Aimbot", "misc.fun.b_money_aimbot", false, nil, nil, nil, nil, true, nil, "hold"),
                Menu.NewCheckbox("Money Aimbot Silent", "misc.fun.b_money_aimbot.b_silent", false, function()
                    return RoachHook.Config["misc.fun.b_money_aimbot"]
                end),
                Menu.NewCheckbox("Money Aimbot Auto Pickup", "misc.fun.b_money_aimbot.b_auto_pickup", false, function()
                    return RoachHook.Config["misc.fun.b_money_aimbot"]
                end),
                Menu.NewSliderInt("Money Aimbot FOV", "misc.fun.b_money_aimbot.i_fov", 0, 0, 180, "%d°", function()
                    return RoachHook.Config["misc.fun.b_money_aimbot"]
                end),
                Menu.NewSliderInt("Minimum Money Amount", "misc.fun.b_money_aimbot.i_min_dolars", 0, 0, 1000, "$%d", function()
                    return RoachHook.Config["misc.fun.b_money_aimbot"]
                end),

                Menu.NewCheckbox("[ DarkRP ] Force taunt", "misc.fun.b_force_taunt", false, function()
                    return cvar_gamemode:GetString() == "darkrp"
                end),
                Menu.NewCombo("[ DarkRP ] Taunt", "misc.fun.b_force_taunt.i_taunt", {
                    "Bow",
                    "Muscle",
                    "Becon",
                    "Laugh",
                    "Lion pose",
                    "No",
                    "Thumbs up",
                    "Wave",
                    "Dance",
                }, 1, function()
                    return RoachHook.Config["misc.fun.b_force_taunt"] && cvar_gamemode:GetString() == "darkrp"
                end),
                Menu.NewSliderFloat("[ DarkRP ] Taunt Refresh", "misc.fun.b_force_taunt.fl_refresh_time", 1.0, math.Clamp(engine.TickInterval() * 6, 0.1, 10.0), 10.0, "%0.2fs", 2, function()
                    return RoachHook.Config["misc.fun.b_force_taunt"] && cvar_gamemode:GetString() == "darkrp"
                end),
            }
        },
        {
            name = "Clientside",
            items = {
                Menu.NewCheckbox("Taunt (Clientsided)", "misc.b_taunt", false),
                Menu.NewCombo("Taunt", "misc.b_taunt.i_selected", {
                    "Salute",
                    "Persistence",
                    "Muscle",
                    "Laugh",
                    "Cheer",
                    "Dance",
                    "Robot",
                    "Death",
                    "Swim",
                }, 1, function()
                    return RoachHook.Config["misc.b_taunt"]
                end),
            }
        },
        {
            name = "Player List",
            items = {
                Menu.NewListbox("misc.i_selected_player", GetPlayerNames(), 1, nil, 250),
                Menu.NewCheckbox("Ignore", "misc.b_ignore", false, function()
                    return RoachHook.Config["misc.i_selected_player"] != nil && #GetPlayerNames() > 0
                end),
                Menu.NewCheckbox("Resolver", "misc.b_resolve", true, function()
                    return RoachHook.Config["misc.i_selected_player"] != nil && #GetPlayerNames() > 0
                end),
                Menu.NewCombo("Resolve Pitch", "misc.b_resolve.i_pitch", {
                    "Disabled",
                    "Up",
                    "Zero",
                    "Down",
                }, 1, function()
                    return RoachHook.Config["misc.i_selected_player"] != nil && #GetPlayerNames() > 0 && RoachHook.Config["misc.b_resolve." .. RoachHook.Config["misc.i_selected_player"]]
                end),
                Menu.NewCombo("Resolve Yaw", "misc.b_resolve.i_yaw", {
                    "Disabled",
                    "Right",
                    "Left",
                    "Backwards",
                    "Forward",
                    "Auto",
                }, 1, function()
                    return RoachHook.Config["misc.i_selected_player"] != nil && #GetPlayerNames() > 0 && RoachHook.Config["misc.b_resolve." .. RoachHook.Config["misc.i_selected_player"]]
                end),
            },
        },
        {
            name = "Other",
            customH = 480,
            items = {
                Menu.NewCheckbox("Override Menu Color", "misc.b_override_color", false, nil, true, false, Color(0, 0, 255)),
                Menu.NewCheckbox("Override Menu Key", "misc.b_override_key", false, nil, false, false, nil, true, KEY_INSERT, "toggle"),
                //Menu.NewCheckbox("OBS/Screengrab Proof", "misc.b_obs_proof", false),
                //Menu.NewCheckbox("Hide obs visible features while OBS/Screengrab Proof is enabled", "misc.b_obs_proof.b_auto_hide", false, function()
                //    return RoachHook.Config["misc.b_obs_proof"]
                //end),
                Menu.NewCheckbox("Hide visuals while Alt-Tabbed", "misc.b_alt_tab_hide_visuals", false),
                
                Menu.NewCombo("DPI Scale", "misc.i_selected_dpi_scale", {
                    "Automatic",
                    "50%",
                    "75%",
                    "100%",
                    "125%",
                    "150%",
                    "200%",
                    "Custom",
                }, 5),
                Menu.NewSliderInt("DPI Scale", "misc.i_selected_dpi_scale.custom", 125, 50, 500, "%d%%", function()
                    return RoachHook.Config["misc.i_selected_dpi_scale"] == 8
                end),

                Menu.NewCheckbox("Bypass command checks", "misc.b_cmd_checks_bypass", false),
                Menu.NewMultiCombo("Commands", "misc.cmd_check_bypass", commands, {}, function()
                    return RoachHook.Config["misc.b_cmd_checks_bypass"]
                end),

                Menu.NewButton("Dump Network Strings", function()
                    RoachHook.UpdateIgnoredEntities()
                    PrintTable(RoachHook.DumpNet())
                    local json = util.TableToJSON(RoachHook.DumpNet(), true)
                    local name = string.lower(string.format("roachhook/net_logger/%s_%s", game.GetIPAddress(), os.date("%Y %m %d %H %M %S")))
                    local name = name:Replace(" ", "_")
                    local name = name:Replace(".", "_")
                    local name = name:Replace(":", "-")
                    local name = name .. ".json"
                    file.Write(name, json)
                    MsgC(RoachHook.GetMenuTheme(), "[RoachHook v2] ", Color(255, 255, 255), "Saved dump as: ", name, "\n")
                end)
            }
        },
    } },
    {"Config",      RoachHook.Detour.Material("config.png"), {
        {
            name = "Configs",
            items = {
                Menu.NewTextbox("Config Name", "config.szName", "", nil, 128, "qwertyuiopasdfghjklzxcvbnm.1234567890"),
                Menu.NewButton("Create", function()
                    if(#configs >= 12) then
                        MsgC(RoachHook.GetMenuTheme(), "[RoachHook v2] ", Color(255, 255, 255), "Sorry but there are too many configs.", Color(255, 0, 0), " [ MAX 12 ]", "\n")

                        return
                    end

                    local configWishName = RoachHook.Config["config.szName"]
                    if(configWishName == "") then return end
                    local addToName = ""
                    if(!string.EndsWith(configWishName, ".txt")) then addToName = ".txt" end

                    local name = "roachhook/config/" .. configWishName .. addToName
                    local compressed = RoachHook.ConfigSystem:CompressConfig(util.TableToJSON(RoachHook.Config, true))

                    file.Write(name, compressed)
                    
                    MsgC(RoachHook.GetMenuTheme(), "[RoachHook v2] ", Color(255, 255, 255), "Created config file: ", configWishName .. addToName, "\n")
                end),
                Menu.NewListbox("config.i_selected_config", configs, 1, nil, 250, true, configData),
                Menu.NewTextbox("Rename Config", "config.szName_Rename", "", nil, 128, "qwertyuiopasdfghjklzxcvbnm.1234567890"),
                Menu.NewButton("Load", function()
                    local cfg = configs[RoachHook.Config["config.i_selected_config"]]
                    if(!cfg) then return end

                    local name = "roachhook/config/" .. cfg
                    file.AsyncRead(name, "DATA", function(name, path, status, content)
                        local config = RoachHook.Detour.util.JSONToTable(RoachHook.ConfigSystem:DecompressConfig(content))
                        
                        config["config.szName"] = RoachHook.Config["config.szName"]
                        config["config.szName_Rename"] = RoachHook.Config["config.szName_Rename"]
                        config["config.i_selected_config"] = RoachHook.Config["config.i_selected_config"]
                        config["madeby"] = RoachHook.Config["modeby"]
                        config["cheatver"] = RoachHook.Config["cheatver"]
                        
                        for k,v in pairs(config) do
                            if(string.StartWith(k, "misc.i_selected_player")) then
                                config[k] = RoachHook.Config[k]
                            end
                        end
    
                        RoachHook.Config = config
                        
                        RoachHook.Detour.MsgC(RoachHook.GetMenuTheme(), "[RoachHook v2] ", Color(255, 255, 255), "Loaded config file: ", cfg, "\n")
                    end)
                end, nil, {
                    x = 0,
                    y = nil,
                    w = cfgbw,
                    h = nil,
                    dontAddY = true,
                }),
                Menu.NewButton("Save", function()
                    local cfg = configs[RoachHook.Config["config.i_selected_config"]]
                    if(!cfg) then return end
                    
                    local curCfg = RoachHook.Config

                    local name = "roachhook/config/" .. cfg
                    local compressed = RoachHook.ConfigSystem:CompressConfig(util.TableToJSON(curCfg, true))

                    RoachHook.Detour.file.Write(name, compressed)

                    RoachHook.Detour.MsgC(RoachHook.GetMenuTheme(), "[RoachHook v2] ", Color(255, 255, 255), "Saved config file: ", cfg, "\n")
                end, nil, {
                    x = (cfgbw * 1) + cfgsx(1),
                    y = nil,
                    w = cfgbw,
                    h = nil,
                    dontAddY = true,
                }),
                Menu.NewButton("Remove", function()
                    local cfg = configs[RoachHook.Config["config.i_selected_config"]]
                    if(!cfg) then return end

                    RoachHook.Config["config.i_selected_config"] = math.Clamp(RoachHook.Config["config.i_selected_config"] - 1, 1, #configs)
                    if(#configs <= 0) then RoachHook.Config["config.i_selected_config"] = nil end

                    local name = "roachhook/config/" .. cfg
                    file.Delete(name)
                    MsgC(RoachHook.GetMenuTheme(), "[RoachHook v2] ", Color(255, 255, 255), "Removed config file: ", cfg, "\n")
                end, nil, {
                    x = (cfgbw * 2) + cfgsx(2),
                    y = nil,
                    w = cfgbw,
                    h = nil,
                    dontAddY = true,
                }),
                Menu.NewButton("Rename", function()
                    local cfg = configs[RoachHook.Config["config.i_selected_config"]]
                    if(!cfg) then return end
                    local newName = RoachHook.Config["config.szName_Rename"]
                    if(newName == "") then return end
                    local addToName = ""
                    if(!string.EndsWith(newName, ".txt")) then addToName = ".txt" end

                    local from = "roachhook/config/" .. cfg
                    local to = "roachhook/config/" .. newName .. addToName
                    
                    file.Rename(from, to)
                    MsgC(RoachHook.GetMenuTheme(), "[RoachHook v2] ", Color(255, 255, 255), "Renamed config file: ", cfg, ", to: ", newName, "\n")
                end, nil, {
                    x = (cfgbw * 3) + cfgsx(3),
                    y = nil,
                    w = cfgbw,
                    h = nil,
                    dontAddY = true,
                }),
                Menu.NewButton("Load Default", function()
                    RoachHook.Config = {}
                    MsgC(RoachHook.GetMenuTheme(), "[RoachHook v2] ", Color(255, 255, 255), "Loaded default config file", "\n")
                end, nil, {
                    x = (cfgbw * 4) + cfgsx(4),
                    y = nil,
                    w = cfgbw,
                    h = nil,
                    dontAddY = true,
                }),
            },
        },
        {
            name = "Lua Loader",
            items = {
                Menu.NewListbox("lua_loader.i_selected_lua", scripts, 1, nil, 364),
                Menu.NewButton("Execute", function()
                    local script = scripts[RoachHook.Config["lua_loader.i_selected_lua"]]
                    if(!script) then return end

                    local scriptFile = file.Read("roachhook/scripts/" .. script)

                    local err = RunString(scriptFile, "RoachHookRunString", false)
                    if(err) then
                        MsgC(RoachHook.GetMenuTheme(), "[RoachHook v2] [LUA ERROR]", Color(255, 0, 0), err)
                    else
                        MsgC(RoachHook.GetMenuTheme(), "[RoachHook v2] ", Color(255, 255, 255), "Loaded LUA script: ", script, "\n")
                    end
                end, nil, {
                    x = nil,
                    y = nil,
                    w = nil,
                    h = nil,
                })
            }
        }
    } },
})

local defVars = {
    ["Ignore"] = "misc.b_ignore",
    ["Resolver"] = "misc.b_resolve",
    ["Resolve Pitch"] = "misc.b_resolve.i_pitch",
    ["Resolve Yaw"] = "misc.b_resolve.i_yaw",
}
RoachHook.Detour.hook.Add("Think", "UpdatePlayerListVars", function()
    if(!RoachHook.Config["misc.i_selected_player"]) then return end
    local items = RoachHook.frame.Tabs[5][3][7].items
    for k,v in pairs(items) do
        if(defVars[v.name]) then
            RoachHook.frame.Tabs[5][3][7].items[k].var = defVars[v.name] .. "." .. RoachHook.Config["misc.i_selected_player"]
        end
    end
end)

RoachHook.ActiveFrame = RoachHook.frame

local function UpdateConfigs(files)
    configs = {}
    for f=1, math.min(#files, 12) do
        local File = files[f]

        configs[f] = File
        if(!configData[f]) then
            local name = "roachhook/config/" .. File
            local content = file.Read(name, "DATA")
            local config = util.JSONToTable(RoachHook.ConfigSystem:DecompressConfig(content))

            configData[f] = {
                owner = config["madeby"],
                ver = config["cheatver"],
            }
        end
    end

    local listbox = RoachHook.Helpers.GetMenuItemFromVar("config.i_selected_config")
    if(!listbox) then return end

    listbox.Items = configs
end
local function UdpateScripts(files)
    scripts = {}
    for f=1, #files do
        local File = files[f]

        scripts[f] = File
    end

    local listbox = RoachHook.Helpers.GetMenuItemFromVar("lua_loader.i_selected_lua")
    if(!listbox) then return end

    listbox.Items = scripts
end

local function UpdatePlayerList()
    local plrs = GetPlayerNames()
    local listbox = RoachHook.Helpers.GetMenuItemFromVar("misc.i_selected_player")
    if(!listbox) then return end

    listbox.Items = plrs
end

RoachHook.Detour.hook.Add("Think", "UpdateConfigs", function()
    local files, dirs = RoachHook.Detour.file.Find("roachhook/config/*.txt", "DATA", "dateasc")
    UpdateConfigs(files)

    local files, dirs = RoachHook.Detour.file.Find("roachhook/scripts/*.lua", "DATA", "dateasc")
    UdpateScripts(files)

    UpdatePlayerList()
end)

RoachHook.PressedVars = {}
RoachHook.Detour.hook.Add("Think", "UpdatePressedKeys", function()
    RoachHook.PressedVars = {}

    for k = 1, #RoachHook.Keybinds do
        RoachHook.PressedVars[RoachHook.Keybinds[k].var] = RoachHook.Helpers.KeybindPressed(RoachHook.Keybinds[k].var)
    end
end)

local cl_interp, cl_updaterate, cl_interp_ratio = GetConVar("cl_interp"), GetConVar("cl_updaterate"), GetConVar("cl_interp_ratio")
RoachHook.Detour.hook.Add("CreateMove", "SilentAimbot", function(cmd)
    if(!LocalPlayer():Alive()) then bSendPacket = true return end
    if(!RoachHook.SilentAimbot) then RoachHook.SilentAimbot = cmd:GetViewAngles() end

    RoachHook.SilentAimbot = RoachHook.SilentAimbot + Angle(cmd:GetMouseY() * GetConVarNumber("m_pitch"), cmd:GetMouseX() * -GetConVarNumber("m_yaw"))
    RoachHook.SilentAimbot.x = math.Clamp(RoachHook.SilentAimbot.x, -89, 89)
    RoachHook.SilentAimbot.y = math.NormalizeAngle(RoachHook.SilentAimbot.y)
    RoachHook.SilentAimbot.z = 0

    if(RoachHook.ActiveItem && RoachHook.ActiveItem._type == "RoachHook.Textbox") then
        cmd:ClearMovement()
        cmd:SetButtons(0)
    end
    
    if(cmd:CommandNumber() == 0) then
        if((RoachHook.Config["misc.camera.b_thirdperson"] && RoachHook.PressedVars["misc.camera.b_thirdperson.key"])) then
            cmd:SetViewAngles(RoachHook.AntiAimData.real)
        else
            cmd:SetViewAngles(RoachHook.SilentAimbot)
        end

        return
    end
    cmd:SetViewAngles(RoachHook.SilentAimbot)

    if(cl_interp:GetInt() != 0) then
        RunConsoleCommand("cl_interp", 0)
    end
    if(cl_updaterate:GetInt() != 128000) then
        RunConsoleCommand("cl_updaterate", 128000)
    end
    if(cl_interp_ratio:GetInt() != 1) then
        RunConsoleCommand("cl_interp_ratio", 1)
    end

    RoachHook.Features.Misc.Bunnyhop(cmd)
    //RoachHook.Features.Misc.FreeCam(cmd)
    
    RoachHook.Modules.Big.StartPrediction(cmd)
    
    RoachHook.Features.Legitbot.Aimbot(cmd)

    RoachHook.Features.Ragebot.Fakelag(cmd)
    RoachHook.Features.Ragebot.AntiAim(cmd)

    RoachHook.Features.Ragebot.Aimbot(cmd)
    RoachHook.Features.Ragebot.FakeDuck(cmd)
    RoachHook.Features.Misc.MoneyAimbot(cmd)
    
    RoachHook.AntiAimData.current = cmd:GetViewAngles()

    if(cmd:KeyDown(IN_ATTACK) && !(RoachHook.Config["fakelag.b_fakeduck"] && RoachHook.PressedVars["fakelag.b_fakeduck.key"])) then
        bSendPacket = true
    end
    
    if(!RoachHook.Config["fakelag.b_enable"]) then
        RoachHook.AntiAimData.real = cmd:GetViewAngles()
        RoachHook.AntiAimData.fake = cmd:GetViewAngles()
        RoachHook.LastSentPos = LocalPlayer():GetPos()
    end

    if(RoachHook.Config["visual.removals"] && RoachHook.Config["visual.removals"][3] && cmd:KeyDown(IN_ATTACK)) then
        
    else
        if(cmd:KeyDown(IN_ATTACK)) then
            RoachHook.AntiAimData.real = cmd:GetViewAngles()
            RoachHook.AntiAimData.fake = cmd:GetViewAngles()
        else
            if(bSendPacket) then
                RoachHook.AntiAimData.fake = cmd:GetViewAngles()
                RoachHook.LastSentPos = LocalPlayer():GetPos()
            else
                RoachHook.AntiAimData.real = cmd:GetViewAngles()
            end
        end
    end

    RoachHook.Modules.Big.FinishPrediction(cmd)

    RoachHook.Features.Misc.Autostrafer(cmd)
    local RawAngles = cmd:GetViewAngles()

    cmd:SetViewAngles(Angle(
        bSecure && math.Clamp(RawAngles.x, -89, 89) || math.NormalizeAngle(RawAngles.x),
        math.NormalizeAngle(RawAngles.y),
        0
    ))

    RoachHook.Helpers.FixMovement(cmd)
    RoachHook.Features.Misc.CircleStrafer(cmd)
end)

local function Drawing()
    for k=1,#RoachHook.OverlayHook do RoachHook.OverlayHook[k]() end

    if(RoachHook.bMenuVisibleLast != RoachHook.bMenuVisible) then
        gui.EnableScreenClicker(RoachHook.bMenuVisible)

        RoachHook.bMenuVisibleLast = RoachHook.bMenuVisible
    end
    
    local key = RoachHook.Config["misc.b_override_key.key"]
    if(RoachHook.Config["misc.b_override_key"] && key && input.GetKeyName(key.key)) then
        RoachHook.bMenuVisible = RoachHook.PressedVars["misc.b_override_key.key"]
    else
        if(input.IsKeyDown(KEY_INSERT) || input.IsKeyDown(KEY_DELETE)) then
            if(!RoachHook.bMenuKeyClicked) then
                RoachHook.bMenuVisible = !RoachHook.bMenuVisible
    
                RoachHook.bMenuKeyClicked = true
            end
        else
            RoachHook.bMenuKeyClicked = false
        end
    end

    for k,v in pairs(RoachHook.DrawBehindMenu) do v() end
    if(RoachHook.bMenuVisible) then
        RoachHook.frame:Draw()
        
        do
            local name = "unknown"
            if(RoachHook.Detour.LocalPlayer() && RoachHook.Detour.LocalPlayer():Name()) then name = RoachHook.Detour.LocalPlayer():Name() end

            local text = RoachHook.Detour.string.format("roachhook v%s | user: %s | date: %s", RoachHook.CheatVer, name, os.date("%d/%m/%Y - %H:%M:%S"))
            surface.SetFont("Menu.UnderText")
            local textW, textH = surface.GetTextSize(text)
            
            local x, y, w, h = RoachHook.frame.x, RoachHook.frame.y + (RoachHook.frame.h * RoachHook.DPIScale), (RoachHook.frame.w * RoachHook.DPIScale), textH + (4 * RoachHook.DPIScale)
            local y = RoachHook.Detour.math.floor(y) - 1
            RoachHook.Detour.draw.RoundedBoxEx(3, x, y, w, h, Color(60, 60, 60), false, false, true, true)
            RoachHook.Detour.draw.RoundedBoxEx(3, x + 1, y + 1, w - 2, h - 2, Color(0, 0, 0, 128), false, false, true, true)
            RoachHook.Detour.draw.RoundedBoxEx(3, x + 2, y + 2, w - 4, h - 4, Color(35, 35, 35), false, false, true, true)

            RoachHook.Detour.draw.SimpleTextOutlined(
                text,
                "Menu.UnderText",
                x + (5 * RoachHook.DPIScale),
                y + h / 2,
                color_white,
                nil,
                TEXT_ALIGN_CENTER,
                1,
                color_black
            )
        end
    end
end

RoachHook.Detour.hook.Add("DrawOverlay", "Roachhook.Menu", function()
    if(!system.HasFocus() && RoachHook.Config["misc.b_alt_tab_hide_visuals"]) then return end
    
    Drawing()
end)