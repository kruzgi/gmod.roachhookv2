local MultiCombo = {}
MultiCombo.name = "MultiCombo"
MultiCombo.items = {}
MultiCombo.var = "null"
MultiCombo.def = nil
MultiCombo.visCheck = function() return true end
MultiCombo.frame = nil
MultiCombo.TextMoveX = 0
MultiCombo.itemAutoUpdate = nil
MultiCombo._type = "RoachHook.MultiCombo"

MultiCombo.Internal = {
    bCanClick = true,
    bOpenned = false,
    bMouseClicked = false
}
MultiCombo.ItemInternal = {}
MultiCombo.ColorPickersEnabled = false
MultiCombo.ColorPickers = {}

MultiCombo.ParentActive = nil

function MultiCombo:Draw()
    if(RoachHook.ActiveFrame && !self.frame) then self.frame = RoachHook.ActiveFrame end
    if(RoachHook.Config[self.var] == nil) then RoachHook.Config[self.var] = self.def end
    if(!self.visCheck()) then return end
    self.items = self.itemAutoUpdate()
    
    local x, y = self.frame.x + (210 * RoachHook.DPIScale), self.frame.y + ((80 + RoachHook.iLineHeight) * RoachHook.DPIScale)
    local w, h = (self.frame.w * RoachHook.DPIScale) - (230 * RoachHook.DPIScale), 20 * RoachHook.DPIScale
    local y = y + self.frame.AddToY

    local bHovered = RoachHook.Helpers.MouseInBox(x, y - (20 * RoachHook.DPIScale), w, h + (20 * RoachHook.DPIScale))

    if(RoachHook.ActiveItem && RoachHook.ActiveItem != self) then
        self.Internal.bCanClick = false
    end

    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(!bHovered) then
            self.Internal.bCanClick = false
        elseif(bHovered && self.Internal.bCanClick && !self.Internal.bMouseClicked) then
            self.Internal.bOpenned = !self.Internal.bOpenned
            self.Internal.bMouseClicked = true
            if(self.Internal.bOpenned) then
                RoachHook.ActiveItem = self
            else
                self.ParentActive = nil
            end
        end
    else
        self.Internal.bCanClick = true
        self.Internal.bMouseClicked = false

        if(!self.Internal.bOpenned) then
            self.ParentActive = nil
            if(RoachHook.ActiveItem == self) then
                RoachHook.ActiveItem = nil
            end
        end
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
    local values = ""
    for k,v in pairs(self.items) do
        local IsSelected = RoachHook.Config[self.var][k]
        if(IsSelected) then
            if(values == "") then
                values = tostring(self.items[k])
            else
                values = values .. ",  " .. self.items[k]
            end
        end
    end

    local valuesW = surface.GetTextSize(values)
    if(valuesW >= w - 4 && bHovered) then
        self.TextMoveX = Lerp(FrameTime(), self.TextMoveX, -((valuesW - w) + (25 * RoachHook.DPIScale)))
    else
        self.TextMoveX = Lerp(FrameTime() * 5, self.TextMoveX, 5 * RoachHook.DPIScale)
    end

    render.SetScissorRect(x + 1, y + 2, x + w - 2, y + h - 4, true)
    draw.SimpleText(
        values,
        "Menu.ButtonText",
        x + (10 * RoachHook.DPIScale) + self.TextMoveX,
        y + h / 2,
        bHovered && Color(255, 255, 255) || Color(100, 100, 100),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )
    render.SetScissorRect(0, 0, ScrW(), ScrH(), false)
    
    surface.SetDrawColor(bHovered && Color(40, 40, 40) || Color(35, 35, 35))
    surface.SetMaterial(RoachHook.Materials.gradient.right)
    surface.DrawTexturedRect(x + w - (h * 2) - 1, y + 2, h * 2, h - 4)
    surface.SetMaterial(RoachHook.Materials.gradient.left)
    surface.DrawTexturedRect(x + 2, y + 2, h * 2, h - 4)
    
    if(RoachHook.ActiveItem && RoachHook.ActiveItem.ParentedBy == self && !self.Internal.bOpenned) then
        RoachHook.ActiveItem = nil
    end

    if(self.Internal.bOpenned) then
        self.frame.DrawAbove[#self.frame.DrawAbove + 1] = function()
            local x, y, w, h = x, y + (25 * RoachHook.DPIScale), w, #self.items * (20 * RoachHook.DPIScale)

            draw.RoundedBox(3, x, y, w, h, Color(45, 45, 45))
            draw.RoundedBox(3, x + 1, y + 1, w - 2, h - 2, Color(35, 35, 35))

            local bHovered0 = RoachHook.Helpers.MouseInBox(x, y, w, h)
            if(input.IsMouseDown(MOUSE_LEFT) && !bHovered && !bHovered0) then
                if(self.ColorPickersEnabled) then
                    if(!self.ParentActive) then
                        self.Internal.bOpenned = false
                    end
                else
                    self.Internal.bOpenned = false
                end
            end

            for k,v in pairs(self.items) do
                if(!self.ItemInternal[k]) then
                    self.ItemInternal[k] = {
                        bCanClick = true,
                        bMouseClicked = false,
                    }
                end

                local y, h = y + ((k - 1) * (20 * RoachHook.DPIScale)), 20 * RoachHook.DPIScale
                local bHovered = RoachHook.Helpers.MouseInBox(x, y, w - (self.ColorPickersEnabled && (30 * RoachHook.DPIScale) || 0), h)

                draw.RoundedBox(3, x + 1, y + 1, w - 2, h - 2, bHovered && Color(40, 40, 40) || Color(35, 35, 35))
                
                draw.SimpleText(
                    v,
                    "Menu.ButtonText",
                    x + (10 * RoachHook.DPIScale),
                    y + h / 2,
                    RoachHook.Config[self.var][k] && Color(255, 255, 255) || (bHovered && Color(190, 190, 190) || Color(128, 128, 128)),
                    TEXT_ALIGN_LEFT,
                    TEXT_ALIGN_CENTER
                )

                if(input.IsMouseDown(MOUSE_LEFT) && !self.ParentActive) then
                    if(!bHovered) then
                        self.ItemInternal[k].bCanClick = false
                    elseif(bHovered && self.ItemInternal[k].bCanClick && !self.ItemInternal[k].bMouseClicked) then
                        RoachHook.Config[self.var][k] = !RoachHook.Config[self.var][k]
                        self.ItemInternal[k].bMouseClicked = true
                    end
                else
                    self.ItemInternal[k].bCanClick = true
                    self.ItemInternal[k].bMouseClicked = false
                end

                if(self.ColorPickersEnabled) then
                    self.ColorPickers[k].customY = y + 3
                    self.ColorPickers[k].subX = 8 * RoachHook.DPIScale
                    self.ColorPickers[k]:Draw()
                end
            end
        end
    end

    self.frame.AddToY = self.frame.AddToY + (h + (30 * RoachHook.DPIScale))
end

Menu.NewMultiCombo = function(name, var, items, def, visCheck, itemAutoUpdate, color_picker, color_picker_use_alpha, default_color)
    local multiCombo = table.Copy(MultiCombo)
    multiCombo.name = name
    multiCombo.items = items
    multiCombo.var = var
    multiCombo.def = def
    multiCombo.visCheck = visCheck || multiCombo.visCheck
    multiCombo.itemAutoUpdate = itemAutoUpdate || function() return multiCombo.items end

    if(color_picker) then
        multiCombo.ColorPickersEnabled = true

        for k,v in pairs(items) do
            multiCombo.ColorPickers[k] = Menu.NewColorPicker(var .. ".color" .. "." .. tostring(k), color_picker_use_alpha, RoachHook.Helpers.CopyColor(default_color))
            multiCombo.ColorPickers[k].ParentedBy = multiCombo
        end
    end

    return multiCombo
end