local szIgnoredItems = {
    ["Undo_Undone"] = true,
    ["Undo_AddUndo"] = true,
    ["Undo_FireUndo"] = true,
    ["properties"] = true,
    ["drive_base"] = true,
    ["drive_noclip"] = true,
    ["player_default"] = true,
    ["PlayerKilled"] = true,
    ["PlayerKilledSelf"] = true,
    ["PlayerKilledByPlayer"] = true,
    ["PlayerKilledNPC"] = true,
    ["NPCKilledNPC"] = true,
    ["GModSave"] = true,
    ["player_sandbox"] = true,
    ["drive_sandbox"] = true,
    ["ReceiveDupe"] = true,
    ["ArmDupe"] = true,
    ["CopiedDupe"] = true,
    ["worldspawn"] = true,
    ["player_manager"] = true,
    ["weapon_oldmanharpoon"] = true,
    ["prop_combine_ball"] = true,
    ["env_entity_dissolver"] = true,
    ["crossbow_bolt_hl1"] = true,
    ["weapon_357_hl1"] = true,
    ["weaponbox"] = true,
    ["monster_snark"] = true,
    ["scene_manager"] = true,
    ["weapon_crowbar_hl1"] = true,
    ["simple_bot"] = true,
    ["weapon_alyxgun"] = true,
    ["vgui_screen"] = true,
    ["entityflame"] = true,
    ["weapon_physgun"] = true,
    ["weapon_swep"] = true,
    ["sent_point"] = true,
    ["env_skypaint"] = true,
    ["editvariable"] = true,
    ["env_fog_controller"] = true,
    ["env_sun"] = true,
    ["UserGroup"] = true,
    ["predicted_viewmodel"] = true,
    ["sent_anim"] = true,
    ["ServerName"] = true,   ["grenade_ar2"] = true,
    ["npc_tripmine"] = true,
    ["npc_satchel"] = true,
    ["rpg_missile"] = true,
    ["crossbow_bolt"] = true,
    ["weapon_citizensuitcase"] = true,
    ["weapon_citizenpackage"] = true,
    ["weapon_shotgun_hl1"] = true,
    ["weapon_satchel"] = true,
    ["weapon_rpg_hl1"] = true,
    ["weapon_mp5_hl1"] = true,
    ["weapon_hornetgun"] = true,
    ["weapon_handgrenade"] = true,
    ["weapon_glock_hl1"] = true,
    ["weapon_gauss"] = true,
    ["weapon_egon"] = true,
    ["weapon_crossbow_hl1"] = true,
    ["ammo_357"] = true,
    ["weapon_tripmine"] = true,
    ["weapon_snark"] = true,
    ["ammo_buckshot"] = true,
    ["ammo_rpgclip"] = true,
    ["ammo_argrenades"] = true,
    ["ammo_mp5grenades"] = true,
    ["ammo_9mmbox"] = true,
    ["ammo_9mmar"] = true,
    ["ammo_mp5clip"] = true,
    ["ammo_9mmclip"] = true,
    ["ammo_glockclip"] = true,
    ["ammo_gaussclip"] = true,
    ["ammo_egonclip"] = true,
    ["ammo_crossbow"] = true,
    ["gmod_hands"] = true,                     
}
local autoIgnoredEnts = {}
function RoachHook.UpdateIgnoredEntities()
    local items = {
        npc = list.Get("NPC"),
        vehicles = list.Get("Vehicles"),
        weapon = list.Get("Weapon"),
        sents = list.Get("SpawnableEntities")
    }

    for k,v in pairs(items) do
        for k,v in pairs(v) do
            autoIgnoredEnts[k] = true
        end
    end
end
function RoachHook.DumpNet()
    local iNet = 0
    local szNet = ""
    local szLoggedNet = {}
    while szNet != nil do
        iNet = iNet + 1
        szNet = util.NetworkIDToString(iNet)
        if(autoIgnoredEnts[szNet] || szIgnoredItems[szNet]) then continue end
        szLoggedNet[#szLoggedNet + 1] = szNet
    end
    return szLoggedNet
end