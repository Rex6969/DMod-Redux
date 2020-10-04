AddCSLuaFile()

ENT.Model = "models/doom/pickups/rocket_large_max.mdl"

ENT.Type			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.Category 		= "DOOM Ammunition"
ENT.PrintName		= "Rocket Ammunition"
ENT.Author			= "Rex"
ENT.RenderGroup 	= RENDERGROUP_OPAQUE

ENT.Spawnable = true

function ENT:Initialize()

	self:SetModel(self.Model)
	self:Physics()

end

function ENT:Physics()

	if CLIENT then return end
	
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	local phys = self:GetPhysicsObject()
	
	if(phys:IsValid()) then
		phys:Wake()
	end
	
	if CLIENT then return end
	self:SetTrigger( true )
	
end

function ENT:StartTouch( ent )
	
	if ent:IsPlayer() then
		local ammo = GetConVar( "dmod_limitpickupammo" ):GetBool() and math.Clamp( 5, 0, 25 - ent:GetAmmoCount( "rpg_round" ) ) or 5
		if ammo > 0 then
			ent:GiveAmmo( ammo, "rpg_round" )
			self:EmitSound( "doom/ammo.ogg" )
			self:Remove()
		end
	end
	
end