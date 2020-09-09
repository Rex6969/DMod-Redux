if !CPTBase then return end

AddCSLuaFile('shared.lua')
include('shared.lua')

--ENT.Model = "models/error.mdl"
ENT.Health = 999
ENT.Faction = "FACTION_DOOM"

-- Custom variables

ENT.i_CurrentState = 0

ENT.v_TargetPos = Vector()

---------------------------------------------------------------------------------------------------------------------------------------------
-- New custom functions.
---------------------------------------------------------------------------------------------------------------------------------------------

-- Custom state system functions. Obsolete.

function ENT:SetState(arg)
	if not self.i_CurrentState then return end
	self.i_CurrentState = arg
end

function ENT:GetState()
	if not self.i_CurrentState then return end
	return self.i_CurrentState
end

function ENT:State(arg)
	if not self.i_CurrentState then return end
	return (self.i_CurrentState == arg)
end

-- Useful shit

function ENT:SetRunAnimation(anim)
	self.tbl_Animations["Run"] = {anim}
end

function ENT:SetWalkAnimation(anim)
	self.tbl_Animations["Walk"] = {anim}
end

function ENT:SetLastPos(pos)
	self.v_TargetPos = pos
	self:SetLastPosition(pos)
end

function ENT:GetLastPos(pos)
	return self.v_TargetPos
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- Legacy angle function
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:D_GetAngleTo(pos)
	local targetang = ( pos - self:GetPos() + self:OBBCenter() ):Angle()
	local selfang = self:GetAngles()
	local angreturn = {["x"] = math.AngleDifference(targetang.x,selfang.x),["y"] = math.AngleDifference(targetang.y,selfang.y)}
	return angreturn
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- That shit return direction as a string
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:D_DirectionTo(pos)
	local _ang = self:D_GetAngleTo(pos).y
	if _ang >= -45 and _ang <= 45 then
		return "forward"
	elseif _ang >= -135 and _ang <= -45 then
		return "right"
	elseif _ang <= 135 and _ang >= 45 then
		return "left"
	else
		return "back"
	end
end

function ENT:D_Gib(tbl,dmg)

	if not tbl then return end
	
	for k,v in pairs(self.GibTable[1]) do
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

---------------------------------------------------------------------------------------------------------------------------------------------
-- Based on the legacy range attack projectile function
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:D_RangeAttack(proj, att, forcemul, vector)

	--self.NEXTATTACK = CurTime()+math.Rand(1,3)

	local fireball = ents.Create( proj )
	
	fireball:SetPos(self:GetAttachment(self:LookupAttachment(att)).Pos)
	fireball:SetOwner(self)
	fireball:Spawn()
	fireball:Activate()
	
	local phys = fireball:GetPhysicsObject()
	
	if IsValid(phys) then
	
		phys:SetVelocity(self:SetUpRangeAttackTarget() * forcemul + vector)
		
	end
	
end

function ENT:D_RangeAttack_Normalized(proj, att, force, vector)

	--self.NEXTATTACK = CurTime()+math.Rand(1,3)

	local fireball = ents.Create( proj )
	
	fireball:SetPos(self:GetAttachment(self:LookupAttachment(att)).Pos)
	fireball:SetOwner(self)
	fireball:Spawn()
	fireball:Activate()
	
	local phys = fireball:GetPhysicsObject()
	
	if IsValid(phys) then
	
		phys:SetVelocity(self:SetUpRangeAttackTarget():GetNormalized() * force + vector)
		
	end
	
end

function ENT:OnRemove()

	if not IsValid(self:GetOwner()) then return end
	local _owner = self:GetOwner()
	if IsGoreNest(_owner) then
		_owner.i_Spawned = _owner.i_Spawned - 1
	end

end


-- Empty shit
-- Fuck this function btw, it's only being ran if there is a enemy and not ai_ignoreplayers set to 1, it doesn't allow me to use alert code without stealing and modifying one of cptbase functions

function ENT:HandleSchedules()
end

--Idk lol