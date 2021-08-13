local Textbox = {}
Textbox.name = "textbox"
Textbox.var = "null"
Textbox.def = ""
Textbox.frame = nil
Textbox.visCheck = function() return true end
Textbox._type = "RoachHook.Textbox"
Textbox.Internal = {
    bIsEditing = false,
    iCurrentSpot = nil,
    iCharAddDelay = nil,
    iCharAddDelayTime = nil,
    iCharSubDelay = nil,
    iCharSubDelayTime = nil,
    lastChar = nil,
}

Textbox.allowedChars = "qwertyuiopasdfghjklzxcvbnm,.1234567890[];'/\\`-=!@#$%^&*()_+{}:\"<>?|"
local keyCombinations = {
    ["!"] = {KEY_LSHIFT, KEY_1},
    ["@"] = {KEY_LSHIFT, KEY_2},
    ["#"] = {KEY_LSHIFT, KEY_3},
    ["$"] = {KEY_LSHIFT, KEY_4},
    ["%"] = {KEY_LSHIFT, KEY_5},
    ["^"] = {KEY_LSHIFT, KEY_6},
    ["&"] = {KEY_LSHIFT, KEY_7},
    ["*"] = {KEY_LSHIFT, KEY_8},
    ["("] = {KEY_LSHIFT, KEY_9},
    [")"] = {KEY_LSHIFT, KEY_0},
    ["{"] = {KEY_LSHIFT, KEY_LBRACKET},
    ["}"] = {KEY_LSHIFT, KEY_RBRACKET},
    ["|"] = {KEY_LSHIFT, KEY_BACKSLASH},
    [":"] = {KEY_LSHIFT, KEY_SEMICOLON},
    ["\""] = {KEY_LSHIFT, KEY_APOSTROPHE},
    ["<"] = {KEY_LSHIFT, KEY_COMMA},
    [">"] = {KEY_LSHIFT, KEY_PERIOD},
    ["_"] = {KEY_LSHIFT, KEY_MINUS},
    ["+"] = {KEY_LSHIFT, KEY_EQUAL},
    ["~"] = {KEY_LSHIFT, KEY_BACKQUOTE},
    ["?"] = {KEY_LSHIFT, KEY_SLASH},
}

local function bIsKeyCombinationPressed(keyCombination)
    if(#keyCombination <= 0) then return false end
    local bPressed = true

    for i = 1, #keyCombination do
        if(!bPressed) then continue end
        if(!input.IsKeyDown(keyCombination[i])) then bPressed = false end
    end

    return bPressed
end

local function EscapeFromString(str)
    return (str:gsub('%%', '%%%%')
             :gsub('^%^', '%%^')
             :gsub('%$$', '%%$')
             :gsub('%(', '%%(')
             :gsub('%)', '%%)')
             :gsub('%.', '%%.')
             :gsub('%[', '%%[')
             :gsub('%]', '%%]')
             :gsub('%*', '%%*')
             :gsub('%+', '%%+')
             :gsub('%-', '%%-')
             :gsub('%?', '%%?'))
end
local function CheckForKeyCombination(self)
    for k, v in pairs(keyCombinations) do
        if(!self.allowedChars:find(EscapeFromString(k))) then continue end

        if(bIsKeyCombinationPressed(v)) then
            return k
        end
    end
end

function Textbox:Draw()
    if(RoachHook.ActiveFrame && !self.frame) then self.frame = RoachHook.ActiveFrame end
    if(RoachHook.Config[self.var] == nil) then RoachHook.Config[self.var] = self.def end
    if(!self.visCheck()) then return end

    local x, y = self.frame.x + (210 * RoachHook.DPIScale), self.frame.y + ((60 + RoachHook.iLineHeight) * RoachHook.DPIScale)
    local w, h = (self.frame.w * RoachHook.DPIScale) - (230 * RoachHook.DPIScale), 20 * RoachHook.DPIScale
    local y = y + self.frame.AddToY + ((self.name == "" || !self.name) && 0 || (15 * RoachHook.DPIScale))

    local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)

    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(RoachHook.ActiveItem == self && !bHovered) then
            self.Internal.bIsEditing = false
            RoachHook.ActiveItem = nil
        elseif(!RoachHook.ActiveItem && bHovered) then
            self.Internal.bIsEditing = true
            RoachHook.ActiveItem = self
        end
    end

    draw.RoundedBox(3, x, y, w, h, Color(45, 45, 45))
    draw.RoundedBox(3, x + 1, y + 1, w - 2, h - 2, Color(35, 35, 35))

    draw.SimpleText(
        self.name,
        "Menu.ButtonText",
        x + (5 * RoachHook.DPIScale),
        y - (10 * RoachHook.DPIScale),
        bHovered && Color(255, 255, 255) || Color(202, 202, 202),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )
    draw.SimpleText(
        RoachHook.Config[self.var],
        "Menu.ButtonText",
        x + (5 + RoachHook.DPIScale),
        y + h / 2,
        bHovered && Color(255, 255, 255) || Color(202, 202, 202),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    if(self.Internal.bIsEditing && RoachHook.ActiveItem == self) then
        surface.SetFont("Menu.ButtonText")
        local textW, textH = surface.GetTextSize(RoachHook.Config[self.var])
        local x = x + (7 + RoachHook.DPIScale) + textW

        draw.RoundedBox(0, x, y + h / 2 - textH / 2, 1, textH, Color(255, 255, 255, 256 - ((CurTime() * 350) % 256)))
    end

    if(self.Internal.bIsEditing && RoachHook.ActiveItem == self) then
        if(!self.Internal.iCurrentSpot) then
            self.Internal.iCurrentSpot = #RoachHook.Config[self.var]
        end

        if(!input.IsKeyDown(KEY_BACKSPACE)) then
            self.Internal.iCharSubDelay = nil
            self.Internal.iCharSubDelayTime = nil
        end

        if(input.IsKeyDown(KEY_BACKSPACE)) then
            local newtext = ""
            for i = 1, #RoachHook.Config[self.var] - 1 do
                newtext = newtext .. RoachHook.Config[self.var][i]
            end

            if(!self.Internal.iCharSubDelay) then
                self.Internal.iCharSubDelay = CurTime() - 0.1
                self.Internal.iCharSubDelayTime = 0.6
                
                RoachHook.Config[self.var] = newtext
            end

            if(self.Internal.iCharSubDelay + self.Internal.iCharSubDelayTime <= CurTime()) then
                RoachHook.Config[self.var] = newtext
                
                self.Internal.iCharSubDelay = CurTime()
                self.Internal.iCharSubDelayTime = 0.05
            end
        elseif(input.IsKeyDown(KEY_ENTER) || input.IsKeyDown(KEY_ESCAPE)) then
            self.Internal.bIsEditing = false
            RoachHook.ActiveItem = nil
        else
            local keys = RoachHook.Helpers.GetKeysPressed()

            if(#keys > 0 && string.len(RoachHook.Config[self.var] || "") < self.maxLength) then
                local szKeyCombination = CheckForKeyCombination(self)
                if(szKeyCombination) then
                    local keyName = szKeyCombination
    
                    if(!self.Internal.iCharAddDelay) then
                        self.Internal.iCharAddDelay = CurTime()
                        self.Internal.iCharAddDelayTime = 0.4

                        if(self.Internal.lastChar != keyName) then
                            self.Internal.iCharAddDelay = CurTime() - 0.05
                        end
    
                        self.Internal.lastChar = keyName

                        RoachHook.Config[self.var] = RoachHook.Config[self.var] .. keyName
    
                        self.Internal.iCharAddDelay = CurTime()
                    end
    
                    if(self.Internal.lastChar != keyName) then
                        self.Internal.iCharAddDelayTime = 0.15
                    end

                    self.Internal.lastChar = keyName
        
                    if(self.Internal.iCharAddDelay + self.Internal.iCharAddDelayTime <= CurTime()) then
                        RoachHook.Config[self.var] = RoachHook.Config[self.var] .. keyName

                        self.Internal.iCharAddDelayTime = 0.15
                        self.Internal.iCharAddDelay = CurTime()
                    end
                else
                    local keyName = string.lower(input.GetKeyName(table.GetFirstValue(keys)))
                    local bIsAllowedChar = self.allowedChars:find(keyName)
    
                    if(bIsAllowedChar || input.IsKeyDown(KEY_SPACE)) then
                        if(!self.Internal.iCharAddDelay) then
                            self.Internal.iCharAddDelay = CurTime()
                            self.Internal.iCharAddDelayTime = 0.4
                            
                            if(self.Internal.lastChar != keyName) then
                                self.Internal.iCharAddDelay = CurTime() - 0.05
                            end
    
                            self.Internal.lastChar = keyName
            
                            if(input.IsKeyDown(KEY_SPACE)) then
                                RoachHook.Config[self.var] = RoachHook.Config[self.var] .. " "
                            else
                                RoachHook.Config[self.var] = RoachHook.Config[self.var] .. (input.IsKeyDown(KEY_LSHIFT) && string.upper(keyName) || string.lower(keyName))
                            end
    
                            self.Internal.iCharAddDelay = CurTime()
                        end
    
                        if(self.Internal.lastChar != keyName) then
                            self.Internal.iCharAddDelayTime = 0.1
                        end
    
                        self.Internal.lastChar = keyName
        
                        if(self.Internal.iCharAddDelay + self.Internal.iCharAddDelayTime <= CurTime()) then
                            if(input.IsKeyDown(KEY_SPACE)) then
                                RoachHook.Config[self.var] = RoachHook.Config[self.var] .. " "
                            else
                                RoachHook.Config[self.var] = RoachHook.Config[self.var] .. (input.IsKeyDown(KEY_LSHIFT) && string.upper(keyName) || string.lower(keyName))
                            end
    
                            self.Internal.iCharAddDelayTime = 0.1
                            self.Internal.iCharAddDelay = CurTime()
                        end
                    end
                end
            else
                self.Internal.iCharAddDelay = nil
            end
        end
    end

    self.frame.AddToY = self.frame.AddToY + h + ((((self.name == "" || !self.name) && 0 || 15) + 7) * RoachHook.DPIScale)
end

Menu.NewTextbox = function(name, cfgVar, def, visCheck, maxLength, allowedChars)
    local textbox = table.Copy(Textbox)
    textbox.name = name
    textbox.var = cfgVar
    textbox.def = def
    textbox.visCheck = visCheck || textbox.visCheck
    textbox.allowedChars = allowedChars || textbox.allowedChars
    textbox.maxLength = maxLength || 256

    return textbox
end