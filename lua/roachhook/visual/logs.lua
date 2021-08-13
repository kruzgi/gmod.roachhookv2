local ClosedCaption = {}
ClosedCaption.__index = ClosedCaption
ClosedCaption.Texts = {}
ClosedCaption.Outlined = {}

local markups = {
    ["b"] = "bold",
    ["i"] = "italic",
    ["u"] = "underline",
    ["s"] = "strikethrough",
}
local function MarkupTexts(data)
    local texts = {}

    local line = 1
    for k, v in pairs(data) do
        if(v[1] == "\n") then
            line = line + 1

            continue
        end
        
        texts[line] = texts[line] || {}

        local didFind = nil
        for mark, typ in pairs(markups) do
            for str in string.gmatch(v[1], "<" .. mark .. ">(.-)</" .. mark .. ">") do
                texts[line][#texts[line] + 1] = {str, typ, v[2]}
                didFind = "<" .. mark .. ">" .. str .. "</" .. mark .. ">"
            end
        end

        if(didFind && v[1] != didFind) then
            local newstr = string.Replace(v[1], didFind, "")
            local text = MarkupTexts({
                {newstr, nil, v[2]}
            })
            for k,v in pairs(text) do
                if(istable(v[1])) then
                    texts[line][#texts[line] + 1] = v[1]
                else
                    texts[line][#texts[line] + 1] = v
                end
            end
        elseif(!didFind) then
            if(istable(v[1])) then
                texts[line][#texts[line] + 1] = {v[1][1], nil, v[1][2]}
            else
                texts[line][#texts[line] + 1] = {v[1], nil, v[2]}
            end
        end
    end

    return texts
end
function ClosedCaption:Draw(x, y, alphaOverride)
    for line, data in pairs(self.Texts) do
        local addX = 0
        for id, text in pairs(data) do
            local font = "RoachHook.CCFont"
            
            if(text[2]) then
                font = font .. "." .. text[2]
            end

            surface.SetFont(font)
            local textW, textH = surface.GetTextSize(text[1])
            
            if(self.Outlined) then
                draw.SimpleTextOutlined(
                    text[1],
                    font,
                    x + addX,
                    y + (18 * (line - 1)),
                    Color(text[3].r, text[3].g, text[3].b, alphaOverride || text[3].a),
                    nil,
                    nil,
                    1,
                    Color(0, 0, 0, alphaOverride || 255)
                )
            else
                draw.SimpleText(
                    text[1],
                    font,
                    x + addX,
                    y + (18 * (line - 1)),
                    Color(text[3].r, text[3].g, text[3].b, alphaOverride || text[3].a)
                )
            end

            addX = addX + textW
        end
    end
end

local function NewCaption(data, outlined)
    local cc = setmetatable({}, ClosedCaption)
    cc.Texts = MarkupTexts(data)
    cc.Outlined = outlined

    return cc
end

local RoachHookLogs = {}
// NOTE: This can be changed using markup stuff :ok_hand:
RoachHook.Helpers.AddLog = function(text)
    RoachHookLogs[#RoachHookLogs + 1] = {
        text = NewCaption(text, true),
        timer = CurTime(),
        yPos = (#RoachHookLogs - 1) * 14,
        alpha = 0,
    }
end
RoachHook.DrawBehindMenu[#RoachHook.DrawBehindMenu + 1] = function()
    if(!RoachHook.Config["misc.b_logs"]) then
        RoachHookLogs = {}
        
        return
    end

    local k = 0
    for id,v in pairs(RoachHookLogs) do
        if(k > 20) then
            RoachHookLogs[k].timer = CurTime()
            continue
        end

        local bHide = CurTime() - v.timer >= 3
        if(!bHide) then k = k + 1 end

        RoachHookLogs[id].alpha = Lerp(FrameTime() * 5, RoachHookLogs[id].alpha, bHide && 0 || 255)
        RoachHookLogs[id].yPos = Lerp(FrameTime() * 5, RoachHookLogs[id].yPos, (k - (bHide && 2 || 1)) * 14)
        v.text:Draw(5 * RoachHook.DPIScale, (5 + v.yPos) * RoachHook.DPIScale, v.alpha)

        if(v.alpha < 1 && bHide) then
            table.remove(RoachHookLogs, id)
        end
    end
end