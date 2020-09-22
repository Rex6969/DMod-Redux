function ENT:RX_CreateRagdoll( dmg, body )
	local ragdoll = ents.Create( "prop_ragdoll" )
	ragdoll:SetModel( body )
	ragdoll:SetPos( self:GetPos() )
	self:RX_CreateGib( dmg, ragdoll )
end

function ENT:RX_GenericGibs( dmg, num )
	if not num then num = 14 end
	util.Decal("Blood", self:GetPos() , self:GetPos() - Vector(0,0,100), self )
	self:EmitSound("d4t/sfx_gore_big"..math.random(1,7)..".ogg",70,100,0.95)
	for i = 1,num do
		local gib = ents.Create( "prop_physics" )
		gib:SetModel( "models/doom/monsters/gore/death1_gibs_"..i..".mdl" )
		gib:SetPos( self:GetPos() + self:OBBCenter() + VectorRand()*30 )

		self:RX_CreateGib( dmg, gib, 2000 ) 
	end
end

function ENT:RX_CreateGib( dmg, ent )

	massmul = massmul or 1

	ent:SetAngles( self:GetAngles() + AngleRand(-30,-30) )
	ent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	ent:Spawn()
	ent:Activate()
	if math.random(3) == 1 then
		ParticleEffectAttach("blood_advisor_puncture_withdraw",PATTACH_ABSORIGIN_FOLLOW,ent,0)
	end
	ParticleEffectAttach("blood_impact_red_01",PATTACH_ABSORIGIN_FOLLOW,ent,0)
	
	timer.Simple( 5, function() if IsValid( ent ) then ent:Remove() end end)
	
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity( VectorRand() * 80 + self:GetUp() * math.random(200,300) + dmg:GetDamageForce():GetNormalized() * math.random( 50, 100 ) )
	end
	
end