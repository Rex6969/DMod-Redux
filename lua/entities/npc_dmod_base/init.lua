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
	
		phys:SetVelocity(self:SetUpRangeAttackTarget()* forcemul + vector)
		
	end
	
end


-- Empty shit
-- Fuck this function btw, it's only being ran if there is a enemy and not ai_ignoreplayers set to 1, it doesn't allow me to use alert code without stealing and modifying one of cptbase functions

function ENT:HandleSchedules()
end

--Idk lol