if not DrGBase then return end
ENT.Base = "npc_dmod_base"
--DEFINE_BASECLASS("npc_dmod_base")

ENT.PrintName = "Possessed Scientist"
ENT.Category = "DOOM"
ENT.Models = {"models/doom/monsters/zombie/zombie_scientist.mdl"}

ENT.StartHealth = 150

ENT.Factions = {"FACTION_DOOM"}

ENT.IdleAnimation = "idle_combat"
ENT.WalkAnimation = "walk_straight"
ENT.RunAnimation = "walk_straight"

ENT.UseWalkframes = true

ENT.Animtbl_Melee = {
[	"melee_Stand"] = {"melee_lunge_short_left_arm","melee_lunge_short_right_arm"}
}

if SERVER then

	function ENT:CustomInitialize()
		self:SetDefaultRelationship( D_HT )
		self:AddAIState( "State_Spawn" )
	end
	
	function ENT:AIBehaviour()
		self:UpdateAIState(3)
		self:MeleeAttack(self:IsMoving())
	end
	
	-- Idle block
	
	function ENT:State_Fail()
		self:Wait( 1 )
		self:OverwriteAIState( "State_Idle" )
	end

	function ENT:State_Spawn()
		local spawn = math.random(3)
		if spawn ~= 1 then
			self:OverwriteAIState( "State_Sleep" )
			self:WriteAIStateData( "SleepType", math.random(3) )
		else
			self:OverwriteAIState( "State_Idle" )
		end
	end
	
	function ENT:State_Idle()
		--self:SetIdleAnimation("idle_relaxed")
		if self:HasEnemy() then self:AddAIState("State_Combat") end
		self:Wait( 2 )
		self:GoTo( self:RandomPos(200,300), 100 )
	end
	
	function ENT:State_Sleep()
		if self:HasEnemy() then self:SetIdleAnimation( "idle_combat" ) self:PlayAnimationAndMove("wake"..self:AIStateData().SleepType) self:AddAIState("State_Combat") end
		self:SetIdleAnimation( "asleep"..tonumber( self:AIStateData().SleepType ) )
	end

	function ENT:State_Combat()
		self:SetIdleAnimation( "idle_combat" )
		self:ChaseEntity( self:GetEnemy(), nil, function() self:MeleeAttack() end)
	end
	
	function ENT:MeleeAttack(IsMoving)
		local enemy, animkey  = self:GetEnemy(), ""
		if !enemy then return end
		if !self:Visible(enemy) then return end
		if self:IsInRange( enemy, 120 ) and self:IsInCone( enemy, 60 ) --[[and not IsMoving]] then animkey = ( "melee_Stand" ) end
		self:PlayAnimationAndMove(self:ExtractAnimation( self.Animtbl_Melee, animkey), 1, function(self, cycle)
			if cycle > 0.3 and cycle < 0.5 then self:FaceEnemy() end 
		end)
		return
	end
	
	function ENT:HandleAnimEvent(event, time, cycle, type, options)
		local event = string.Explode(" ", options)
		
		if event[1] == "attack" then
			if event[2] == "melee" then
				self:Attack({
				damage = math.random(15,20),
				angle = 90,
				range = 70,
				type = DMG_SLASH,
				viewpunch = Angle(2, math.random(-2, 2), 0)
				})
			end
		end
		
	end
	
	
else

	function ENT:CustomDraw()
		if self:HasEnemy() then
			local enemypos = self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter()
			self:BoneLook("Head", enemypos, 60, 40, 10, 0.5)
		end
	end

end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)
