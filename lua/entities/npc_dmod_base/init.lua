if !CPTBase then return end

AddCSLuaFile('shared.lua')
include('shared.lua')

--ENT.Model = "models/error.mdl"
ENT.Health = 999

ENT.Faction = "FACTION_DOOM"

-- Custom variables

ENT._STATE = 0

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