o_GetConVar = o_GetConVar || GetConVar
o_GetConVar_Internal = o_GetConVar_Internal || GetConVar_Internal
local CVar = FindMetaTable("ConVar")

local commands = {
    "sv_cheats",
    "sv_allowcslua",
}
local commands_def = {
    ["sv_cheats"] = 0,
    ["sv_allowcslua"] = 0
}

function GetConVar_Internal(name)
    return o_GetConVar_Internal(name)
end
function GetConVar(name)
    return o_GetConVar(name)
end
o_GetBool = o_GetBool || CVar.GetBool
o_GetFloat = o_GetFloat || CVar.GetFloat
o_GetInt = o_GetInt || CVar.GetInt
o_GetString = o_GetString || CVar.GetString

local function ShouldBypassConcommand(name)
    local cmds = RoachHook.Config["misc.cmd_check_bypass"]
    if(!cmds) then return false end

    for k,v in pairs(cmds) do
        if(!v) then continue end

        if(commands[k] == name) then return true end
    end

    return false
end

function CVar:GetBool()
    if(ShouldBypassConcommand(self:GetName())) then
        print("Bypased: " .. self:GetName())

        return commands_def[self:GetName()]
    end

    return o_GetBool(self)
end
function CVar:GetFloat()
    if(ShouldBypassConcommand(self:GetName())) then
        print("Bypased: " .. self:GetName())
        
        return commands_def[self:GetName()]
    end

    return o_GetFloat(self)
end
function CVar:GetInt()
    if(ShouldBypassConcommand(self:GetName())) then
        print("Bypased: " .. self:GetName())
        
        return commands_def[self:GetName()]
    end
    
    return o_GetInt(self)
end
function CVar:GetString()
    if(ShouldBypassConcommand(self:GetName())) then
        print("Bypased: " .. self:GetName())
        
        return commands_def[self:GetName()]
    end
    
    return o_GetString(self)
end