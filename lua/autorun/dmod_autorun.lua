if !CPTBase then print("CPTBase addon is missing!") return end

CPTBase.RegisterMod("DMod I","in development")

local Category = "DOOM"

CPTBase.AddParticleSystem("particles/doom_vfx.pcf", {"d_fireball"} )
CPTBase.AddNPC("Imp","npc_dmod_imp", Category)

local Category = "DOOM Eternal"

CPTBase.AddNPC("Imp (DOOM Eternal)","npc_dmod_imp_eternal", Category)