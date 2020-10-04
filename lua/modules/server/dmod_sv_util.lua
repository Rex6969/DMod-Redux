-- Purpose: imp's and possessed soldier's movement code. Picks a random position between the _min and _max aroung the entity 'ent'

function ENT:RecomputeSurroundPath( ent, _min, _max )
	local finpos, tries, maxtries = false, 0, 10
	while tries < maxtries do 
		local _pos = self:RX_RandomPos( ent, _min,  _max )
		if --[[!util.IsInWorld( _pos ) and]] ent:VisibleVec( _pos + Vector( 0, 0, 30 ) ) and !self:IsInRange( _pos, 200 ) then
			finpos = _pos
			break
		end
		tries = tries + 1
	end
	return finpos
end

-- Purpose: gets random position around '_entity' ent

function ENT:RX_RandomPos(_entity, _min, _max)
	if not IsValid(_entity) then return end
	if isnumber(_max) then
		local pos = _entity:GetPos() + Vector(math.random(-100, 100), math.random(-100, 100), 0):GetNormalized() * math.random(_min, _max)
		if navmesh.IsLoaded() then
			local area = navmesh.GetNearestNavArea(pos)
			if IsValid(area) then
				local pos = area:GetClosestPointOnArea(pos)
				return pos
			end
		end
	end
	return self:RX_RandomPos(_entity, 0, _max)
end

-- Purpose: replaces default drgbase GoTo function that doesn't work for me
-- Based on ChaseEntity(). Sorry for stealing your code, Drago.

function ENT:GoTo(pos, tolerance, callback)
	if not isfunction(callback) then callback = function() end end
	while true do
	local res = self:FollowPath(pos, tolerance)
	if res == "reached" then return true
	elseif res == "unreachable" then
		return false
	else
		res = callback(self, self:GetPath())
		if isbool(res) then return res end
			self:YieldCoroutine(true)
		end
	end
	return false
end

function ENT:GetMovementTarget() return self.MovementTarget or false end
function ENT:SetMovementTarget(pos) self.MovementTarget = pos or false end

function ENT:SetIdleAnimation(anim) self.IdleAnimation = anim end
function ENT:SetWalkAnimation(anim) self.WalkAnimation = anim end
function ENT:SetRunAnimation(anim) self.RunAnimation = anim end

function ENT:CallInCoroutineOverride(callback) -- Thank you Roach, lol
	local oldThread = self.BehaveThread
	self.BehaveThread = coroutine.create(function() callback(self) self.BehaveThread = oldThread end)
end
