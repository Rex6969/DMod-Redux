----------------------------------------------------------------------------------------------------
-- Purpose: legacy gore function 
-- OBSOLETE
----------------------------------------------------------------------------------------------------
	
function ENT:D_Gib(tbl,dmg)
		if not tbl then return end
		
	for k,v in pairs(tbl) do
		self.gib = ents.Create("ent_dmod_gib")
		self.gib:SetPos( self:GetBonePosition( self:LookupBone( k ) ) )
		self.gib:SetAngles( self:GetAngles() + AngleRand(-30,-30) )
		self.gib:SetOwner(self)
		self.gib:SetModel(v)
				
		self.gib:Spawn()
		self.gib:Activate()

		local phys = self.gib:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity( VectorRand() * 80 + self:GetUp()*100 + dmg:GetDamageForce():GetNormalized()*math.random(150,250) )
		end
			
	end
		
	self.HasDeathRagdoll = false
	self:Remove()
end
	
----------------------------------------------------------------------------------------------------
-- Purpose: Creates a ragdoll or ragdoll-based gib
----------------------------------------------------------------------------------------------------

function ENT:RX_CreateRagdoll( dmg, body, offset )
	local ragdoll = ents.Create( "prop_ragdoll" )
	local offset = offset or Vector(0,0,0)
	ragdoll:SetModel( body )
	ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	ragdoll:SetPos( self:GetPos() + self:GetRight()*20 + offset )
	ragdoll:SetAngles( self:GetAngles() + AngleRand(-30,-30) )
	ragdoll:Spawn()
	ragdoll:Activate()
	
	--ParticleEffect( "d_bloodsplat_big", self:GetPos() + self:OBBCenter(), self:GetAngles(), ragdoll )
	
	timer.Simple( 5, function() if IsValid( ragdoll ) then ragdoll:Remove() end end)
	
	local phys = ragdoll:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity( self:GetUp() * math.random(400,600) + dmg:GetDamageForce():GetNormalized()*math.random(600,900) )
	end
end

function ENT:RX_RagdollDeath() 
	ragdoll = self:BecomeRagdoll()
	timer.Simple( 5, function() if IsValid( ragdoll ) then ragdoll:Remove() end end)
end

----------------------------------------------------------------------------------------------------
-- Purpose: Creates generic gibs
----------------------------------------------------------------------------------------------------

function ENT:RX_GenericGibs( dmg, num )
	if not num then num = 1 end
	util.Decal("Blood", self:GetPos() , self:GetPos() - Vector(0,0,100), self )
	self:EmitSound("d4t/sfx_gore_big"..math.random(1,7)..".ogg",70,100,0.95)
	
	ParticleEffect( "d_bloodsplat_big", self:GetPos() + self:OBBCenter(), self:GetAngles(), ent )
	
	for i = 14-num, 14 do
		local gib = ents.Create( "prop_physics" )
		gib:SetModel( "models/doom/monsters/gore/death1_gibs_"..i..".mdl" )
		gib:SetPos( self:GetPos() + self:OBBCenter() + VectorRand()*30 )

		self:RX_CreateGib( dmg, gib ) 
	end
end

function ENT:RX_CreateGib( dmg, ent )
	ent:SetAngles( self:GetAngles() + AngleRand(-30,-30) )
	ent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	ent:Spawn()
	ent:Activate()
	
	if math.random(3) == 1 then
		ParticleEffectAttach("d_bloodtrail",PATTACH_ABSORIGIN_FOLLOW,ent,0)
		ParticleEffectAttach("d_bloodsplat",PATTACH_ABSORIGIN_FOLLOW,ent,0)
	end
	
	timer.Simple( math.random( 10, 20 )*0.05 , function() if IsValid( ent ) then ent:StopParticles() end end)
	timer.Simple( math.random( 30, 70 )*0.1 , function() if IsValid( ent ) then ent:Remove() end end)
	
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity( VectorRand() * 50 + self:GetUp() * math.random(200,300) + dmg:GetDamageForce():GetNormalized() * math.random( 100, 200 ) )
	end
	
end