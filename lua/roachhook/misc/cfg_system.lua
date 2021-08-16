RoachHook.ConfigSystem = {}
function RoachHook.ConfigSystem:CompressConfig(json)
    local str = ""
    local spacing = "​"

    for i = 1, #json do
        local char = json[i]

        str = str .. string.byte(char) .. spacing
    end

    return str
end
function RoachHook.ConfigSystem:DecompressConfig(cfg)
    local str = ""
    local spacing = "​"

    local bytes = {}
    local byteTbl = cfg:Split(spacing)
    for k=1, #byteTbl do
        if(tonumber(byteTbl[k])) then
            bytes[#bytes + 1] = tonumber(byteTbl[k])
        end
    end

    for i = 1, #bytes do
        local byte = bytes[i]

        str = str .. string.char(byte)
    end

    return str
end