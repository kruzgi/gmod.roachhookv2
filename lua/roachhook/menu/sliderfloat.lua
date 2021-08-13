local SliderFloat = {}
SliderFloat.name = "SliderFloat"
SliderFloat.var = "null"
SliderFloat.def = false
SliderFloat.min = false
SliderFloat.max = false
SliderFloat.visCheck = function() return true end
SliderFloat.frame = nil
SliderFloat.format = "%d"
SliderFloat.roundZeros = 0
SliderFloat._type = "RoachHook.SliderFloat"

SliderFloat.Internal = {
    bCanClick = true,
    bMousePressed = false
}

function SliderFloat:Draw()
    if(RoachHook.Config[self.var] == nil) then RoachHook.Config[self.var] = self.def end
    if(RoachHook.ActiveFrame && !self.frame) then self.frame = RoachHook.ActiveFrame end
    if(!self.visCheck()) then return end

    local x, y = self.frame.x + (210 * RoachHook.DPIScale), self.frame.y + ((75 + RoachHook.iLineHeight) * RoachHook.DPIScale)
    local w, h = (self.frame.w * RoachHook.DPIScale) - (230 * RoachHook.DPIScale), 8 * RoachHook.DPIScale
    local y = y + self.frame.AddToY

    if(RoachHook.ActiveItem) then
        self.Internal.bCanClick = false
    end

    local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)
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

        RoachHook.Config[self.var] = math.Round(xx, self.roundZeros)
    end

    self.frame.AddToY = self.frame.AddToY + (h + (25 * RoachHook.DPIScale))
end

Menu.NewSliderFloat = function(name, cfgVar, def, min, max, format, roundZeros, visCheck)
    local sliderFloat = table.Copy(SliderFloat)
    sliderFloat.name = name
    sliderFloat.var = cfgVar
    sliderFloat.def = def
    sliderFloat.min = min
    sliderFloat.max = max
    sliderFloat.visCheck = visCheck || sliderFloat.visCheck
    sliderFloat.format = format || "%0." .. tostring(roundZeros || sliderFloat.roundZeros) .. "f"
    sliderFloat.roundZeros = roundZeros || sliderFloat.roundZeros

    return sliderFloat
end