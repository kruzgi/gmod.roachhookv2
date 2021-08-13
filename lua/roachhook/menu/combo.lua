local Combo = {}
Combo.name = "Combo"
Combo.items = {}
Combo.var = "null"
Combo.def = nil
Combo.visCheck = function() return true end
Combo.frame = nil
Combo._type = "RoachHook.Combo"

Combo.Internal = {
    bCanClick = true,
    bOpenned = false,
    bMouseClicked = false
}

function Combo:Draw()
    if(RoachHook.ActiveFrame && !self.frame) then self.frame = RoachHook.ActiveFrame end
    if(RoachHook.Config[self.var] == nil) then RoachHook.Config[self.var] = self.def end
    if(!self.visCheck()) then return end
    
    local x, y = self.frame.x + (210 * RoachHook.DPIScale), self.frame.y + ((80 + RoachHook.iLineHeight) * RoachHook.DPIScale)
    local w, h = (self.frame.w * RoachHook.DPIScale) - (230 * RoachHook.DPIScale), 20 * RoachHook.DPIScale
    local y = y + self.frame.AddToY

    local bHovered = RoachHook.Helpers.MouseInBox(x, y - (20 * RoachHook.DPIScale), w, h + (20 * RoachHook.DPIScale))

    if(RoachHook.ActiveItem != self && RoachHook.ActiveItem) then
        self.Internal.bCanClick = false
    end
    
    if(input.IsMouseDown(MOUSE_LEFT) && (!RoachHook.ActiveItem || RoachHook.ActiveItem == self)) then
        if(!bHovered) then
            self.Internal.bCanClick = false
        elseif(bHovered && self.Internal.bCanClick && !self.Internal.bMouseClicked) then
            self.Internal.bOpenned = !self.Internal.bOpenned
            self.Internal.bMouseClicked = true
            if(self.Internal.bOpenned) then
                RoachHook.ActiveItem = self
            end
        end
    else
        self.Internal.bCanClick = true
        self.Internal.bMouseClicked = false
    end
    if(RoachHook.ActiveItem != self && RoachHook.ActiveItem) then self.Internal.bOpenned = false end
    if(RoachHook.ActiveItem == self && !self.Internal.bOpenned) then RoachHook.ActiveItem = nil end

    draw.RoundedBox(3, x, y, w, h, Color(45, 45, 45))
    draw.RoundedBox(3, x + 1, y + 1, w - 2, h - 2, bHovered && Color(40, 40, 40) || Color(35, 35, 35))

    draw.SimpleText(
        self.name,
        "Menu.ButtonText",
        x + (5 * RoachHook.DPIScale),
        y - (5 * RoachHook.DPIScale),
        bHovered && Color(255, 255, 255) || Color(100, 100, 100),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_BOTTOM
    )
    draw.SimpleText(
        self.items[RoachHook.Config[self.var]],
        "Menu.ButtonText",
        x + (10 * RoachHook.DPIScale),
        y + h / 2,
        bHovered && Color(255, 255, 255) || Color(100, 100, 100),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    if(self.Internal.bOpenned) then
        self.frame.DrawAbove[#self.frame.DrawAbove + 1] = function()
            local x, y, w, h = x, y + (25 * RoachHook.DPIScale), w, #self.items * (20 * RoachHook.DPIScale)

            draw.RoundedBox(3, x, y, w, h, Color(45, 45, 45))
            draw.RoundedBox(3, x + 1, y + 1, w - 2, h - 2, Color(35, 35, 35))

            local bHovered0 = RoachHook.Helpers.MouseInBox(x, y, w, h)
            if(input.IsMouseDown(MOUSE_LEFT) && !bHovered && !bHovered0) then self.Internal.bOpenned = false end

            for k,v in pairs(self.items) do
                local y, h = y + ((k - 1) * (20 * RoachHook.DPIScale)), 20 * RoachHook.DPIScale
                local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)

                draw.RoundedBox(3, x + 1, y + 1, w - 2, h - 2, bHovered && Color(40, 40, 40) || Color(35, 35, 35))
                
                draw.SimpleText(
                    v,
                    "Menu.ButtonText",
                    x + (10 * RoachHook.DPIScale),
                    y + h / 2,
                    RoachHook.Config[self.var] == k && Color(255, 255, 255) || (bHovered && Color(190, 190, 190) || Color(128, 128, 128)),
                    TEXT_ALIGN_LEFT,
                    TEXT_ALIGN_CENTER
                )

                if(bHovered && input.IsMouseDown(MOUSE_LEFT)) then
                    RoachHook.Config[self.var] = k
                    self.Internal.bOpenned = false
                end
            end
        end
    end

    self.frame.AddToY = self.frame.AddToY + (h + (30 * RoachHook.DPIScale))
end
function Combo:GetValueString(i)
    return self.items[RoachHook.Config[self.var]]
end

Menu.NewCombo = function(name, var, items, def, visCheck)
    local combo = table.Copy(Combo)
    combo.name = name
    combo.items = items
    combo.var = var
    combo.def = def
    combo.visCheck = visCheck || combo.visCheck

    return combo
end