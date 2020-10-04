AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.Model = "models/hunter/misc/sphere075x075.mdl"
ENT.DamageType = DMG_BURN
ENT.RemoveOnHitEntity = false

function ENT:Initialize()

		self:SetModel( self.Model )
		self:SetModelScale( 0.8 )
		
		self:SetNoDraw( true )
		
		ParticleEffectAttach( "d_baron_fireball", 1, self, 0)
		
		if SERVER then
		
			self.StartLight1 = ents.Create( "light_dynamic" )
			self.StartLight1:SetKeyValue("brightness", "1")
			self.StartLight1:SetKeyValue("distance", "200")
			self.StartLight1:SetLocalPos(self:GetPos())
			self.StartLight1:SetLocalAngles( self:GetAngles() )
			self.StartLight1:Fire("Color", "0 255 0")
			self.StartLight1:SetParent(self)
			self.StartLight1:Spawn()
			self.StartLight1:Activate()
			self:DeleteOnRemove(self.StartLight1)
		
			self:SetMoveCollide(3)
			self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)
		
			local phys = self:GetPhysicsObject()
			
			if(phys:IsValid()) then
			
				phys:Wake()
				phys:SetMass(1)
				phys:EnableGravity(false)
				phys:EnableDrag(false)
				
			end
		
		end

end

function ENT:PhysicsCollide(data,phys)

		if !data.HitEntity then return true end
		if IsValid(self) and not self.IsDead then
		
			self.IsDead = true
		
			self:EmitSound( "doom/weapons/rocketlauncher/rocket_explo_"..math.random( 6 )..".ogg", 90, nil, nil, CHAN_WEAPON )
			
			util.Decal( "FadingScorch", self:GetPos(), self:GetPos() + self:GetForward() * 50, self )
			
			--ParticleEffect("d_baron_fireball_explosion", data.HitPos + data.HitNormal, self:GetAngles() )
			--util.ScreenShake( self:GetPos(), 50, 5, 0.5, 400 )
			
			--if data.HitEntity:IsPlayer() then
				util.BlastDamage( self, self, self:GetPos(), 50, math.random( 34, 35 ) )
			--else
				--util.BlastDamage( self, self:GetOwner(), self:GetPos(), 120, math.random( 34, 35 ) )
			--end
			
			self:Remove()
		end
		
		return true
		
end






