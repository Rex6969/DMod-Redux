AddCSLuaFile()

ENT.Model = "models/doom/barrel/uac_tech_barrel.mdl"

ENT.Type			= "anim"
ENT.Base 			= "obj_cpt_base"
ENT.PrintName		= "UAC Barrel"
ENT.Author			= "Rex"
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

ENT.StartHealth = 30
ENT.Damage = 150

function ENT:OnTakeDamage(dmg,hitgroup,dmginfo)
	local dmginfo = DamageInfo()
	local _Attacker = dmginfo:GetAttacker()
	local _Type = dmg:GetDamageType()
	local _Pos = dmg:GetDamagePosition()
	local _Force = dmg:GetDamageForce()
	local _Force = dmg:GetInflictor()
	local _Inflictor = dmg:GetInflictor()
	self:SetHealth(self:Health() -dmg:GetDamage())
	self:OnDamaged(dmg,dmginfo)
	if self:Health() <= 0 then
	self:Explode(_Attacker)
	end
 end
 
 function self:Explode(_Attacker)
 
	util.BlastDamage(self,_Attacker,self:GetPos(),80,self.Damage)
	
	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	util.Effect( "Explosion", effectdata )
	self:Remove()
 
 end