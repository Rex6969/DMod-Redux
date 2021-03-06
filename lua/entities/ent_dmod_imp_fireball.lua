
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/hunter/misc/sphere025x025.mdl"
ENT.Damage = 16
ENT.DamageType = DMG_BURN
ENT.RemoveOnHitEntity = false

function ENT:CustomEffects()

	ParticleEffectAttach("d_fireball", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	self.StartLight1 = ents.Create("light_dynamic")
	self.StartLight1:SetKeyValue("brightness", "2")
	self.StartLight1:SetKeyValue("distance", "250")
	self.StartLight1:SetLocalPos(self:GetPos())
	self.StartLight1:SetLocalAngles( self:GetAngles() )
	self.StartLight1:Fire("Color", "255 100 20")
	self.StartLight1:SetParent(self)
	self.StartLight1:Spawn()
	self.StartLight1:Activate()
	self.StartLight1:Fire("TurnOn", "", 0)
	
	self:DeleteOnRemove(self.StartLight1)
	
	self:SetModelScale(0.5)
	
	if GetConVar("cpt_aidifficulty"):GetInt() > 1 then
		self.Damage = self.Damage * ( GetConVar("cpt_aidifficulty"):GetInt() - 1 )
	else
		self.Damage = self.Damage * 0.5
	end

end

function ENT:Physics()
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1)
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(true)
		phys:EnableDrag(false)
	end
end

function ENT:PhysicsCollide(data,phys)

	if !data.HitEntity then return true end
	if IsValid(self) then
		sound.Play("doom/monsters/imp/fx_imp_fireball_impact"..math.random(1,4)..".ogg", self:GetPos(), 70)
		ParticleEffect("d_explosion_01",data.HitPos +data.HitNormal,self:GetAngles())
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 25, self.Damage)
		self:Remove()
		return true
	end
	return true
end







