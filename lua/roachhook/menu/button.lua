local Button = {}
Button.name = "Button"
Button.visCheck = function() return true end
Button.onPress = function() end
Button.frame = nil
Button._type = "RoachHook.Button"
Button.Force = {}

Button.Internal = {
    bCanClick = true,
    bClicked = false
}

function Button:Draw()
    if(RoachHook.ActiveFrame && !self.frame) then self.frame = RoachHook.ActiveFrame end
    if(!self.visCheck()) then return end

    local x, y = self.frame.x + (210 * RoachHook.DPIScale), self.frame.y + ((60 + RoachHook.iLineHeight) * RoachHook.DPIScale)
    local w, h = (self.frame.w * RoachHook.DPIScale) - (230 * RoachHook.DPIScale), 20 * RoachHook.DPIScale
    local y = y + self.frame.AddToY

    if(self.Force.x) then x = self.frame.x + (210 * RoachHook.DPIScale) + (self.Force.x * RoachHook.DPIScale) end
    if(self.Force.y) then y = self.Force.y * RoachHook.DPIScale end
    if(self.Force.w) then w = self.Force.w * RoachHook.DPIScale end
    if(self.Force.h) then h = self.Force.h * RoachHook.DPIScale end

    local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)

    if(RoachHook.ActiveItem) then
        self.Internal.bCanClick = false
    end

    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(bHovered && !self.Internal.bClicked && self.Internal.bCanClick) then
            self.Internal.bClicked = true
            self.onPress()
        elseif(!bHovered && !self.Internal.bCanClick) then
            self.Internal.bCanClick = false
        end
    else
        self.Internal.bCanClick = true
        self.Internal.bClicked = false
    end

    draw.RoundedBox(3, x, y, w, h, Color(45, 45, 45))
    draw.RoundedBox(3, x + 1, y + 1, w - 2, h - 2, bHovered && Color(40, 40, 40) || Color(35, 35, 35))

    draw.SimpleText(
        self.name,
        "Menu.ButtonText",
        x + w / 2,
        y + h / 2,
        bHovered && Color(255, 255, 255) || Color(100, 100, 100),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    if(!self.Force.dontAddY) then
        self.frame.AddToY = self.frame.AddToY + (h + (10 * RoachHook.DPIScale))
    end
end

Menu.NewButton = function(name, onPress, visCheck, force)
    local button = table.Copy(Button)
    button.name = name
    button.onPress = onPress || button.onPress
    button.visCheck = visCheck || button.visCheck
    button.Force = force || Button.Force

    return button
end