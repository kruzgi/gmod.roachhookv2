RoachHook.OverlayHook[#RoachHook.OverlayHook + 1] = function()
    local entities = RoachHook.Helpers.GetMenuItemFromVar("visual.selected_ents").items
    local selected_entities = RoachHook.Config["visual.selected_ents"]
    if(!selected_entities) then return end

    for i = 1, #entities do
        local ent = entities[i]
        if(!ent) then continue end
        if(!selected_entities[i]) then continue end

        local entitiesOnMap = ents.FindByClass(ent)
        for i=0, #entitiesOnMap do
            local ent = entitiesOnMap[i]
            if(!ent) then continue end

            local bbox = RoachHook.Helpers.GetRotatedAABB(ent, ent:GetAngles(), ent:GetPos())
            if(!bbox) then continue end

            local bDrawBBOX = RoachHook.Config["visual.selected_ents.b_bbox"]
            local bboxClr = RoachHook.Config["visual.selected_ents.b_bbox.color"]
            local bDrawBBOXOutline = RoachHook.Config["visual.selected_ents.b_bbox.b_outline"]
            local bboxOutlineClr = RoachHook.Config["visual.selected_ents.b_bbox.b_outline.color"]

            if(bDrawBBOX && bDrawBBOXOutline) then
                surface.SetDrawColor(bboxOutlineClr)
                surface.DrawOutlinedRect(bbox.x, bbox.y, bbox.w, bbox.h)
                surface.DrawOutlinedRect(bbox.x + 2, bbox.y + 2, bbox.w - 4, bbox.h - 4)

                surface.SetDrawColor(bboxClr)
                surface.DrawOutlinedRect(bbox.x + 1, bbox.y + 1, bbox.w - 2, bbox.h - 2)
            elseif(bDrawBBOX) then
                surface.SetDrawColor(bboxClr)
                surface.DrawOutlinedRect(bbox.x, bbox.y, bbox.w, bbox.h)
            end

            local bDrawClassname = RoachHook.Config["visual.selected_ents.b_classname"]
            local classnameClr = RoachHook.Config["visual.selected_ents.b_classname.color"]

            if(bDrawClassname) then
                draw.SimpleTextOutlined(
                    ent:GetClass(),
                    "ESP.Text1",
                    bbox.x + bbox.w / 2,
                    bbox.y - 2,
                    classnameClr,
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_BOTTOM,
                    1,
                    Color(0, 0, 0)
                )
            end

            local bDrawOwner = RoachHook.Config["visual.selected_ents.b_owner"]
            local ownerClr = RoachHook.Config["visual.selected_ents.b_owner.color"]

            if(bDrawOwner) then
                if(IsValid(ent.Owner)) then
                    draw.SimpleTextOutlined(
                        ent.Owner:Name(),
                        "ESP.Text1",
                        bbox.x + bbox.w / 2,
                        bbox.y + bbox.h,
                        ownerClr,
                        TEXT_ALIGN_CENTER,
                        nil,
                        1,
                        Color(0, 0, 0)
                    )
                elseif(ent.Getowning_ent) then
                    draw.SimpleTextOutlined(
                        ent:Getowning_ent():Name(),
                        "ESP.Text1",
                        bbox.x + bbox.w / 2,
                        bbox.y + bbox.h,
                        ownerClr,
                        TEXT_ALIGN_CENTER,
                        nil,
                        1,
                        Color(0, 0, 0)
                    )
                end
            end

            local flags = RoachHook.Config["visual.selected_ents.flags"]
            local flagsToDraw = {}
            if(flags) then
                if(flags[1]) then
                    if((ent:GetClass() == "money_printer" || ent:GetClass() == "spawned_money") && ent.Getamount) then
                        flagsToDraw[#flagsToDraw + 1] = {
                            text = "$" .. ent:Getamount(),
                            clr = RoachHook.Config["visual.selected_ents.flags.color.1"]
                        }
                    end
                end
                if(flags[2]) then
                    if(ent.Health) then
                        flagsToDraw[#flagsToDraw + 1] = {
                            text = ent:Health(),
                            clr = RoachHook.Config["visual.selected_ents.flags.color.2"]
                        }
                    end
                end
                if(flags[3]) then
                    flagsToDraw[#flagsToDraw + 1] = {
                        text = string.format("%d m", LocalPlayer():GetPos():Distance(ent:GetPos()) * 0.01904),
                        clr = RoachHook.Config["visual.selected_ents.flags.color.3"]
                    }
                end
                if(flags[4]) then
                    flagsToDraw[#flagsToDraw + 1] = {
                        text = string.format("%d m/s", (ent:GetVelocity() * engine.TickInterval()):Length2D() * 0.01904),
                        clr = RoachHook.Config["visual.selected_ents.flags.color.4"]
                    }
                end

                for i=1, #flagsToDraw do
                    local flag = flagsToDraw[i]
                    if(!flag) then continue end

                    draw.SimpleTextOutlined(
                        flag.text,
                        "ESP.Text1",
                        bbox.x + bbox.w,
                        bbox.y + (14 * (i - 1)),
                        flag.clr,
                        nil,
                        nil,
                        1,
                        Color(0, 0, 0)
                    )
                end
            end
        end
    end
end