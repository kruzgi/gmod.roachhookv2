local playerMdl = "null"

local function setModel(path)
    util.PrecacheModel(path)
    LocalPlayer():SetModel(path)
    LocalPlayer():InvalidateBoneCache()
    LocalPlayer():SetupBones()
    
    -- print("model has been set to", path)
end

RoachHook.Features.Misc.ModelChanger = function(plr, flags, isFake)
    -- playerMdl = LocalPlayer():GetModel()
    -- if(not RoachHook.Config["misc.b_model_changer"] or isFake) then
    --     if(playerMdl != "null") then 
    --         setModel(playerMdl)
    --     end
    --     return
    -- end

    -- local modelNamePath = RoachHook.Config["misc.b_model_changer.i_selected"]
    -- if(modelNamePath == 1) then
    --     modelNamePath = RoachHook.Config["misc.b_model_changer.sz_name"]

    --     if(modelNamePath == "null" or modelNamePath == "") then
    --         if(playerMdl != "null") then 
    --             setModel(playerMdl)
    --         end
    --         return
    --     end
    -- end

    -- local mdlPathIdx = isnumber(modelNamePath) and modelNamePath or (RoachHook.ModelIdsFromName[modelNamePath] or RoachHook.ModelIdsFromPath[modelNamePath])
    -- if(!mdlPathIdx) then
    --     if(playerMdl != "null") then 
    --         setModel(playerMdl)
    --     end
    --     return
    -- end

    -- setModel(RoachHook.ModelPaths[mdlPathIdx])
end
RoachHook.Features.Misc.ModelChangerPost = function(plr, flags, isFake)
    // if(playerMdl != "null") then 
    //     LocalPlayer():SetModel(playerMdl)
    //     -- setModel(playerMdl)
    // end
end