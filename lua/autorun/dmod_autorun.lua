
if SERVER then
	CreateConVar( "dmod_limitpickupammo", "0", FCVAR_ARCHIVE )
end

include( "autorun/dmod_proj_decl.lua" )

----------------------------------------------------------------------------------------------------
-- Blood
----------------------------------------------------------------------------------------------------

	game.AddParticles( "particles/doom_blood.pcf" )
	PrecacheParticleSystem( "d_bloodsplat" )
	PrecacheParticleSystem( "d_bloodsplat_big" )
	PrecacheParticleSystem( "d_bloodtrail" )

----------------------------------------------------------------------------------------------------
-- Weapons
----------------------------------------------------------------------------------------------------

	-- Main

	game.AddParticles( "particles/doom_vfx_weapons.pcf" )
	PrecacheParticleSystem( "d_muzzleflash" )
	
	-- Rocketlauncher

	PrecacheParticleSystem( "d_rpgrocket_trail" )
	PrecacheParticleSystem( "d_rpgrocket_explosion" )
	PrecacheParticleSystem( "d_rpg_muzzleflash" )
	
----------------------------------------------------------------------------------------------------
-- Demons
----------------------------------------------------------------------------------------------------

	-- Main
	game.AddParticles( "particles/doom_vfx.pcf" )
	
	-- Baron of Hell
	util.PrecacheModel( "models/doom/monsters/baron/baron.mdl" )
	PrecacheParticleSystem( "d_baron_shockwave" )
	PrecacheParticleSystem( "d_baron_fireball" )
	