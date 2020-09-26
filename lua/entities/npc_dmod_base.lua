if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously) -- Haha i touched this so many times
DEFINE_BASECLASS("drgbase_nextbot")

-- Include files

--[[
include("modules/server/dmod_sv_state.lua") -- FSM functions
include("modules/server/dmod_sv_util.lua") -- Util functions
include("modules/dmod_meta.lua") -- custom functions
]]

if SERVER then
	
	
	ENT.PrintName = "Template"
	ENT.Category = "Other"
	ENT.Models = {"models/Kleiner.mdl"}

	ENT.UseWalkframes = true
	
	ENT.BehaviourType = AI_BEHAV_CUSTOM -- Because i want it to have custom AI
	ENT.Factions = {"FACTION_DOOM"}
	--ENT.Tbl_State = {} -- State stack

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
	-- Purpose: rewrote death functionality
	----------------------------------------------------------------------------------------------------
	
	function ENT:Death(dmg, hitgroup)
		if dmg:GetDamage() > self:Health() and self:Alive() then
			self:SetNW2Bool("DrGBaseDead", true)
			self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			if dmg:GetDamage() >= self.GibDamage then
				self:HandleDeath( dmg, hitgroup )
			else
				self:DeathSounds()
				self:RX_RagdollDeath()
			end
		end

	end
	
	function ENT:OnKilled()
		return
	end
	
	function ENT:DeathSounds()
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
