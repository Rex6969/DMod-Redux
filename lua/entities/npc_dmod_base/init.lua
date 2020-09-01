if !CPTBase then return end

AddCSLuaFile('shared.lua')
include('shared.lua')

--ENT.Model = "models/error.mdl"
ENT.Health = 999

ENT.Faction = "FACTION_DOOM"

-- Custom variables

ENT._STATE = 0
ENT.TargetPos = Vector()

-- Custom functions

function ENT:_SetState(arg)
	if not self._STATE then return end
	self._STATE = arg
end

function ENT:_GetState()
	if not self._STATE then return end
	return self._STATE
end

function ENT:_State(arg)
	if not self._STATE then return end
	return (self._STATE == arg)
end

function ENT:SetRunAnimation(anim)
	self.tbl_Animations["Run"] = {anim}
end

function ENT:SetWalkAnimation(anim)
	self.tbl_Animations["Walk"] = {anim}
end

function ENT:SetLastPos(pos)
	self.TargetPos = pos
	self:SetLastPosition(pos)
end

function ENT:GetLastPos(pos)
	return self.TargetPos
end

function ENT:HandleSchedules()
	-- Empty shit
	-- Fuck this function btw, it's only being ran if there is a enemy and not ai_ignoreplayers set to 1, it doesn't allow me to use alert code without stealing and modifying one of cptbase functions
end

