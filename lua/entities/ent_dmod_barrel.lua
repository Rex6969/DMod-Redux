AddCSLuaFile()

ENT.Model = "models/props_phx/facepunch_barrel.mdl"

ENT.Type			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "UAC Barrel"
ENT.Author			= "Rex"
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_VPHYSICS
ENT.CollisionGroup = COLLISION_GROUP_INTERACTIVE
ENT.MoveCollide = 3
ENT.MoveType = MOVETYPE_VPHYSICS

ENT.StartHealth = 30
ENT.Damage = 150

function ENT:Initialize()

	self:SetModel(self.Model)

	self:SetMoveCollide(self.MoveCollide)
	self:SetCollisionGroup(self.CollisionGroup)
	self:PhysicsInit(self.PhysicsType)
	self:SetMoveType(self.MoveType)
	self:SetSolid(self.SolidType)
	
	self:Physics()
	
	self.IsDead = false

end

function ENT:Physics()

	local phys = self:GetPhysicsObject()
	
	if(phys:IsValid()) then
	
		phys:Wake()
		phys:SetMass(50)
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(true)
		
	end
end

function ENT:OnTakeDamage(dmg,hitgroup,dmginfo)
	
	self:SetHealth(self:Health() - dmg:GetDamage())
	
	if self:Health() <= 0 and not self.IsDead then
	
		self.IsDead = true
		
		util.BlastDamage(self,self,self:GetPos(),150,150)

		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		util.Effect( "Explosion", effectdata )
		self:Remove()
	end
	
end