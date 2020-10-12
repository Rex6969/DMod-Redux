if !DrGBase then return end

----------------------------------------------------------------------------------------------------
-- INCLUDE START
----------------------------------------------------------------------------------------------------

include( "modules/dredux/server/ai_core.lua" )
include( "modules/dredux/rx_table_extension.lua" )

----------------------------------------------------------------------------------------------------
-- INCLUDE END
----------------------------------------------------------------------------------------------------

ENT.Base = "drgbase_nextbot"
ENT.PrintName = ""
ENT.Category = "DOOM"

ENT.BehaviourType = AI_BEHAV_CUSTOM
ENT.UseWalkframes = true

ENT.Factions = {"FACTION_DOOM"}
ENT.Faction = ""

ENT.GibDamage = 200

if SERVER then

	function ENT:CustomInitialize()
	
		self:Precache()
		self:SetDefaultRelationship( D_HT )
		
		self:SetHealth( self.StartHealth )
		self:SetMaxHealth( self.StartHealth )
		
		self.State = ""
		self.Conditions = {}
		
	end
	
	function ENT:Precache() return end
	function ENT:OnSpawn() return end
	
	----------------------------------------------------------------------------------------------------
	function ENT:AIBehaviour()
	
		self.NextUpdateConditions = self.NextUpdateConditions || CurTime()
		
		local cond = self.Conditions
		
		if CurTime() > self.NextUpdateConditions then
		
			if !SERVER then return end
			self:UpdateConditions( cond )
			self:HandleConditions( cond )
			self.NextUpdateConditions = CurTime() + 0.1
			
		end
			
		self:PoseParameters( cond )
		self:UpdateState()
		
	end
	
	function ENT:UpdateConditions( cond ) return end
	function ENT:HandleConditions( cond ) return end

	----------------------------------------------------------------------------------------------------
	
	function ENT:Death(dmg, hitgroup)
		if dmg:GetDamage() > self:Health() and self:Alive() then
			self:SetNW2Bool("DrGBaseDead", true)
			self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			if dmg:GetDamage() >= self.GibDamage or dmg:GetDamageType() == DMG_BLAST then
				self:HandleDeath( dmg, hitgroup )
			else
				self:DeathSounds()
				local ragdoll = self:RX_RagdollDeath( dmg )
				
			end
		end
	
	end

end

function ENT:DirectPoseParametersAt(pos, pitch, yaw, center, speed)

	if isentity(pos) then pos = pos:WorldSpaceCenter() end
	speed = speed or 2
	center = center or self:GetPos()
	local angle = (pos - center):Angle()
	
	local p_min, p_max = self:GetPoseParameterRange( self:LookupPoseParameter( pitch ) )
	local current_p = SERVER && self:GetPoseParameter( pitch ) || math.Remap( self:GetPoseParameter( pitch ), 0, 1, p_min, p_max )
	
	local y_min, y_max = self:GetPoseParameterRange( self:LookupPoseParameter( yaw ) )
	local current_y = SERVER && self:GetPoseParameter( yaw ) || math.Remap( self:GetPoseParameter( yaw ), 0, 1, y_min, y_max )
	
	self:SetPoseParameter(pitch, math.Approach( current_p, math.AngleDifference(angle.p, self:GetAngles().p), speed ) )
	self:SetPoseParameter(yaw, math.Approach( current_y, math.AngleDifference(angle.y, self:GetAngles().y), speed ) )
	
end

AddCSLuaFile()