local SliderInt = {}
SliderInt.name = "SliderInt"
SliderInt.var = "null"
SliderInt.def = false
SliderInt.min = false
SliderInt.max = false
SliderInt.visCheck = function() return true end
SliderInt.frame = nil
SliderInt.format = "%d"
SliderInt._type = "RoachHook.SliderInt"

SliderInt.Internal = {
    bCanClick = true,
    bMousePressed = false
}

function SliderInt:Draw()
    if(RoachHook.Config[self.var] == nil) then RoachHook.Config[self.var] = self.def end
    if(RoachHook.ActiveFrame && !self.frame) then self.frame = RoachHook.ActiveFrame end
    if(!self.visCheck()) then return end

    local x, y = self.frame.x + (210 * RoachHook.DPIScale), self.frame.y + ((75 + RoachHook.iLineHeight) * RoachHook.DPIScale)
    local w, h = (self.frame.w * RoachHook.DPIScale) - (230 * RoachHook.DPIScale), 8 * RoachHook.DPIScale
    local y = y + self.frame.AddToY

    local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)

    if(RoachHook.ActiveItem) then
        self.Internal.bCanClick = false
    end
    
    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(!bHovered && !self.Internal.bMousePressed) then
            self.Internal.bCanClick = false
        elseif(bHovered && self.Internal.bCanClick) then
            self.Internal.bMousePressed = true
        end
    else
        self.Internal.bCanClick = true
        self.Internal.bMousePressed = false
    end

    if(self.Internal.bMousePressed) then self.frame.canDrag = false end

    draw.RoundedBox(3, x, y, w, h, Color(45, 45, 45))
    draw.RoundedBox(3, x + 1, y + 1, w - 2, h - 2, Color(35, 35, 35))
    local flScale = (RoachHook.Config[self.var] - self.min) / (self.max - self.min)
    draw.RoundedBox(3, x + 1, y + 1, (w - 2) * flScale, h - 2, RoachHook.GetMenuTheme())

    draw.SimpleText(
        self.name,
        "Menu.ButtonText",
        x + (5 * RoachHook.DPIScale),
        y - (5 * RoachHook.DPIScale),
        Color(255, 255, 255),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_BOTTOM
    )
    draw.SimpleText(
        string.format(self.format, RoachHook.Config[self.var]),
        "Menu.ButtonText",
        x + w - (5 * RoachHook.DPIScale),
        y - (5 * RoachHook.DPIScale),
        Color(255, 255, 255),
        TEXT_ALIGN_RIGHT,
        TEXT_ALIGN_BOTTOM
    )

    if(self.Internal.bMousePressed) then
        local iMouseX, iMouseY = gui.MousePos()
        local xx = math.Clamp((((iMouseX - x) / w) * (self.max - self.min)) + self.min, self.min, self.max)

        RoachHook.Config[self.var] = math.Round(xx, 0)
    end

    self.frame.AddToY = self.frame.AddToY + (h + (25 * RoachHook.DPIScale))
end

Menu.NewSliderInt = function(name, cfgVar, def, min, max, format, visCheck)
    local sliderInt = table.Copy(SliderInt)
    sliderInt.name = name
    sliderInt.var = cfgVar
    sliderInt.def = def
    sliderInt.min = min
    sliderInt.max = max
    sliderInt.visCheck = visCheck || sliderInt.visCheck
    sliderInt.format = format || sliderInt.format

    return sliderInt
end