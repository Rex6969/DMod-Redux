if !DrGBase then return end

include( "drgbase/entity_helpers.lua" )

print("dmod_proj_decl loaded")

----------------------------------------------------------------------------------------------------
-- Demons
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Weapons
----------------------------------------------------------------------------------------------------

	-- Rocket

	--[[local Rocket = {}

	Rocket.Type = "anim"
	Rocket.Base = "proj_drg_default"
	
	Rocket.Models = {"models/weapons/w_missile_launch.mdl"}
	Rocket.Gravity = false
	Rocket.OnContactEffects = {"d_rpgrocket_explosion"}
	Rocket.OnContactDecals = {"Scorch"}
	Rocket.OnContactDelete = 0
	
	function Rocket:CustomInitialize()
		ParticleEffectAttach( "d_rpgrocket_trail", 1, self, 0)
		self:DynamicLight( Color( 255, 120, 0 ), 400, 0.75 )
	end
	
	function Rocket:OnContact( ent )
		self:EmitSound( "doom/weapons/rocketlauncher/rocket_explo_"..math.random( 6 )..".ogg", 90, nil, nil, CHAN_WEAPON )
		util.ScreenShake( self:GetPos(), 50, 5, 0.5, 400 )
		self:DealDamage( ent,  math.random( 110, 130 ), DMG_BLAST )
		self:RadiusDamage( math.random( 110, 130 ) , DMG_BLAST, 100, function(ent) return ent end)
	end

	scripted_ents.Register( Rocket, "proj_dmod_rocket" )]]
	
----------------------------------------------------------------------------------------------------
	
	
