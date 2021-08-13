local Listbox = {}
Listbox.name = "Listbox"
Listbox.var = "null"
Listbox.def = false
Listbox.visCheck = function() return true end
Listbox.Items = {}
Listbox.frame = nil
Listbox._type = "RoachHook.Listbox"
Listbox.ForceHeight = nil
Listbox.isCFG = false
Listbox.configData = {}

Listbox.Internal = {
    bCanClick = true,
}
Listbox.HoveredItem = nil

function Listbox:Draw()
    if(RoachHook.Config[self.var] == nil) then RoachHook.Config[self.var] = self.def end
    if(RoachHook.ActiveFrame && !self.frame) then self.frame = RoachHook.ActiveFrame end
    if(!self.visCheck()) then return end

    local x, y = self.frame.x + (210 * RoachHook.DPIScale), self.frame.y + ((60 + RoachHook.iLineHeight) * RoachHook.DPIScale)
    local w, h = (self.frame.w * RoachHook.DPIScale) - (230 * RoachHook.DPIScale), (self.forceHeight * RoachHook.DPIScale) || (#self.Items * (20 * RoachHook.DPIScale))
    local y = y + self.frame.AddToY

    draw.RoundedBox(3, x, y, w, h, Color(45, 45, 45))
    draw.RoundedBox(3, x + 1, y + 1, w - 2, h - 2, Color(35, 35, 35))

    render.SetScissorRect(x, y, x + w, y + h, true)

        for k,v in pairs(self.Items) do
            local y = y + ((20 * RoachHook.DPIScale) * (k - 1))
            local bHovered = RoachHook.Helpers.MouseInBox(x, y, w, 20 * RoachHook.DPIScale)
            if(self.HoveredItem == k && !bHovered) then
                self.HoveredItem = nil
            elseif(!self.HoveredItem && bHovered) then
                self.HoveredItem = k
            end
            local bHovered = self.HoveredItem == k

            if(bHovered && input.IsMouseDown(MOUSE_LEFT) && !RoachHook.ActiveItem) then
                RoachHook.Config[self.var] = k
            end
            
            draw.SimpleText(
                v,
                "Menu.ListboxText",
                x + (5 * RoachHook.DPIScale),
                y + (10 * RoachHook.DPIScale),
                RoachHook.Config[self.var] == k && Color(255, 255, 255) || (bHovered && Color(190, 190, 190) || Color(128, 128, 128)),
                nil,
                TEXT_ALIGN_CENTER
            )

            if(bHovered && self.isCFG) then
                self.frame.DrawAbove[#self.frame.DrawAbove + 1] = function()
                    // data.owner, data.ver
                    local data = self.configData[k]
    
                    local x = x + w / 2

                    local h = 40
                    local h = h * RoachHook.DPIScale
                    local h = math.floor(h)
                    
                    local x, y = x - w / 2, y + (20 * RoachHook.DPIScale)
                    
                    surface.SetDrawColor(Color(0, 0, 0, 128))
                    surface.SetMaterial(RoachHook.Materials.gradient.right)
                    surface.DrawTexturedRect(x, y, w / 2, h)
    
                    surface.SetMaterial(RoachHook.Materials.gradient.left)
                    surface.DrawTexturedRect(x + w / 2 - 1, y, w / 2, h)
                    
                    surface.SetDrawColor(RoachHook.GetMenuTheme())
                    surface.SetMaterial(RoachHook.Materials.gradient.right)
                    surface.DrawTexturedRect(x, y + h - 1, w / 2, 1)
                    surface.DrawTexturedRect(x, y, w / 2, 1)
    
                    surface.SetMaterial(RoachHook.Materials.gradient.left)
                    surface.DrawTexturedRect(x + w / 2 - 1, y + h - 1, w / 2, 1)
                    surface.DrawTexturedRect(x + w / 2 - 1, y, w / 2, 1)

                    draw.SimpleTextOutlined(
                        string.format("Made by: %s", data.owner),
                        "Menu.ListboxText",
                        x + w / 2,
                        y + (10 * RoachHook.DPIScale),
                        color_white,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        1,
                        color_black
                    )
                    draw.SimpleTextOutlined(
                        string.format("Config for: v%s", tostring(data.ver)),
                        "Menu.ListboxText",
                        x + w / 2,
                        y + (27 * RoachHook.DPIScale),
                        RoachHook.CheatVer != data.ver && Color(255, 0, 0) || color_white,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        1,
                        color_black
                    )
                end
            end
        end

    render.SetScissorRect(0, 0, ScrW(), ScrH(), false)

    self.frame.AddToY = self.frame.AddToY + (h + (10 * RoachHook.DPIScale))
end

Menu.NewListbox = function(cfgVar, items, def, visCheck, forceHeight, isCFG, cfgData)
    local listbox = table.Copy(Listbox)
    listbox.var = cfgVar
    listbox.def = def
    listbox.visCheck = visCheck || listbox.visCheck
    listbox.Items = items
    listbox.forceHeight = forceHeight
    listbox.isCFG = isCFG || false
    listbox.configData = cfgData || {}

    return listbox
end