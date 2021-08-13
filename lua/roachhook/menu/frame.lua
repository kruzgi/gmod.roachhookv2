local Frame = {}
Frame.x = 0
Frame.y = 0
Frame.defH = 0
Frame.name = ""
Frame.Tabs = {}
Frame.SelectedTab = 1
Frame.SelectedSubTab = {}
Frame.AvatarCircle = RoachHook.Circles.New(CIRCLE_FILLED, 30, 0, 0)
Frame.Internal = {
    bMouseClicked = false,
    bCanDrag = true,

    iAddX = nil,
    iAddY = nil,
}
Frame.canDrag = true
Frame.DrawAbove = {}
Frame._type = "RoachHook.Frame"

function Frame:Drag()
    if(!input.IsMouseDown(MOUSE_LEFT)) then self.canDrag = true end
    if(!self.canDrag) then return end

    local bHovered = RoachHook.Helpers.MouseInBox(self.x, self.y, self.w * RoachHook.DPIScale, self.h * RoachHook.DPIScale)
    if(input.IsMouseDown(MOUSE_LEFT)) then
        if(!bHovered) then
            self.Internal.bCanDrag = false
        elseif(bHovered && self.Internal.bCanDrag && !self.Internal.bMouseClicked) then
            local mouseX, mouseY = gui.MousePos()

            self.Internal.bMouseClicked = true
            self.Internal.iAddX = self.x - mouseX
            self.Internal.iAddY = self.y - mouseY
        end
    else
        self.Internal.bCanDrag = true
        self.Internal.bMouseClicked = false
    end

    if(self.Internal.bMouseClicked) then
        local mouseX, mouseY = gui.MousePos()

        self.x = mouseX + self.Internal.iAddX
        self.y = mouseY + self.Internal.iAddY
    end

    self.x = math.Clamp(self.x, -((self.w - 10) * RoachHook.DPIScale), ScrW() - 10)
    self.y = math.Clamp(self.y, -((self.h - 10) * RoachHook.DPIScale), ScrH() - 10)
end
function Frame:Draw()
    self:Drag()

    local iLineHeight = RoachHook.iLineHeight * RoachHook.DPIScale
    local w, h = self.w * RoachHook.DPIScale, self.h * RoachHook.DPIScale

    render.SetStencilWriteMask( 0xFF )
    render.SetStencilTestMask( 0xFF )
    render.SetStencilReferenceValue( 0 )
    -- render.SetStencilCompareFunction( STENCIL_ALWAYS )
    render.SetStencilPassOperation( STENCIL_KEEP )
    -- render.SetStencilFailOperation( STENCIL_KEEP )
    render.SetStencilZFailOperation( STENCIL_KEEP )
    render.ClearStencil()

    -- Enable stencils
    render.SetStencilEnable( true )
    -- Set everything up everything draws to the stencil buffer instead of the screen
    render.SetStencilReferenceValue( 1 )
    render.SetStencilCompareFunction( STENCIL_NEVER )
    render.SetStencilFailOperation( STENCIL_REPLACE )

    surface.SetDrawColor(Color(255, 255, 255))
    draw.NoTexture()
    surface.DrawRect(self.x, self.y, self.w * RoachHook.DPIScale, self.h * RoachHook.DPIScale)

    -- Only draw things that are in the stencil buffer
    render.SetStencilCompareFunction( STENCIL_EQUAL )
    render.SetStencilFailOperation( STENCIL_KEEP )

    draw.NoTexture()

    draw.RoundedBox(math.huge, self.x, self.y, w, iLineHeight * 2, RoachHook.GetMenuTheme())

    surface.SetDrawColor(Color(35, 35, 35))
    surface.DrawRect(self.x, self.y + iLineHeight, w, h - iLineHeight)

    surface.SetDrawColor(Color(60, 60, 60))
    surface.DrawRect(self.x + 1, self.y + (50 * RoachHook.DPIScale) + iLineHeight, w - 2, 1)
    surface.SetDrawColor(Color(0, 0, 0, 128))
    surface.DrawRect(self.x + 1, self.y + (50 * RoachHook.DPIScale) + iLineHeight - 1, w - 2, 1)
    
    surface.SetDrawColor(Color(60, 60, 60))
    surface.DrawOutlinedRect(self.x, self.y + iLineHeight, w, h - iLineHeight)
    surface.SetDrawColor(Color(0, 0, 0, 128))
    surface.DrawOutlinedRect(self.x + 1, self.y + iLineHeight + 1, w - 2, h - iLineHeight - 2)

    surface.SetFont("Menu.Title")
    local nameSize = surface.GetTextSize(self.name)

    draw.SimpleText(
        self.name,
        "Menu.Title",
        self.x + (15 * RoachHook.DPIScale),
        self.y + (25 * RoachHook.DPIScale) + iLineHeight,
        Color(255, 255, 255),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    local x, y, w, h = self.x + (nameSize + (30 * RoachHook.DPIScale)), self.y + (15 * RoachHook.DPIScale) + iLineHeight, w - (nameSize + (130 * RoachHook.DPIScale)), 20 * RoachHook.DPIScale

    local nextX = 0
    for k,v in pairs(self.Tabs) do
        surface.SetFont("Menu.TabText")
        local tabText = surface.GetTextSize(v[1])
        local x, y, w, h = x + nextX, y + (2 * RoachHook.DPIScale), tabText + (20 * RoachHook.DPIScale), h - (4 * RoachHook.DPIScale)

        local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, h)
        if(bHovered && input.IsMouseDown(MOUSE_LEFT) && !RoachHook.ActiveItem && self.canDrag) then
            self.SelectedTab = k
        end

        surface.SetDrawColor(self.SelectedTab == k && Color(255, 255, 255) || (bHovered && Color(190, 190, 190) || Color(128, 128, 128)))
        surface.SetMaterial(v[2])
        surface.DrawTexturedRect(x, y, h, h)
        
        draw.SimpleText(
            v[1],
            "Menu.TabText",
            x + h + (5 * RoachHook.DPIScale),
            y + h / 2,
            self.SelectedTab == k && Color(255, 255, 255) || (bHovered && Color(190, 190, 190) || Color(128, 128, 128)),
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER
        )

        nextX = nextX + w + 15
    end

    render.SetScissorRect(x + w + (35 * RoachHook.DPIScale), y, self.x + (self.w * RoachHook.DPIScale) - 2, y + h, true)
    draw.SimpleText(
        LocalPlayer():Name(),
        "Menu.TabText",
        x + w + (35 * RoachHook.DPIScale),
        y + h / 2,
        Color(255, 255, 255),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )
    render.SetScissorRect(0, 0, ScrW(), ScrH(), false)

    surface.SetDrawColor(Color(35, 35, 35))
    surface.SetMaterial(RoachHook.Materials.gradient.right)
    surface.DrawTexturedRect(
        self.x + ((self.w * RoachHook.DPIScale) - (h * 2)) - 2,
        y,
        h * 2,
        h
    )

    surface.SetDrawColor(Color(255, 255, 255))
    if(RoachHook.LocalPlayerAvatar) then
        surface.SetMaterial(RoachHook.LocalPlayerAvatar)
    else
        draw.NoTexture()
    end
    
    self.AvatarCircle:SetX(x + w + (32 * RoachHook.DPIScale) - (14 * RoachHook.DPIScale))
    self.AvatarCircle:SetY(y + h / 2)
    self.AvatarCircle:SetRadius(14 * RoachHook.DPIScale)
    self.AvatarCircle()

    // subtabs

    surface.SetDrawColor(Color(60, 60, 60))
    surface.DrawRect(self.x + (200 * RoachHook.DPIScale), self.y + (50 * RoachHook.DPIScale) + iLineHeight + 1, 1, (self.h * RoachHook.DPIScale) - ((50 * RoachHook.DPIScale) + (iLineHeight + 2)))
    surface.SetDrawColor(Color(0, 0, 0, 128))
    surface.DrawRect(self.x + (200 * RoachHook.DPIScale) - 1, self.y + (50 * RoachHook.DPIScale) + iLineHeight + 1, 1, (self.h * RoachHook.DPIScale) - ((50 * RoachHook.DPIScale) + iLineHeight + 3))

    local id = 0
    local x, y, w, h = self.x + (20 * RoachHook.DPIScale), self.y + (65 * RoachHook.DPIScale) + iLineHeight + 1, ((self.w - 40) * RoachHook.DPIScale), (self.h * RoachHook.DPIScale) - (50 * RoachHook.DPIScale) + iLineHeight
    for k,v in pairs(self.Tabs[self.SelectedTab][3]) do
        if(type(v.visCheck) == "function") then
            if(!v.visCheck()) then continue end
        end

        if(!self.SelectedSubTab[self.SelectedTab]) then self.SelectedSubTab[self.SelectedTab] = k end

        local y, h = y + ((33 * RoachHook.DPIScale) * id), 30 * RoachHook.DPIScale
        local bHovered = RoachHook.Helpers.MouseInBox(x, y, 170 * RoachHook.DPIScale, h)

        if(bHovered && input.IsMouseDown(MOUSE_LEFT) && !RoachHook.ActiveItem && self.canDrag) then
            self.SelectedSubTab[self.SelectedTab] = k
        end
    
        draw.SimpleText(
            v.name,
            "Menu.TabText",
            x,
            y + h / 2,
            self.SelectedSubTab[self.SelectedTab] == k && Color(255, 255, 255) || (bHovered && Color(190, 190, 190) || Color(128, 128, 128)),
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER
        )

        self.AddToY = 0
        if(self.SelectedSubTab[self.SelectedTab] == k) then
            for k,v in pairs(v.items) do
                v:Draw()
            end
            
            if(v.customH) then
                self.h = Lerp((FrameTime() * 7) / GetConVarNumber("host_timescale"), self.h, v.customH)
            else
                self.h = Lerp((FrameTime() * 10) / GetConVarNumber("host_timescale"), self.h, self.defH)
            end
        end
        
        id = id + 1
    end

    render.SetStencilEnable(false)

    for k,v in pairs(self.DrawAbove) do v() end
    self.DrawAbove = {}
end

Menu.NewFrame = function(name, w, h, tabs)
    local frame = table.Copy(Frame)
    frame.name = name
    frame.x = ScrW() / 2 - w / 2
    frame.y = ScrH() / 2 - h / 2
    frame.w = w
    frame.h = h
    frame.defH = h
    frame.Tabs = tabs || {}

    return frame
end