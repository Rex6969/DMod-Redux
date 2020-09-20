AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.IsDrGEntity = true

ENT.PrintName		= "Ragdoll"
ENT.Author			= "Rex"
--ENT.RenderGroup 	= RENDERGROUP_OPAQUE

ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_VPHYSICS
ENT.CollisionGroup = COLLISION_GROUP_INTERACTIVE
ENT.MoveCollide = 3
ENT.MoveType = MOVETYPE_VPHYSICS

ENT.Model = "models/doom/monsters/zombie/zombie_scientist.mdl"

function ENT:Initialize()

	self:SetModel(self.Model)

	self:SetMoveCollide(self.MoveCollide)
	self:SetCollisionGroup(self.CollisionGroup)
	self:PhysicsInit(self.PhysicsType)
	self:SetMoveType(self.MoveType)
	self:SetSolid(self.SolidType)
	
	self:Physics()
	
	self:SetBodygroup(1,3)
	
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
