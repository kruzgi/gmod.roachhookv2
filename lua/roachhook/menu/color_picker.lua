local ColorPicker = {}
ColorPicker.def = Color(255, 255, 255)
ColorPicker.var = "null"
ColorPicker.frame = nil
ColorPicker.useAlpha = true
ColorPicker.Internal = {
    bCanClick = true,
    bMouseClicked = false,

    bCanGrab = true,
    bIsGrabbing = false,

    bAlphaCanGrab = true,
    bAlphaIsGrabbed = false,

    bHueCanGrab = true,
    bHueIsGrabbed = false,
}
ColorPicker.x = nil
ColorPicker.y = nil
ColorPicker.hue = 0
ColorPicker.addY = 0
ColorPicker.customY = nil
ColorPicker.subX = 0
ColorPicker.ParentedBy = nil
ColorPicker._type = "RoachHook.ColorPicker"

ColorPicker.Circle = RoachHook.Circles.New(CIRCLE_FILLED, 300, 0, 0, 2)

local function RenderCircle(x, y, radius)
    local poly = {}
    for i=0, 360 do
        local pos = Vector(x, y) + Angle(0, i, 0):Forward() * radius
        poly[#poly + 1] = {x = pos.x, y = pos.y}
    end
    surface.DrawPoly(poly)
end

local matGrid = Material("gui/alpha_grid.png", "nocull")
local matHue = Material("gui/colors.png", "nocull")
function ColorPicker:Draw()
    if(RoachHook.Config[self.var] == nil) then RoachHook.Config[self.var] = self.def end
    if(RoachHook.ActiveFrame && !self.frame) then self.frame = RoachHook.ActiveFrame end

    local x, y, w, h = self.frame.x + (self.frame.w * RoachHook.DPIScale) - (50 * RoachHook.DPIScale), self.frame.y + (60 * RoachHook.DPIScale) + self.frame.AddToY, 30 * RoachHook.DPIScale, 15 * RoachHook.DPIScale
    local y = y + (self.addY * RoachHook.DPIScale)
    if(self.customY) then y = self.customY end
    local x = x - (self.subX * RoachHook.DPIScale)

    local clr = RoachHook.Config[self.var]
    draw.RoundedBox(5, x - 1, y - 1, w + 2, h + 2, Color(45, 45, 45))
    draw.RoundedBox(3, x, y, w, h, Color(25, 25, 25))

    draw.RoundedBox(3, x + 1, y + 1, w - 2, h - 2, clr)

    local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)

    if(RoachHook.ActiveItem != self && RoachHook.ActiveItem && (self.ParentedBy && RoachHook.ActiveItem != self.ParentedBy)) then
        self.Internal.bCanClick = false
    end

    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(!bHovered && self.Internal.bCanClick) then
            self.Internal.bCanClick = false
        elseif(bHovered && self.Internal.bCanClick && !self.Internal.bMouseClicked) then
            self.Internal.bMouseClicked = true

            if(RoachHook.ActiveItem == self) then
                RoachHook.ActiveItem = nil
            elseif(!RoachHook.ActiveItem) then
                RoachHook.ActiveItem = self
                self.x = (x + w) - (160 * RoachHook.DPIScale)
                self.y = y + h + (5 * RoachHook.DPIScale)
            elseif(RoachHook.ActiveItem == self.ParentedBy && self.ParentedBy) then
                if(!self.ParentedBy.ParentActive) then
                    self.ParentedBy.ParentActive = self
                    self.x = (x + w) - (160 * RoachHook.DPIScale)
                    self.y = y + h + (5 * RoachHook.DPIScale)
                elseif(self.ParentedBy.ParentActive == self) then
                    self.ParentedBy.ParentActive = nil
                end
            end
        end
    else
        self.Internal.bCanClick = true
        self.Internal.bMouseClicked = false
    end

    if(RoachHook.ActiveItem == self || (self.ParentedBy && self.ParentedBy.ParentActive == self)) then
        self.frame.DrawAbove[#self.frame.DrawAbove + 1] = function()
            local x, y, w, h = self.x, self.y, 160 * RoachHook.DPIScale, (self.useAlpha && 165 || 150) * RoachHook.DPIScale
            local x, y, w, h = math.floor(x), math.floor(y), math.floor(w), math.floor(h)

            draw.RoundedBox(3, x, y, w, h, Color(0, 0, 0, 128))
            draw.RoundedBox(3, x + 1, y + 1, w - 2, h - 2, Color(60, 60, 60))
            draw.RoundedBox(3, x + 2, y + 2, w - 4, h - 4, Color(35, 35, 35))

            local bHovered1 = RoachHook.Helpers.MouseInBox(x, y, w, h)
            if( input.IsMouseDown(MOUSE_LEFT) && !bHovered && !bHovered1 &&
                !self.Internal.bIsGrabbing && !self.Internal.bAlphaIsGrabbed && !self.Internal.bHueIsGrabbed) then
                RoachHook.ActiveItem = nil
            end

            // Hue bar
            do
                local x, y, w, h = x + w - (15 * RoachHook.DPIScale), y + (10 * RoachHook.DPIScale), 10 * RoachHook.DPIScale, 130 * RoachHook.DPIScale
                
                local bHueHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)
                if(input.IsMouseDown(MOUSE_LEFT)) then
                    if(!bHueHovered && self.Internal.bHueCanGrab) then
                        self.Internal.bHueCanGrab = false
                    elseif(bHueHovered && self.Internal.bHueCanGrab) then
                        self.Internal.bHueIsGrabbed = true
                    end
                else
                    self.Internal.bHueCanGrab = true
                    self.Internal.bHueIsGrabbed = false
                end

                if(self.Internal.bHueIsGrabbed) then
                    local val = (gui.MouseY() - y) / h
                    
                    self.hue = math.Clamp(360 - math.ceil(val * 360), 0, 360)

                    local clr = RoachHook.Config[self.var]
                    local hue, sat, val = ColorToHSV(clr)
                    
                    local newClr = HSVToColor(self.hue, sat, val)

                    RoachHook.Config[self.var].r = newClr.r
                    RoachHook.Config[self.var].g = newClr.g
                    RoachHook.Config[self.var].b = newClr.b
                end

                render.SetScissorRect(x, y, x + w, y + h, true)
            
                -- render.SetStencilWriteMask(0xFF)
                -- render.SetStencilTestMask(0xFF)
                -- render.SetStencilReferenceValue(0)
                -- render.SetStencilPassOperation(STENCIL_KEEP)
                -- render.SetStencilZFailOperation(STENCIL_KEEP)
                -- render.ClearStencil()

                -- render.SetStencilEnable(true)
                -- render.SetStencilReferenceValue(1)
                -- render.SetStencilCompareFunction(STENCIL_NEVER)
                -- render.SetStencilFailOperation(STENCIL_REPLACE)

                -- RoachHook.Helpers.DrawRoundedBoxProper(4, x, y, w, h, Color(255, 255, 255))

                -- render.SetStencilCompareFunction(STENCIL_EQUAL)
                -- render.SetStencilFailOperation(STENCIL_KEEP)

                surface.SetDrawColor(Color(255, 255, 255))
                surface.SetMaterial(matHue)
                surface.DrawTexturedRect(x, y, w, h)

                local addY = h - ((self.hue / 360) * h)

                surface.SetDrawColor(Color(25, 25, 25))
                surface.DrawOutlinedRect(x - 1, y - 2 + addY, w + 2, 4)

                -- render.SetStencilEnable(false)
                
                render.SetScissorRect(0, 0, ScrW(), ScrH(), true)
            end

            // Color preview
            if(self.useAlpha) then
                local x, y, w, h = x + w - (15 * RoachHook.DPIScale), y + h - (20 * RoachHook.DPIScale), 10 * RoachHook.DPIScale, 10 * RoachHook.DPIScale
                local clr = RoachHook.Config[self.var]

                RoachHook.Helpers.DrawRoundedBoxProper(3, x, y, w, h, Color(clr.r, clr.g, clr.b))
            end

            // Alpha bar
            if(self.useAlpha) then
                local x, y, w, h = x + (10 * RoachHook.DPIScale), y + h - (20 * RoachHook.DPIScale), 130 * RoachHook.DPIScale, 10 * RoachHook.DPIScale

                local bAlphaHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)
                if(input.IsMouseDown(MOUSE_LEFT)) then
                    if(!bAlphaHovered && self.Internal.bAlphaCanGrab) then
                        self.Internal.bAlphaCanGrab = false
                    elseif(bAlphaHovered && self.Internal.bAlphaCanGrab) then
                        self.Internal.bAlphaIsGrabbed = true
                    end
                else
                    self.Internal.bAlphaCanGrab = true
                    self.Internal.bAlphaIsGrabbed = false
                end

                if(self.Internal.bAlphaIsGrabbed) then
                    local val = (gui.MouseX() - x) / w
                    
                    RoachHook.Config[self.var].a = math.Clamp(math.ceil(val * 255), 0, 255)
                end
                
                surface.SetDrawColor(Color(255, 255, 255))
                surface.SetMaterial(matGrid)
                
                render.SetScissorRect(x, y, x + w, y + h, true)

                for i = 0, w / 128 do
                    surface.DrawTexturedRect(x + (128 * i), y, 128, 128)
                end

                render.SetScissorRect(0, 0, ScrW(), ScrH(), true)

                surface.SetDrawColor(Color(255, 255, 255))
                surface.SetMaterial(RoachHook.Materials.gradient.right)
                surface.DrawTexturedRect(x, y, w, h)

                local clr = RoachHook.Config[self.var]
                local addX = w * (clr.a / 255)
                surface.SetDrawColor(Color(clr.r, clr.g, clr.b))
                surface.DrawRect(x - 2 + addX, y - 1, 4, h + 2)
                surface.SetDrawColor(Color(25, 25, 25))
                surface.DrawOutlinedRect(x - 2 + addX, y - 1, 4, h + 2)
                
                surface.SetDrawColor(0, 0, 0)
                surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)
                surface.SetDrawColor(0, 0, 0, 128)
                surface.DrawOutlinedRect(x - 2, y - 2, w + 4, h + 4)
            end

            // Main picker
            local x, y, w, h = x + (10 * RoachHook.DPIScale), y + (10 * RoachHook.DPIScale), 130 * RoachHook.DPIScale, 130 * RoachHook.DPIScale

            -- render.SetScissorRect(x, y, x + w, y + h, true)
        
            -- render.SetStencilWriteMask(0xFF)
            -- render.SetStencilTestMask(0xFF)
            -- render.SetStencilReferenceValue(0)
            -- render.SetStencilPassOperation(STENCIL_KEEP)
            -- render.SetStencilZFailOperation(STENCIL_KEEP)
            -- render.ClearStencil()

            -- render.SetStencilEnable(true)
            -- render.SetStencilReferenceValue(1)
            -- render.SetStencilCompareFunction(STENCIL_NEVER)
            -- render.SetStencilFailOperation(STENCIL_REPLACE)

            -- RoachHook.Helpers.DrawRoundedBoxProper(5, x, y, w, h, Color(255, 255, 255))

            -- render.SetStencilCompareFunction(STENCIL_EQUAL)
            -- render.SetStencilFailOperation(STENCIL_KEEP)

            draw.RoundedBox(0, x, y, w, h, Color(255, 255, 255))

            surface.SetDrawColor(HSVToColor(self.hue, 1, 1))
            surface.SetMaterial(RoachHook.Materials.gradient.right)
            surface.DrawTexturedRect(x, y, w, h)
            
            surface.SetDrawColor(color_black)
            surface.SetMaterial(RoachHook.Materials.gradient.down)
            surface.DrawTexturedRect(x, y, w, h)

            surface.SetDrawColor(0, 0, 0)
            surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)
            surface.SetDrawColor(0, 0, 0, 128)
            surface.DrawOutlinedRect(x - 2, y - 2, w + 4, h + 4)

            -- render.SetStencilEnable(false)
            
            -- render.SetScissorRect(0, 0, ScrW(), ScrH(), true)

            local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)
            if(input.IsMouseDown(MOUSE_LEFT)) then
                if(!bHovered && self.Internal.bCanGrab) then
                    self.Internal.bCanGrab = false
                elseif(bHovered && self.Internal.bCanGrab) then
                    self.Internal.bIsGrabbing = true
                end
            else
                self.Internal.bCanGrab = true
                self.Internal.bIsGrabbing = false
            end

            if(self.Internal.bIsGrabbing) then
                local xScale, yScale = (gui.MouseX() - x) / w, (gui.MouseY() - y) / h
            
                local v, s = math.Clamp(xScale, 0, 1), math.Clamp(yScale, 0, 1)

                local y = 1 - v
                local x = 1 - s

                local clr = HSVToColor(self.hue, 1 - y, x)
                RoachHook.Config[self.var].r = clr.r
                RoachHook.Config[self.var].g = clr.g
                RoachHook.Config[self.var].b = clr.b
            end

            local hue, sat, val = ColorToHSV(RoachHook.Config[self.var])

            local bx, by = x + (w * sat), y + (h - (h * val))

            -- surface.SetDrawColor(Color(25, 25, 25))
            -- surface.DrawOutlinedRect(math.Clamp(bx, x, x + w - 4), math.Clamp(by, y, y + h - 4), 4, 4)

            draw.NoTexture()
            
            if(!self.CircleRadius) then self.CircleRadius = 3 end
            self.CircleRadius = Lerp(FrameTime() * 5, self.CircleRadius, self.Internal.bIsGrabbing && 4 || 3)
            if(!self.Internal.bIsGrabbing) then
                if(!self.LastColor) then
                    self.LastColor = Color(RoachHook.Config[self.var].r, RoachHook.Config[self.var].g, RoachHook.Config[self.var].b, RoachHook.Config[self.var].a)
                end
                self.LastColor = RoachHook.Helpers.LerpColor(FrameTime() * 5, self.LastColor, RoachHook.Config[self.var])
            end

            surface.SetDrawColor(color_black)
            RenderCircle(bx, by, self.CircleRadius)
            
            render.SetScissorRect(bx - 5, by - 5, bx, by + 5, true)

            surface.SetDrawColor(self.LastColor.r, self.LastColor.g, self.LastColor.b)
            RenderCircle(bx, by, self.CircleRadius - 1)

            render.SetScissorRect(0, 0, ScrW(), ScrH(), false)
            
            render.SetScissorRect(bx, by - 5, bx + 5, by + 5, true)

            surface.SetDrawColor(RoachHook.Config[self.var].r, RoachHook.Config[self.var].g, RoachHook.Config[self.var].b)
            RenderCircle(bx, by, self.CircleRadius - 1)

            render.SetScissorRect(0, 0, ScrW(), ScrH(), false)
            
            self.frame.canDrag = false
        end
    end
end

Menu.NewColorPicker = function(cfgVar, bUseAlpha, def, addY)
    local color = table.Copy(ColorPicker)
    color.def = def
    color.var = cfgVar
    color.useAlpha = bUseAlpha
    color.hue = ColorToHSV(color.def)
    color.addY = addY || 0

    return color
end