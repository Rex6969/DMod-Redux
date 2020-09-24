function ENT:RX_CreateRagdoll( dmg, body, offset )
	local ragdoll = ents.Create( "prop_ragdoll" )
	local offset = offset or Vector(0,0,0)
	ragdoll:SetModel( body )
	ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	ragdoll:SetPos( self:GetPos() + self:GetRight()*20 + offset )
	ragdoll:SetAngles( self:GetAngles() + AngleRand(-30,-30) )
	ragdoll:Spawn()
	ragdoll:Activate()
	
	ParticleEffectAttach("d_bloodsplat_big",PATTACH_ABSORIGIN_FOLLOW,ent,0)
	
	timer.Simple( math.Rand(2,5), function() if IsValid( ragdoll ) then ragdoll:Remove() end end)
	
	local phys = ragdoll:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity( VectorRand()*300 + self:GetUp() * math.random(700,900) + dmg:GetDamageForce():GetNormalized()*math.random(900,1200) )
	end
end

function ENT:RX_GenericGibs( dmg, num )
	if not num then num = 14 end
	util.Decal("Blood", self:GetPos() , self:GetPos() - Vector(0,0,100), self )
	self:EmitSound("d4t/sfx_gore_big"..math.random(1,7)..".ogg",70,100,0.95)
	
	ParticleEffect( "d_bloodsplat_big", self:GetPos() + self:OBBCenter(), self:GetAngles(), self )
	
	for i = 1,num do
		local gib = ents.Create( "prop_physics" )
		gib:SetModel( "models/doom/monsters/gore/death1_gibs_"..i..".mdl" )
		gib:SetPos( self:GetPos() + self:OBBCenter() + VectorRand()*30 )

		self:RX_CreateGib( dmg, gib, 2000 ) 
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
	
	timer.Simple( math.Rand(3,7), function() if IsValid( ent ) then ent:Remove() end end)
	
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity( VectorRand() * 50 + self:GetUp() * math.random(200,300) + dmg:GetDamageForce():GetNormalized() * math.random( 100, 200 ) )
	end
	
end