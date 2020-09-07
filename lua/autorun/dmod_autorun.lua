if !CPTBase then print("CPTBase addon is missing!") return end

CPTBase.RegisterMod("DMod Redux Vol. I","in development")

local Category = "DOOM"

CPTBase.AddParticleSystem("particles/doom_vfx_legacy.pcf", {"d_explosion_01", "d_explosion_02"})

CPTBase.AddNPC("Imp","npc_dmod_imp", Category); CPTBase.AddParticleSystem("particles/doom_vfx.pcf", {"d_fireball", "d_fireballfast", "d_fireball_notrail",})

local Category = "DOOM Eternal"

CPTBase.AddNPC("Imp (DOOM Eternal)","npc_dmod_imp_eternal", Category)

hook.Add( "ScaleNPCDamage", "DModHGROUP", "DModHGROUP" )

function DModHGROUP(npc,hitgroup,dmginfo)
	npc:Remove()
end