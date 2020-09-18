if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously) -- Haha i touched this so many times
DEFINE_BASECLASS("drgbase_nextbot")

-- Include files

include("modules/server/dmod_ai_state.lua") -- FSM functions

if SERVER then
	
	
	ENT.PrintName = "Template"
	ENT.Category = "Other"
	ENT.Models = {"models/Kleiner.mdl"}

	ENT.UseWalkframes = true
	
	ENT.BehaviourType = AI_BEHAV_CUSTOM -- Because i want it to have custom AI
	ENT.Factions = {"FACTION_DOOM"}
	ENT.Tbl_State = {} -- State stack

	----------------------------------------------------------------------------------------------------
	-- Purpose: Replacing DrGBase functions that don't work for me.
	-- ~ Based on DrG_RandomPos but exists only for this base and it's children. Sorry for stealing your code, Drago.
	----------------------------------------------------------------------------------------------------
	
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
	
	----------------------------------------------------------------------------------------------------
	-- Purpose: animation setters/getters
	----------------------------------------------------------------------------------------------------
	
	function ENT:SetIdleAnimation(anim)
		self.IdleAnimation = anim
	end
	
	function ENT:SetWalkAnimation(anim)
		self.WalkAnimation = anim
	end
	
	function ENT:SetRunAnimation(anim)
		self.RunAnimation = anim
	end

	----------------------------------------------------------------------------------------------------
	-- Purpose: gore function
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
	-- Purpose: it should be used to restrict weird poseparameters to be set
	-- ~ ONLY should be used with 4-way blends
	-- ~ DOOM game uses the same system, as ID showed in their GDC video
	----------------------------------------------------------------------------------------------------

	
	function ENT:PreventWrongMoveBlend( p, pos )
	
		if (p > -15 and p < 15) or (p > 80 and p < 100) or (p > 170 and p < -170) or (p < -85 and p > -100) then
			return p
		end
		local _dir = self:D_DirectionTo(pos)
		if _dir == "forward" then
			return 0
		elseif _dir == "right" then
			return 90
		elseif  _dir == "left" then
			return -90
		elseif  _dir == "back" then
			return 180
		end
		return 0 -- forward
		
	end
	
	----------------------------------------------------------------------------------------------------
	-- Purpose: gore nest compatibility
	----------------------------------------------------------------------------------------------------
	
	function ENT:OnRemove()
		if not IsValid(self:GetOwner()) then return end
		local _owner = self:GetOwner()
		if IsGoreNest(_owner) then
			_owner.i_Spawned = _owner.i_Spawned - 1
		end
		BaseClass:OnRemove()
	end

else

end

	----------------------------------------------------------------------------------------------------
	-- Purpose: fuck poseparameters
	-- ~ Fuck poseparameters
	-- ~ Legacy function, it's going to be here until i find something better
	----------------------------------------------------------------------------------------------------
	
function ENT:BoneLook(bone, pos, limitx, limity, speed, mul)
	local mul = mul or 1
	local bone = self:LookupBone(bone)
	local selfpos, selfang = self:GetPos() + self:OBBCenter(), self:GetAngles()
	local targetang = (pos - selfpos):Angle()
	local rotpitch, rotyaw = math.AngleDifference(targetang.p,selfang.p) * mul, math.AngleDifference(targetang.y,selfang.y) * mul
	local curang = self:GetManipulateBoneAngles(bone)
		
	if (rotpitch > -limitx and rotpitch < limitx) and (rotyaw > -limity and rotyaw < limity) then
		self:ManipulateBoneAngles(bone, Angle( math.ApproachAngle(curang.p,rotpitch,speed), math.ApproachAngle(curang.y,rotyaw,speed), 0 ) )
	end
end

AddCSLuaFile()
