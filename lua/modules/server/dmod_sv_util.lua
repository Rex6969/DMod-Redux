-- Purpose: imp's and possessed soldier's movement code. Picks a random position between the _min and _max aroung the entity 'ent'

function ENT:RecomputeSurroundPath( ent, _min, _max )
	
	local finpos, tries, maxtries = false, 0, 10
	
	while tries < maxtries do 
		local _pos = self:RX_RandomPos( ent, _min,  _max )
		if !util.IsInWorld(_pos) and ent:VisibleVec(_pos+Vector(0,0,60)) and !self:IsInRange(_pos, 300) then
			finpos = _pos
			break
		end
		tries = tries + 1
	end
	return finpos
end

function ENT:GetMovementTarget()
	return self.MovementTarget or false
end

function ENT:SetMovementTarget(pos)
	self.MovementTarget = pos or false
end

function ENT:CallInCoroutineOverride(callback) -- Thank you Roach, lol
	local oldThread = self.BehaveThread
	self.BehaveThread = coroutine.create(function() callback(self) self.BehaveThread = oldThread end)
end
