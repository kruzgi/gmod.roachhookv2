local Checkbox = {}
Checkbox.name = "Checkbox"
Checkbox.var = "null"
Checkbox.def = false
Checkbox.visCheck = function() return true end
Checkbox._type = "RoachHook.Checkbox"

Checkbox.keybind = nil
Checkbox.colorpicker = nil

Checkbox.Internal = {
    bCanClick = true,
}

function Checkbox:Draw()
    if(RoachHook.Config[self.var] == nil) then RoachHook.Config[self.var] = self.def end
    if(RoachHook.ActiveFrame && !self.frame) then self.frame = RoachHook.ActiveFrame end
    
    if(!self.visCheck()) then return end

    local x, y = self.frame.x + (210 * RoachHook.DPIScale), self.frame.y + ((60 + RoachHook.iLineHeight) * RoachHook.DPIScale)
    local w, h = 12 * RoachHook.DPIScale, 12 * RoachHook.DPIScale
    local y = y + self.frame.AddToY

    surface.SetFont("Menu.ChecboxText")
    local textsize = surface.GetTextSize(self.name)

    if(RoachHook.ActiveItem) then
        self.Internal.bCanClick = false
    end
    
    local bHovered = RoachHook.Helpers.MouseInBox(x, y, w + textsize + (20 * RoachHook.DPIScale), h)
    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(bHovered && self.Internal.bCanClick) then
            RoachHook.Config[self.var] = !RoachHook.Config[self.var]

            self.Internal.bCanClick = false
        elseif(!bHovered && self.Internal.bCanClick) then
            self.Internal.bCanClick = false
        end
    else
        self.Internal.bCanClick = true
    end

    draw.RoundedBox(3, x, y, w, h, Color(45, 45, 45))
    draw.RoundedBox(3, x + 1, y + 1, w - 2, h - 2, RoachHook.Config[self.var] && RoachHook.GetMenuTheme() || Color(35, 35, 35))
    
    draw.SimpleText(
        self.name,
        "Menu.ChecboxText",
        x + w + (10 * RoachHook.DPIScale),
        y + h / 2,
        RoachHook.Config[self.var] && Color(255, 255, 255) || (bHovered && Color(190, 190, 190) || Color(128, 128, 128)),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    if(self.colorpicker) then
        self.colorpicker:Draw()
    end
    if(self.keybind) then
        self.keybind:Draw()
    end

    self.frame.AddToY = self.frame.AddToY + (h + (10 * RoachHook.DPIScale))
end

Menu.NewCheckbox = function(name, cfgVar, def, visCheck, color_picker, color_picker_use_alpha, default_color, keybind_picker, def_key, def_mode)
    local checkbox = table.Copy(Checkbox)
    checkbox.name = name
    checkbox.var = cfgVar
    checkbox.def = def
    checkbox.visCheck = visCheck || checkbox.visCheck

    if(color_picker) then
        checkbox.colorpicker = Menu.NewColorPicker(cfgVar .. ".color", color_picker_use_alpha, default_color || Color(255, 255, 255))
    end
    if(keybind_picker) then
        checkbox.keybind = Menu.NewKeybind(cfgVar .. ".key", def_key, def_mode)
        
        if(color_picker) then
            checkbox.keybind.iSubX = 38
        end
    end

    return checkbox
end