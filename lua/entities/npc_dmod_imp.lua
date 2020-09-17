if not DrGBase then return end
ENT.Base = "npc_dmod_base"
DEFINE_BASECLASS("npc_dmod_base")

ENT.PrintName = "Imp"
ENT.Category = "DOOM"
ENT.Models = {"models/doom/monsters/imp/imp.mdl"}

ENT.StartHealth = 150

ENT.Factions = {"FACTION_DOOM"}

ENT.IdleAnimation = "idle_combat"
ENT.WalkAnimation = "walk"
ENT.RunAnimation = "run"

ENT.UseWalkframes = true

ENT.LastSeenEnemy = CurTime()

ENT.MinSurroundDist = 400
ENT.MaxSurroundDist = 800

ENT.FarDist = 1000
ENT.AttackDist = 1500

ENT.MeleeFarDistance = 150
ENT.MeleeCloseDistance = 90

ENT.Animtbl_Melee = {
	["melee_Moving"] = {"melee_forward_moving_1","melee_forward_moving_2"},
	["melee_N"] = {"melee_forward_1","melee_forward_2"},
	["melee_W"] = {"melee_left"},
	["melee_E"] = {"melee_right"},
	["melee_S"] = {"melee_back_1","melee_back_2"}
}

ENT.Animtbl_Ranged = {
	["Forward"] = {"throw_1","throw_2"},
	["move_N"] = {"throw_moving_forward"},
	["move_W"] = {"throw_moving_left"},
	["move_E"] = {"throw_moving_right"}
}

ENT.Animtbl_Stop = {
	["N"] = {"","",""},
	["W"] = {"","",""},
	["E"] = {"","",""},
	["S"] = {"","",""}
}

if SERVER then

	function ENT:CustomInitialize()
		self:SetDefaultRelationship( D_HT )
		self:OverwriteAIState( "State_Spawn" )
		
		--self:SetCooldown( "Next_Move", 0 )
		
	end
	
	function ENT:AIBehaviour()
		self:UpdateAIState(5)
		self:MeleeAttack(self:IsMoving())
		
		--if not self:HasEnemy() then return end
		--local enemy = self:GetEnemy()
		--if self:Visible(enemy) then
			--self.LastSeenEnemy = CurTime()
		--end
	end
	
	-- Idle block

	function ENT:State_Spawn()
		self:PlayAnimationAndWait( "spawn_teleport_"..math.random(1,5) )
		if self:HasEnemy() then 
			self:OverwriteAIState( "State_Combat" )
		else 
			self:OverwriteAIState( "State_Idle" ) 
		end
	end
	
	function ENT:State_Idle()
	
		if self:HasEnemy() then self:AddAIState("State_Combat") end
		
		self:SetIdleAnimation("idle_relaxed")
		self:Wait( 1.5 )
		
		self:GoTo( self:RX_RandomPos( self, 200,400 ), 100)
	end
	
	function ENT:State_Combat()
	
		if !self:HasEnemy() then self:AddAIState("State_Combat") end
		
		self:SetIdleAnimation( "idle_combat" )
		if self:GetCooldown( "Next_Move" ) <= 0 then
			self:AddAIState( "State_Combat_Move" )
			self:SetCooldown( "Next_Move", math.Rand( 3, 5 ) )
		--elseif ( CurTime() - self.LastSeenEnemy > 5 and math.random(5) == 1 ) then
			--self:AddAIState( "State_Combat_Move" )
			--self:WriteAIStateData( "Chase", true )
			--self:SetCooldown( "Next_Move", math.Rand( 2, 3 ) )
		end
	end
	
	function ENT:State_Combat_Move()
		--if self:AIStateData().Chase then
			--self:GoTo( self:GetEnemy():GetPos(), 400, function() if self:Visible(enemy) and math.random(2) == 1 then return true end end)
		--else
		self:GoTo( self:RecomputeSurroundPath() )
		--end
		self:RemoveAIState()
	end
	
	function ENT:MeleeAttack(IsMoving)
		local enemy, animkey  = self:GetEnemy(), ""
		if !enemy then return end
		if !self:Visible(enemy) then return end
		if self:IsInRange( enemy, self.MeleeCloseDistance ) --[[and not IsMoving]] then animkey = ( "melee_"..self:CalcPosDirection( enemy:GetPos() ) )
		elseif self:IsInRange( enemy, self.MeleeFarDistance ) && self:IsInCone( enemy, 60 ) then animkey = "melee_Moving"
		end
		self:PlayAnimationAndMove(self:ExtractAnimation( self.Animtbl_Melee, animkey), 1, function(self, cycle)
			if cycle > 0.3 and cycle < 0.5 then self:FaceEnemy() end 
		end)
		return
	end
	
	function ENT:RecomputeSurroundPath(_max)
		local finpos, tries, maxtries = false, 0, 10
		while tries < maxtries do 
			local _pos = self:RX_RandomPos( self:GetEnemy(), self.MinSurroundDist,  _max )
			if !util.IsInWorld(pos) and self:GetEnemy():VisibleVec(_pos+Vector(0,0,60)) and !self:IsInRange(_pos, 300) then
				finpos = _pos
				break
			end
			tries = tries + 1
		end
		return finpos
	end
	
	function ENT:HandleAnimEvent(event, time, cycle, type, options)
		local event = string.Explode(" ", options)
		
		if event[1] == "attack" then
			if event[2] == "melee" then
				self:Attack({
				damage = math.random(7,8),
				angle = 135,
				range = 90,
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
			self:BoneLook("Spine", enemypos, 60, 40, 10, 0.5)
		end
	end
	
end

AddCSLuaFile()
--DrGBase.AddNextbot(ENT)
