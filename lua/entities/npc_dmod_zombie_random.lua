if not DrGBase then return end
ENT.Base = "npc_dmod_base"
--DEFINE_BASECLASS("npc_dmod_base")

include("modules/dmod_meta.lua")
include("modules/server/dmod_sv_spawn.lua")

ENT.PrintName = "Random UAC Possessed"
ENT.Category = "DOOM"
ENT.Models = { "models/hunter/misc/sphere025x025.mdl"}

ENT.ToSpawn = {"npc_dmod_zombie","npc_dmod_zombie","npc_dmod_zombie_worker"}

ENT.SpawnDelay = 0
ENT.SpawnParticle = ""

if SERVER then
	
	function ENT:Input(input)
		if input == "SpawnEntity" then
			self:SpawnEntity()
		end
	end
	
	function ENT:CustomInitialize() 
		self:SetNoDraw(true)
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		self:SpawnEntity() -- temporary, for testing
	end
	
	function ENT:SpawnEntity()
		--ParticleEffect(self.SpawnParticle, self:GetPos()+Vector(0,0,-85), self:GetAngles())
		--sound.Play( "doom/sfx_spawn_"..math.random(1,2)..".ogg",self:GetPos(), 80, math.random(98,102) )
		print(ff)
		timer.Simple( 0, 
			function()
				local spawn = self.ToSpawn
				if istable( spawn ) then spawn = self:GetTableValue( spawn ) end
				local _ent = ents.Create( spawn )
				_ent:SetPos( self:GetPos() )
				_ent:Activate()
				_ent:Spawn()
				undo.ReplaceEntity(self, _ent)
				cleanup.ReplaceEntity(self, _ent)
				self:Remove()
			end)
	end

end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)

