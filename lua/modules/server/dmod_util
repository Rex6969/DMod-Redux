-- Purpose: imp's and possessed soldier's movement code.

function ENT:RecomputeSurroundPath( argent, _min, _max )
	local finpos, tries, maxtries = false, 0, 10
		while tries < maxtries do 
			local _pos = self:RX_RandomPos( argent, _min,  _max )
			if !util.IsInWorld(pos) and argent:VisibleVec(_pos+Vector(0,0,60)) and !self:IsInRange(_pos, 300) then
				finpos = _pos
				break
			end
			tries = tries + 1
		end
		return finpos
	end
