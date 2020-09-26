if not DrGBase then return end
ENT.Base = "npc_dmod_base"

include("modules/server/dmod_sv_state.lua") -- FSM functions
include("modules/server/dmod_sv_util.lua") -- Util functions
include("modules/server/dmod_sv_gore.lua") -- Util functions

include("modules/dmod_meta.lua") -- custom functions

ENT.PrintName = "Imp"
ENT.Category = "DOOM"
ENT.Models = {"models/doom/monsters/imp/imp.mdl"}

ENT.StartHealth = 75

ENT.Factions = {"FACTION_DOOM"}

ENT.IdleAnimation = "idle_combat"
ENT.WalkAnimation = "walk"
ENT.RunAnimation = "run"

ENT.UseWalkframes = true

--ENT.LastSeenEnemy = CurTime()

ENT.MinSurroundDist = 400
ENT.MaxSurroundDist = 900

ENT.FarDist = 1000
ENT.AttackDist = 1500

ENT.MeleeFarDistance = 150
ENT.MeleeCloseDistance = 90

ENT.GibDamage = 60
ENT.FalterDamage = 30
ENT.CurrentDeathAnimation = ""

ENT.Tbl_Animations = {
	["melee_Moving"] = {"melee_forward_moving_1","melee_forward_moving_2"},
	["melee_N"] = {"melee_forward_1","melee_forward_2"},
	["melee_W"] = {"melee_left"},
	["melee_E"] = {"melee_right"},
	["melee_S"] = {"melee_back_1","melee_back_2"},
	["Ranged"] = {"throw_1","throw_2"},
	["Ranged_Move_N"] = {"throw_moving_forward"},
	["Ranged_Move_NE"] = {"throw_moving_forward"},
	["Ranged_Move_NW"] = {"throw_moving_forward"},
	["Ranged_Move_W"] = {"throw_moving_left"},
	["Ranged_Move_SW"] = {"throw_moving_left"},
	["Ranged_Move_E"] = {"throw_moving_right"},
	["Ranged_Move_SE"] = {"throw_moving_left"},
	["Ranged_Move_S"] = {"throw_moving_right"},
	["N"] = {"","",""},
	["W"] = {"","",""},
	["E"] = {"","",""},
	["S"] = {"","",""}
}

if SERVER then

	ENT.Tbl_State = {}

	function ENT:AIBehaviour()
		self:UpdateState(5)
		self:MeleeAttack(self:IsMoving())
		
		--[[if not self:HasEnemy() then return end
		local enemy = self:GetEnemy()
		if self:Visible(enemy) then
			self.LastSeenEnemy = CurTime()
		end]]
	end
	
	function ENT:CustomInitialize()
		self:SetDefaultRelationship( D_HT )
		self:OverwriteState( "Spawn" )
		
		self:SetCooldown( "Next_Move", math.Rand( 3,5 ) )
		
	end
	
	-- Idle block

	function ENT:State_Spawn()
		if !self:GetInState() then
			self:PlayAnimationAndWait( "spawn_teleport_"..math.random(1,5) )
			return self:SetInState(true)
		end
		--local data = self:StateData()
		if self:HasEnemy() then self:OverwriteState( "Combat" ) else self:OverwriteState( "Idle" ) end
	end
	
	function ENT:State_Idle()
		if !self:GetInState() then
			self:SetCooldown( "Next_Wander", math.Rand(1,3) )
			return self:SetInState(true)
		end
		
		if self:GetCooldown( "Next_Wander" ) <= 0 then
			self:SetMovementTarget( self:RX_RandomPos( self, 100, 300 ) )
			self:SetCooldown( "Next_Wander", 10 )
		end
		
		if  self:GetMovementTarget() then self:FollowPath( self:GetMovementTarget() ) end
		if not self:IsMoving() then self:SetCooldown( "Next_Wander", -1 ) end
		
		if self:HasEnemy() then return self:OverwriteState( "Combat" ) end
		
	end
	
	----------------------------------------------------------------------------------------------------
	-- Combat --
	----------------------------------------------------------------------------------------------------
	
	function ENT:State_Combat()
	
		if !self:GetInState() then
			--self:Wait( math.Rand(1,3) )
			-- Stop animation code goes here
			self:SetIdleAnimation( "idle_combat" )
			
			return self:SetInState(true)
		end
		
		local enemy = self:GetEnemy()

		if not IsValid(enemy) or !self:HasEnemy() then self:OverwriteState("State_Idle") end

		if self:GetCooldown( "Next_Move" ) <= 0 or ( !self:Visible( enemy ) and math.random(5) == 1 ) then
			self:AddState( "Combat_Move" )
			self:SetCooldown( "Next_Move", math.random( 500, 900 )*0.01 )
		end
	
		self:MeleeAttack()
		self:RangedAttack( false )

	end
	
	function ENT:State_Combat_Move() 
		if !self:GetInState() then
		
			if not self:HasEnemy() then self:RemoveState() return end
			
			-- Idle-to-tun animation code goes here
			
			--if self:GetCooldown( "Next_Move" ) <= 0 then
				local pos = self:RecomputeSurroundPath( self:GetEnemy(), self.MinSurroundDist, self.MaxSurroundDist ) 
				self:SetMovementTarget( pos )
				if !self:GetMovementTarget() then return end
			--else
				--self:OverwriteState( "Combat" )
				--return
			--end
			
			self:SetIdleAnimation( "idle_combat" )
			self:SetRunAnimation( "run" )
			
			return self:SetInState(true)
		end
		
		if !self:HasEnemy() then self:OverwriteState("State_Idle") end
		
		local path = self:FollowPath( self:GetMovementTarget() )
		if path then
			if path == "reached" or path == "unreachable" then
				self:SetCooldown( "Next_Move", math.random( 500, 700 )*0.01 )
				self:OverwriteState( "Combat" )
				return
			end
		end
		
		self:MeleeAttack()
		self:RangedAttack( true )

	end
	
	----------------------------------------------------------------------------------------------------
	-- Melee Attack
	----------------------------------------------------------------------------------------------------
	
	function ENT:MeleeAttack(IsMoving)
		local enemy, animkey  = self:GetEnemy(), ""
		if not IsValid(enemy) then return end
		if !self:Visible(enemy) then return end
		if self:IsInRange( enemy, self.MeleeCloseDistance ) --[[and not IsMoving]] then animkey = ( "melee_"..self:CalcPosDirection( enemy:GetPos() ) )
		elseif self:IsInRange( enemy, self.MeleeFarDistance ) && self:IsInCone( enemy, 60 ) then animkey = "melee_Moving"
		end
		self:PlayAnimationAndMove(self:ExtractAnimation( self.Tbl_Animations, animkey), 1, function(self, cycle)
			if cycle > 0.3 and cycle < 0.5 then self:FaceEnemy() end 
		end)
		return
	end
	
	----------------------------------------------------------------------------------------------------
	-- Ranged Attack
	----------------------------------------------------------------------------------------------------	
	
	function ENT:RangedAttack(IsMoving)
		local enemy, anim_key  = self:GetEnemy(), ""
		if not IsValid(enemy) then return end
		if self:IsInRange( enemy, self.AttackDist) and self:Visible(enemy) then
		
			if self:GetCooldown( "Next_Ranged_Attack" ) <= 0 then
				local dir = self:CalcPosDirection( enemy:GetPos(), true )
				if not IsMoving and math.random( 2 ) == 1 then
					if dir == "N" then
						anim_key = "Ranged"
					else
						self:Turn()
						return
					end
				elseif IsMoving and dir ~= "S" and math.random( 3 ) == 1 then
					anim_key = "Ranged_Move_"..self:CalcPosDirection( enemy:GetPos(), true )
				end
				print(anim_key)
				self:SetCooldown( "Next_Ranged_Attack", math.Rand(1,3) )
				self:PlayAnimationAndMove(self:ExtractAnimation( self.Tbl_Animations, anim_key), 1, function(self, cycle)
					if IsMoving then 
						if cycle > 0.3 and cycle < 0.5 then self:FaceTowards( self:GetMovementTarget() ) end
					else
						if cycle > 0.3 and cycle < 0.5 then self:FaceEnemy() end
					end
				end)
			end
			
		else
			self:SetCooldown( "Next_Ranged_Attack", math.Rand(1,3) )
			self:AddState( "Combat_Move" )
		end
		
		return
	end
	
	----------------------------------------------------------------------------------------------------
	-- Turning
	----------------------------------------------------------------------------------------------------	
	
	function ENT:Turn()
	end
	
	----------------------------------------------------------------------------------------------------
	-- Pain
	----------------------------------------------------------------------------------------------------	
	
	function ENT:OnTakeDamage( dmg, hitgroup )
		self:Death( dmg, hitgroup )
	end
	
	----------------------------------------------------------------------------------------------------
	-- Death
	----------------------------------------------------------------------------------------------------	
	
	function ENT:HandleDeath( dmg, hitgroup )
		self:RX_RagdollDeath( dmg )
	end
	
	----------------------------------------------------------------------------------------------------
	-- Events
	----------------------------------------------------------------------------------------------------	
	
	function ENT:HandleAnimEvent(event, time, cycle, type, options)
		local event = string.Explode(" ", options)
		
		if event[1] == "attack" then
			if event[2] == "melee" then
				self:Attack({
				damage = math.random(15,20),
				angle = 135,
				range = 80,
				type = DMG_SLASH,
				viewpunch = Angle(5, math.random(-5, 5), 0)
				},
				function(self, hit)
					if #hit > 0 then
						sound.Play("doom/monsters/melee_hit_" .. math.random(2) .. ".ogg",self:GetPos(), 75,math.random(98,102))
					else
						sound.Play("npc/zombie/claw_miss" .. math.random(2) .. ".wav",self:GetPos(), 65,math.random(98,102))
					end
				end)
			end
		end
		
	end
	
else

	function ENT:CustomThink() 
		if CLIENT then
			if self:HasEnemy() and IsValid(self:GetEnemy()) then
				local enemypos = self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter()
				self:BoneLook("head", enemypos, 80, 60, 10, 0.5)
				self:BoneLook("spine", enemypos, 40, 20, 10, 0.5)
			end
			self:SetNextClientThink( CurTime() + 0.1 )
		end
	end
	
end

AddCSLuaFile()
--DrGBase.AddNextbot(ENT)
