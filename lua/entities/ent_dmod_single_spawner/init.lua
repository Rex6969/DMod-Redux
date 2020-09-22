AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/hunter/misc/sphere025x025.mdl"
ENT.ToSpawn = "npc_zombie"
ENT.SpawnParticle = "d_monster_spawn_small_01"

function ENT:Initialize()

	self:SetModel(self.Model)
	self:SetNoDraw(true)
	
	self:SetPos(self:GetPos()+Vector(0,0,80))
	
end

-- It can be activated through input (for mapping and shit).

function ENT:Input(input)
	if input == "SpawnEntity" then
		self:SpawnEntity()
	end
end

	-- I dunno lol

function ENT:SetSpawnEntity(ent)
	self.ToSpawn = ent
end

function ENT:SetSpawnParticle(particle)
	if not particle then return end
	self.SpawnParticle = particle
end

-- Entity spawn function

function ENT:SpawnEntity()
	
	ParticleEffect(self.SpawnParticle, self:GetPos()+Vector(0,0,-85), self:GetAngles())
	sound.Play( "doom/sfx_spawn_"..math.random(1,2)..".ogg",self:GetPos(), 80, math.random(98,102) )
	
	timer.Simple(1, 
		function()
			local _ent = ents.Create(self.ToSpawn)
			_ent:SetPos( self:GetPos() + Vector(0,0,-80) )
			_ent:Activate()
			_ent:Spawn()
			if IsValid(self:GetOwner()) then
				_ent:SetOwner(self:GetOwner())
			end
			self:Remove()
		end
	)

end



