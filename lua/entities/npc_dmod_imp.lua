if not DrGBase then return end
ENT.Base = "npc_dmod_base"

--include("modules/client/dmod_cl_util.lua") -- Util functions
AddCSLuaFile("modules/client/dmod_cl_util.lua")

if SERVER then
include("modules/server/dmod_sv_state.lua") -- FSM functions
include("modules/server/dmod_sv_util.lua") -- Util functions
include("modules/server/dmod_sv_gore.lua") -- Util functions

include("modules/dmod_meta.lua")
end


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
	["Melee_Moving"] = {"melee_forward_moving_1","melee_forward_moving_2"},
	
	["Melee_N"] = {"melee_forward_1","melee_forward_2"},
	["Melee_W"] = {"melee_left"},
	["Melee_E"] = {"melee_right"},
	["Melee_S"] = {"melee_back_1","melee_back_2"},
	
	["Ranged"] = {"throw_1","throw_2"},
	
	["Ranged_Move_N"] = {"throw_moving_forward"},
	["Ranged_Move_NE"] = {"throw_moving_forward"},
	["Ranged_Move_NW"] = {"throw_moving_forward"},
	["Ranged_Move_W"] = {""},
	["Ranged_Move_SW"] = {"throw_moving_left"},
	["Ranged_Move_E"] = {""},
	["Ranged_Move_SE"] = {"throw_moving_right"},
	["Ranged_Move_S"] = {"throw_moving_right"},
	
	["Stop_N"] = {"run_forward_to_idle"},
	["Stop_W"] = {"run_forward_turn_left_to_idle"},
	["Stop_E"] = {"run_forward_turn_right_to_idle"},
	["Stop_S"] = {"run_forward_turn_left_180_to_idle","run_forward_turn_right_180_to_idle"},
	
	["Stop_Throw_N"] = {"run_forward_throw_to_idle"},
	["Stop_Throw_W"] = {"run_forward_throw_turn_left_to_idle"},
	["Stop_Throw_E"] = {"run_forward_throw_turn_right_to_idle"},
	["Stop_Throw_S"] = {"run_forward_throw_turn_left_180_to_idle","run_forward_turn_right_180_to_idle"},
	
	["Idle_To_Run_N"] = {"idle_to_run_forward"},
	["Idle_To_Run_NE"] = {"idle_to_run_forward"},
	["Idle_To_Run_NW"] = {"idle_to_run_forward"},
	["Idle_To_Run_W"] = {"idle_turn_left_to_run_forward"},
	["Idle_To_Run_SW"] = {"idle_turn_back_left_157_to_run_forward"},
	["Idle_To_Run_E"] = {"idle_turn_right_to_run_forward"},
	["Idle_To_Run_SE"] = {"idle_turn_back_right_157_to_run_forward"},
	["Idle_To_Run_S"] = {"idle_turn_back_left_157_to_run_forward","idle_turn_back_right_157_to_run_forward"}
}

function ENT:CustomThink() 
	if CLIENT then
		if not self:HasEnemy() then return end
		local EnemyPos = self:GetEnemy():GetPos()
		self:BoneLook("head", EnemyPos, 80, 60, 6, 0.5)
		self:BoneLook("spine2", EnemyPos, 80, 60, 4, 0.25)
		self:BoneLook("spine", EnemyPos, 80, 60, 4, 0.25)
		self:SetNextClientThink( CurTime() + 0.01 )
	end
end

if SERVER then

	ENT.Tbl_State = {}

	function ENT:AIBehaviour()
	
		self:UpdateState(5)
		
		PrintTable( self.Tbl_State )
		
		--[[if not self:HasEnemy() then return end
		local enemy = self:GetEnemy()
		if self:Visible(enemy) then
			self.LastSeenEnemy = CurTime()
		end]]
	end
	
	function ENT:CustomInitialize()
		self:SetDefaultRelationship( D_HT )
		self:OverwriteState( "Spawn" )
		
		self.EnemyPos = self:GetForward() * 200
		
		self.BehaviorType = 1 --self:GetTableValue( { 0, 0, 0, 0, 1, 1, 2 } )
		self:SetCooldown( "Next_Move", math.random( 30,55 )*0.1 )
	end
	
	----------------------------------------------------------------------------------------------------
	-- Idle
	----------------------------------------------------------------------------------------------------

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
		
		if self:GetMovementTarget() then self:FollowPath( self:GetMovementTarget() ) end
		if not self:IsMoving() then self:SetCooldown( "Next_Wander", -1 ) end
		
		if self:HasEnemy() then return self:OverwriteState( "Combat" ) end
		
	end
	
	----------------------------------------------------------------------------------------------------
	-- Combat --
	----------------------------------------------------------------------------------------------------
	
	function ENT:State_Combat()
	
		if !self:GetInState() then
			self:SetIdleAnimation( "idle_combat" )
			return self:SetInState(true)
		end
		local enemy = self:GetEnemy()
		if !self:HasEnemy() then return self:OverwriteState( "Idle" ) end
		local dist = self:GetHullRangeSquaredTo( enemy:GetPos() )
		local canmove = ( self:GetCooldown( "Next_Move" ) <= 0 )
		if dist > 1500^2 then
			self:AddState( "Combat_Move" )
		else
			self:AddState( "Combat_Surround" )
		end
	end
	
	----------------------------------------------------------------------------------------------------
	
	function ENT:State_Combat_Close()
	
		if !self:GetInState() then
			self:SetIdleAnimation( "idle_combat" )
			self:SetRunAnimation( "run" )
			self:SetCooldown( "Next_Move" , math.random( 50, 70 ) * 0.1 )
			return self:SetInState(true)
		end
		
		local enemy = self:GetEnemy()
		local beh = self.BehaviorType
		local dist = self:GetHullRangeSquaredTo( enemy )
		
		if self:GetCooldown( "Next_Move" ) <= 0 then
			if dist < 400^2 and math.random( 2 ) == 1 then
				local path = self:RecomputeSurroundPath( self, 450, 650 )
				if path then 
					self:SetMovementTarget( path )
					self:AddState( "Combat_Move", {CanRangeAttack = false} )
				end
			elseif dist > 400^2 then
				self:OverwriteState( "Combat_Surround" )
			end
			self:SetCooldown( "Next_Move", math.random ( 5, 10 )*0.1 )
		end
		
		if !self:IsMoving() and dist > 250 then
			self:RangedAttack( enemy, dist, false )
		end
		self:MeleeAttack( enemy, dist )
	end
	
	----------------------------------------------------------------------------------------------------
	
	function ENT:State_Combat_Surround()
	
		if !self:GetInState() then
			self:SetIdleAnimation( "idle_combat" )
			self:SetRunAnimation( "run" )
			self:SetCooldown( "Next_Move" , math.random( 4, 7 ) * 0.1 )
			return self:SetInState(true)
		end

		local enemy = self:GetEnemy()
		local beh = self.BehaviorType
		local dist = self:GetHullRangeSquaredTo( enemy )
		
		if self:GetCooldown( "Next_Move" ) <= 0 then
		
			if math.random( 2 ) == 1 and self:Visible( enemy ) then
			
				local path = self:RecomputeSurroundPath( self, 500, 650 )
				if path then
					self:AddState( "Combat_Move" )
					self:SetCooldown( "Next_Move", math.random ( 50, 100 )*0.1 )
				end
				
			else
			
				local path = self:RecomputeSurroundPath( enemy, 800, 1000 )
				if path then
					self:AddState( "Combat_Move" )
					self:SetCooldown( "Next_Move", math.random ( 40, 100 )*0.1 )
				end
				
			end
			
			if dist < 400^2 then
				self:OverwriteState( "Combat_Close" )
			elseif dist >1250^2 then
				self:AddState( "Combat_Far" )
			end
			
		end
		
		if dist > 250 then
			self:RangedAttack( enemy, dist, false )
		end
		
		self:MeleeAttack( enemy, dist )
		
	end
	
	----------------------------------------------------------------------------------------------------
	
	function ENT:State_Combat_Far()
	
		if !self:GetInState() then
			self:SetIdleAnimation( "idle_combat" )
			self:SetRunAnimation( "run" )
			return self:SetInState(true)
		end
		
		local enemy = self:GetEnemy()
		local dist = self:GetHullRangeSquaredTo( enemy )
		
		if dist < 1250^2 or not self:Visible( enemy ) then
			self:RemoveState()
			self:SetCooldown( "Next_Move", math.random ( 5, 10 )*0.1 )
		end
		
		if !self:IsMoving() and dist > 250 then
			self:RangedAttack( enemy, dist, false )
		end
	end
	
	----------------------------------------------------------------------------------------------------
	
	function ENT:State_Combat_Move() 
	
		if !self:GetInState() then
			local path = self:RecomputeSurroundPath( self:GetEnemy(), self.MinSurroundDist, self.MaxSurroundDist )
			if path then self:SetMovementTarget( path )
			else self:RemoveState() return end
			
			local anim_key = "Idle_To_Run_"..self:CalcPosDirection( self.loco:GetGroundMotionVector(), true )
			self:PlayAnimationAndMove( self:ExtractAnimation( self.Tbl_Animations, anim_key ), 1, function( self, cycle )
				if cycle > 0.5 then
					if self:VisibleVec( self:GetMovementTarget() ) then
						self:FaceTowards( self:GetMovementTarget() )
					else
						self:FaceTowards( self:GetVelocity() )
					end
				end
			end)
			
			self:SetIdleAnimation( "idle_combat" )
			self:SetRunAnimation( "run" )
			return self:SetInState(true)
		end
		
		if !self:HasEnemy() then self:OverwriteState("Idle") end
		local enemy = self:GetEnemy()
		local dist = self:GetHullRangeSquaredTo( enemy )
		local canrangeattack = self:StateData().CanRangeAttack or true
		
		if self:HandleMovement( enemy ) then self:RemoveState() end
		
		if dist > 300^2 and canrangeattack then
			self:RangedAttack( enemy, dist, true )
		end
		self:MeleeAttack( enemy, dist )
		
	end
	
	----------------------------------------------------------------------------------------------------
	-- Path following
	----------------------------------------------------------------------------------------------------
	
	function ENT:HandleMovement( argent )
	
		local path = self:FollowPath( self:GetMovementTarget(), 300 )
		
		if path == "reached" or path == "unreachable" then
			local anim_key = "Stop_N"
			local enemy = argent
			if self:HasEnemy() then
				local dir = self:CalcPosDirection( argent:GetPos() )
				if math.random( 2 ) == 1 and self:Visible( argent ) then
					anim_key = "Stop_Throw_"..dir
				else
					anim_key = "Stop_"..dir
				end
				
				print( dir )
				print( anim_key )
				
			end
			
			self.loco:SetVelocity( Vector( 0, 0, 0 ) ) 
			self:SetMovementTarget( self:GetPos() )
			self:PlayAnimationAndMove( self:ExtractAnimation( self.Tbl_Animations, anim_key ) )
			self:SetCooldown( "Next_Move", math.random( 50, 75 )*0.1 )
			return true
		end
		return false
	end
	
	----------------------------------------------------------------------------------------------------
	-- Melee Attack
	----------------------------------------------------------------------------------------------------
	
	function ENT:MeleeAttack( argent, dist )
	
		if self:GetCooldown( "Next_MeleeAttackCheck" ) <= 0 then
		
			self:SetCooldown( "Next_MeleeAttackCheck", 0.5 )
		
			if !self:Visible(argent) then return end
			
			local anim_key
			local dist = self:GetHullRangeSquaredTo( argent:GetPos() )
			
			if dist < self.MeleeCloseDistance^2 then anim_key = "Melee_"..self:CalcPosDirection( argent:GetPos() ) 
			elseif  dist < self.MeleeFarDistance^2 then
				if self:IsInCone( argent, 60 ) then anim_key = "Melee_Moving" end
			else return
			end

			if anim_key then
				self:PlayAnimationAndMove(self:ExtractAnimation( self.Tbl_Animations, anim_key), 1, function(self, cycle)
					if cycle > 0.3 and cycle < 0.5 then self:FaceEnemy() end 
				end)
			end
			
		end
		
	end
	
	----------------------------------------------------------------------------------------------------
	-- Ranged Attack
	----------------------------------------------------------------------------------------------------	
	
	function ENT:RangedAttack( enemy, dist, IsMoving )
		local anim_key
		local enemy = enemy or self:GetEnemy()
		if not IsValid(enemy) then return end
		if self:IsInRange( enemy, self.AttackDist ) and self:Visible(enemy) then
			self.does_move = IsMoving
			if self:GetCooldown( "Next_Ranged_Attack" ) <= 0 then
				local dir = self:CalcPosDirection( enemy:GetPos(), true )
				if not self.does_move and  math.random( 1, 3 ) == 1 then
					if dir == "N" then
						anim_key = "Ranged"
						self:SetCooldown( "Next_Ranged_Attack", math.random( 20, 45 )*0.1 )
					else
						self:Turn()
						return
					end
				elseif self.does_move and dir ~= "S" and math.random( 5 ) == 1 then
					anim_key = "Ranged_Move_"..self:CalcPosDirection( enemy:GetPos(), true )
					self:SetCooldown( "Next_Ranged_Attack", math.random( 30, 50 )*0.1 )
				end
				self:PlayAnimationAndMove(self:ExtractAnimation( self.Tbl_Animations, anim_key), 1, function(self, cycle)
					if self.does_move then 
						if cycle > 0.3 and cycle < 0.5 then self:FaceTowards( self:GetMovementTarget() ) end
					else
						if cycle > 0.3 and cycle < 0.5 then self:FaceEnemy() end
					end
				end)
			end
			--self:SetCooldown( "Next_Ranged_Attack", math.Rand(1,3) )
			--self:AddState( "Combat_Move" )
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
				damage = 8,
				angle = 155,
				range = 90,
				type = DMG_SLASH,
				viewpunch = Angle(8, math.random(-5, 5), 0)
				},
				function(self, hit)
					if #hit > 0 then
						sound.Play("doom/monsters/melee_hit_" .. math.random(2) .. ".ogg",self:GetPos(), 75,math.random(98,102))
					else
						sound.Play("npc/zombie/claw_miss" .. math.random(2) .. ".wav",self:GetPos(), 65,math.random(98,102))
					end
				end)
			elseif event[2] == "rleft" then
				self:StopParticles()
			elseif event[2] == "rright" then
				self:StopParticles()
			end
		elseif event[1] == "emit" then
		
			if event[2] == "fireleft" then
				ParticleEffectAttach("d_fireball_notrail",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("hand_left"))
			elseif event[2] == "fireright" then
				ParticleEffectAttach("d_fireball_notrail",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("hand_right"))
			end
		
		end
		
		print( event[1], " ", event[2] )
		
	end
	
else

end

AddCSLuaFile()
--DrGBase.AddNextbot(ENT)
