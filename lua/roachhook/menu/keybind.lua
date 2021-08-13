local KeyBinder = {}
KeyBinder.def = {
    key = nil,
    mode = "hold"
}
KeyBinder.var = "null"
KeyBinder.frame = nil
KeyBinder.x = nil
KeyBinder.y = nil
KeyBinder.iSubX = 0
KeyBinder.Internal = {
    bCanGrab = true,
    bIsGrabbing = false,
    
    bCanChange = true,

    iSavedW = nil
}
KeyBinder._type = "RoachHook.KeyBinder"

function KeyBinder:Draw()
    if(RoachHook.Config[self.var] == nil) then RoachHook.Config[self.var] = self.def end
    if(RoachHook.ActiveFrame && !self.frame) then self.frame = RoachHook.ActiveFrame end

    local key = RoachHook.Config[self.var]
    local keyName = self.Internal.bIsGrabbing && "..." || (key.key == nil && "none" || (input.GetKeyName(key.key) || "none"))

    surface.SetFont("Menu.ButtonText")
    local keyW, keyH = surface.GetTextSize(keyName)

    local x, y, w, h = self.frame.x + (self.frame.w * RoachHook.DPIScale) - (20 * RoachHook.DPIScale) - (self.iSubX * RoachHook.DPIScale) - (keyW + (10 * RoachHook.DPIScale)), self.frame.y + (60 * RoachHook.DPIScale) + self.frame.AddToY
    local w, h = keyW + (10 * RoachHook.DPIScale), 15 * RoachHook.DPIScale
    local bHovered = RoachHook.Helpers.MouseInBox((x + w) - (self.Internal.iSavedW || w), y, self.Internal.iSavedW || w, h)

    if(RoachHook.ActiveItem) then
        self.Internal.bCanGrab = false
    end

    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(!bHovered && self.Internal.bCanGrab) then
            self.Internal.bCanGrab = false
        elseif(bHovered && self.Internal.bCanGrab) then
            self.Internal.bIsGrabbing = true
            self.Internal.bCanGrab = false
        end
    else
        self.Internal.bCanGrab = true
    end

    if(!self.Internal.bIsGrabbing) then
        if(input.IsMouseDown(MOUSE_RIGHT)) then
            if(!bHovered && self.Internal.bCanChange) then
                self.Internal.bCanChange = false
            elseif(bHovered && self.Internal.bCanChange) then
                if(RoachHook.ActiveItem == nil) then
                    RoachHook.ActiveItem = self
                    
                    self.x = (x + w) - (60 * RoachHook.DPIScale)
                    self.y = y + h + (5 * RoachHook.DPIScale)
                elseif(RoachHook.ActiveItem == self) then
                    RoachHook.ActiveItem = nil
                end

                self.Internal.bCanChange = false
            end
        else
            self.Internal.bCanChange = true
        end
    end

    if(RoachHook.ActiveItem == self) then
        local modes = {"Always on", "Toggle", "Hold"}

        self.frame.DrawAbove[#self.frame.DrawAbove + 1] = function()
            local x, y, w, h = self.x, self.y, 60 * RoachHook.DPIScale, ((#modes * 20) + 4) * RoachHook.DPIScale

            local bHoveredMenu = RoachHook.Helpers.MouseInBox(x, y, w, h)
            if(input.IsMouseDown(MOUSE_LEFT) && !bHoveredMenu && !bHovered) then
                RoachHook.ActiveItem = nil
            end
            
            draw.RoundedBox(3, x, y, w, h, Color(0, 0, 0, 128))
            draw.RoundedBox(3, x + 1, y + 1, w - 2, h - 2, Color(60, 60, 60))
            draw.RoundedBox(3, x + 2, y + 2, w - 4, h - 4, Color(35, 35, 35))

            for k,v in pairs(modes) do
                local x, y, w, h = x + 2, math.floor(y + 2 + (22 * (k - 1))), w - 4, 20 * RoachHook.DPIScale
                
                local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)
                if(bHovered) then
                    if(k == 1) then
                        draw.RoundedBoxEx(3, x, y, w, h, Color(45, 45, 45), true, true)
                    elseif(k == #modes) then
                        draw.RoundedBoxEx(3, x, y, w, h, Color(45, 45, 45), false, false, true, true)
                    else
                        draw.RoundedBox(0, x + 1, y, w, h, Color(45, 45, 45))
                    end
                end

                draw.SimpleText(
                    v,
                    "Menu.ButtonText",
                    x + (5 * RoachHook.DPIScale),
                    y + h / 2,
                    RoachHook.Config[self.var].mode == string.lower(v) && Color(255, 255, 255) || (bHovered && Color(190, 190, 190) || Color(128, 128, 128)),
                    TEXT_ALIGN_LEFT,
                    TEXT_ALIGN_CENTER
                )

                self.frame.canDrag = false

                if(bHovered && input.IsMouseDown(MOUSE_LEFT)) then
                    RoachHook.Config[self.var].mode = string.lower(v)

                    RoachHook.ActiveItem = nil
                end
            end
        end
    end

    if(!self.Internal.bIsGrabbing) then self.Internal.iSavedW = w end

    if(self.Internal.bIsGrabbing) then
        if(input.IsKeyDown(KEY_ESCAPE)) then
            RoachHook.Config[self.var].key = nil

            gui.HideGameUI()
            self.Internal.bIsGrabbing = false
        else
            if(input.IsMouseDown(MOUSE_LEFT)) then
                if(!bHovered) then
                    RoachHook.Config[self.var].key = MOUSE_LEFT
                    self.Internal.bIsGrabbing = false
                end
            else
                local keys = RoachHook.Helpers.GetKeysPressed()
                if(#keys > 0) then
                    RoachHook.Config[self.var].key = keys[1]
                    self.Internal.bIsGrabbing = false
                end
            end
        end

        self.frame.canDrag = false
    end

    draw.RoundedBox(5, x - 1, y - 1, w + 2, h + 2, Color(45, 45, 45))
    draw.RoundedBox(3, x, y, w, h, Color(25, 25, 25))

    draw.SimpleTextOutlined(
        keyName,
        "Menu.ButtonText",
        x + w / 2,
        y + h / 2,
        bHovered && Color(255, 255, 255) || Color(128, 128, 128),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER,
        1,
        color_black
    )
end

Menu.NewKeybind = function(cfgVar, def_key, def_mode)
    local keybind = table.Copy(KeyBinder)
    keybind.var = cfgVar
    keybind.def.key = def_key
    keybind.def.mode = def_mode || "hold"

    RoachHook.Keybinds[#RoachHook.Keybinds + 1] = keybind

    return keybind
end