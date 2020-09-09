AddCSLuaFile()

ENT.Type			= "ai"
ENT.Base 			= "ent_dmod_gorenest_base"
ENT.PrintName		= "Gore Nest (The UAC)"
ENT.Author			= "Rex"
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

ENT.IsGoreNest = true

ENT.SpawnTable = {

-- First wave

{"npc_dmod_imp",0,"d_monster_spawn_small_01"},
{"npc_dmod_imp",0,"d_monster_spawn_small_01"},
{"npc_dmod_imp",0,"d_monster_spawn_small_01"},
{"npc_dmod_imp",0,"d_monster_spawn_small_01"},

-- Occasional npcs spawned

{"npc_dmod_imp",3,"d_monster_spawn_small_01"},
{"npc_dmod_imp",0,"d_monster_spawn_small_01"},
{"npc_dmod_imp",0,"d_monster_spawn_small_01"},

-- Last wave

{"npc_dmod_imp",3,"d_monster_spawn_small_01"},
{"npc_dmod_imp",0,"d_monster_spawn_small_01"},
{"npc_dmod_imp",0,"d_monster_spawn_small_01"}
}