if not DrGBase then return end
ENT.Base = "npc_dmod_base"

include("modules/server/dmod_sv_state.lua") -- FSM functions
include("modules/server/dmod_sv_util.lua") -- Util functions
include("modules/dmod_meta.lua") -- custom functions

ENT.PrintName = "Possessed Scientist"
ENT.Category = "DOOM"
ENT.Models = {"models/doom/monsters/zombie/zombie_scientist.mdl"}

ENT.StartHealth = 150

ENT.Factions = {"FACTION_DOOM"}

ENT.IdleAnimation = "idle_combat"
ENT.WalkAnimation = "walk_straight"
ENT.RunAnimation = "walk_straight"

ENT.UseWalkframes = true

ENT.ClimbLedges = true
ENT.ClimbLedgesMinHeight = 32
ENT.ClimbLedgesMaxHeight = 256
ENT.LedgeDetectionDistance = 30

ENT.Tbl_Animations = {
	["Melee"] = {"melee_lunge_short_left_arm","melee_lunge_short_right_arm"},
	["Melee_Moving"] = {"melee_moving_fwd_lunge_left_arm","melee_moving_fwd_lunge_right_arm"},
	["Melee_Special"] = {"melee_special","melee_special_uacsecurity"},
	["Melee_Special_Moving"] = {"melee_special_moving","melee_special_uacsecurity_moving"},
	
	["Idle_To_Walk_W"] = {"idle_turn_left_to_walkforward"},
	["Idle_To_Walk_E"] = {"idle_turn_right_to_walkforward"},
	["Idle_To_Walk_SW"] = {"idle_turn_back_left_157_to_walkforward"},
	["Idle_To_Walk_SE"] = {"idle_turn_back_right_157_to_walkforward"},
	["Idle_To_Walk_S"] = {"idle_turn_back_left_157_to_walkforward","idle_turn_back_right_157_to_walkforward"},
	
	["Walk_Relaxed"] = {
		"walk_forward_relaxed_1",
		"walk_forward_relaxed_2",
		"walk_forward_relaxed_3",
		"walk_forward_relaxed_4"
		},
	
	["Walk"] = {
		"walk_forward",
		"walk_forward_b",
		"walk_forward_c",
		"walk_forward_d",
		"walk_forward_e",
		"walk_forward_f",
		"walk_forward_g"
		}
}

if SERVER then

	ENT.Tbl_State = {}

	function ENT:CustomInitialize()
		self:SetDefaultRelationship( D_HT )
		self:AddState( "Spawn" )
		self:SetCooldown( "Next_Idle_Sound", math.random(3,8) )
		self:SetNWBool("Gloryable", true)
		--self:CallOnClient(nil, function() self:SetIK(true) end)
	end
	
	function ENT:AIBehaviour()
		self:UpdateState(3)
		self:IdleSounds()
		--self:MeleeAttack(self:IsMoving())
		--PrintTable(self.Tbl_State)
	end
	
	----------------------------------------------------------------------------------------------------
	-- Spawn --
	----------------------------------------------------------------------------------------------------
	
	function ENT:State_Spawn()
		if !self:GetInState() then
			local spawn = math.random(3)
			if self:HasEnemy() then 
				self:AlertSounds() return self:OverwriteState( "Combat" ) 
			elseif math.random(2) == 1 then
				return self:OverwriteState( "Sleep", math.random(1,3) )
			else
				return self:OverwriteState( "Idle" ) 
			end
			--return self:SetInState(true)
		end
	end
	
	----------------------------------------------------------------------------------------------------
	-- Idle --
	----------------------------------------------------------------------------------------------------
	
	function ENT:State_Idle()
		if !self:GetInState() then
			self:SetIdleAnimation("idle_relaxed")
			self:SetWalkAnimation( self:ExtractAnimation( self.Tbl_Animations, "Walk_Relaxed" ) )
			return self:SetInState(true)
		end
		
		--print("idle")
		
		if self:GetCooldown( "Next_Wander" ) <= 0 then
			self:SetMovementTarget( self:RX_RandomPos( self, 100, 300 ) )
			self:SetCooldown( "Next_Wander", math.random(3,7) )
		end
		
		if self:GetMovementTarget() then self:FollowPath( self:GetMovementTarget() ) end
		if not self:IsOnGround() then self:OnFallDown() end
		if self:HasEnemy() then self:AlertSounds() return self:OverwriteState( "Combat" ) end
		
	end
	
	function ENT:State_Sleep()
	
		if !self:GetInState() then
			self:SetIdleAnimation( "asleep"..self:StateData() )
			return self:SetInState(true)
		end
	
		self:SetCooldown( "Next_Idle_Sound", 1 )
		
		if self:HasEnemy() then 
			self:SetIdleAnimation( "idle_combat" ) 
			self:PlayAnimationAndMove( "wake"..self:StateData() ) 
			self:AlertSounds()
			return self:OverwriteState("Combat") 
		end
		
	end
	
	----------------------------------------------------------------------------------------------------
	-- Combat --
	----------------------------------------------------------------------------------------------------

	function ENT:State_Combat()
	
		if !self:GetInState() then
			self:SetIdleAnimation( "idle_combat" )
			return self:SetInState(true)
		end
		
		if self:GetCooldown( "Next_Chase" ) <= 0 then
			self:AddState( "Combat_Walk" )
		end
		
		if !self:HasEnemy() then self:OverwriteState( "Idle" ) end
		
		self:HandleMeleeAttack()
		
	end
	
	function ENT:State_Combat_Walk()
	
		if !self:GetInState() then
		
			if IsValid( self:GetEnemy() ) then
		
				self:SetMovementTarget( self:GetEnemy():GetPos() )
				local anim_key = self:CalcPosDirection( self:GetMovementTarget(), true )
				if anim_key ~= "N" or anim_key ~= "NW" or anim_key ~= "NE" then
					self:PlayAnimationAndMove( self:ExtractAnimation( self.Tbl_Animations, "Idle_To_Walk"..anim_key ), 1, function(self, cycle)
						if cycle > 0.35 and cycle < 0.8 then self:FaceEnemy() end 
					end)
				end
				
			end
		
			self:SetIdleAnimation( "idle_combat" )
			self:SetRunAnimation( self:ExtractAnimation( self.Tbl_Animations, "Walk" ) )
			return self:SetInState(true)
		end
		
				if !self:HasEnemy() then self:OverwriteState( "Idle" ) end
		
		
		if !self:IsOnGround() then self:AddState( "Fall" ) end
		
		if IsValid( self:GetEnemy() ) then
			if self:GetCooldown( "Next_Chase" ) <= 0 or self:IsInRange( self:GetEnemy(), 200 ) then
				self:SetMovementTarget( self:GetEnemy():GetPos() )
				self:SetCooldown( "Next_Chase", math.Rand( 0, 3 ) )
			end
		end
		
		local path = self:FollowPath( self:GetMovementTarget() ) == "reached"
		
		if path == "reached" then
			self:RemoveState()
		end
		
		self:HandleMeleeAttack()
		
	end
	
	----------------------------------------------------------------------------------------------------
	-- Melee Attack
	----------------------------------------------------------------------------------------------------
	
	function ENT:HandleMeleeAttack()
		if IsValid( self:GetEnemy() ) then
			local anim_key = ""
			if self:Visible( self:GetEnemy() ) and self:IsInRange( self:GetEnemy(), 120 ) and self:IsInCone( self:GetEnemy(), 45 ) and math.random(3) == 1 then
				if math.random( 10 ) == 1 then
					if self:IsMoving() then
						anim_key = "Melee_Special_Moving"
					else
						anim_key = "Melee_Special"
					end
				else
					self:AttackSounds()
					if self:IsMoving() then
						anim_key = "Melee_Moving"
					else
						anim_key = "Melee"
					end
				end
			end
			
			if anim_key == "" then return end
			
			self:OverwriteState("Combat") 
			self:PlayAnimationAndMove( self:ExtractAnimation( self.Tbl_Animations, anim_key), 1, function(self, cycle)
				if cycle < 0.3 and IsValid( self:GetEnemy() ) then self:FaceEnemy() end 
			end)
		end
	end
	
	----------------------------------------------------------------------------------------------------
	-- Sounds
	----------------------------------------------------------------------------------------------------
	
	function ENT:IdleSounds()
		if self:GetCooldown( "Next_Idle_Sound"	) <= 0 and math.random(20) == 1 then
			sound.Play("doom/monsters/zombie/unwilling_idle" .. math.random(3) .. ".ogg",self:GetPos(),65, math.random(98,102))
			self:SetCooldown( "Next_Idle_Sound", math.random(5,9) )
		end
	end
	
	function ENT:AlertSounds()
		if math.random(3) == 1 then
			sound.Play("doom/monsters/zombie/unwilling_sight" .. math.random(3) .. ".ogg",self:GetPos(),70, math.random(98,102))
			self:SetCooldown( "Next_Idle_Sound", math.random(3,9) )
		end
	end
	
	function ENT:AttackSounds()
		sound.Play("doom/monsters/zombie/unwilling_attack" .. math.random(3) .. ".ogg",self:GetPos(),65, math.random(98,102))
		self:SetCooldown( "Next_Idle_Sound", math.random(2,5) )
	end
	
	----------------------------------------------------------------------------------------------------
	-- Climbing
	----------------------------------------------------------------------------------------------------
	
	function ENT:OnStartClimbing( ledge, height, down)
	
		if down then print("heck") return end
	
		if isvector(ledge) and self:VisibleVec( ledge ) then
			local anim_key = ""
			
			if height < 64 then 
				local checkpos = ( ledge + self:GetUp()*-( height - 25 ) + self:GetForward()*60 )
				local enemy = self:GetEnemy()
				debugoverlay.Cross(checkpos,10,10)
				if self:VisibleVec(checkpos) then
					anim_key = "overrailing"
				else
					anim_key = "climbledgeup64"
				end
				
			elseif height < 96 then anim_key = "climbledgeup96"
			elseif height < 128 then anim_key = "climbledgeup128" end
			print(height)
			
			self:SetPos(ledge + self:GetForward()*-40 + self:GetUp()*-( height ))
			self:FaceTo(ledge)
			
			self:PlaySequenceAndMoveAbsolute( anim_key, 1, function( self, cycle) end)
			self:OverwriteState("Combat") 
		end
		
		return true
		
	end
	
	function ENT:CustomClimbing( climb, height )
		return true
	end
	
	function ENT:State_Fall()
		if !self:GetInState() then
			self:SetInState(true)
			
			local GroundDist = self:GroundDist( self:GetPos() + self:GetForward() * 30, 256 )
			local anim_key = "" 
			
			print(GroundDist)
			
			--self:SetVelocity( Vector( 0, 0, 0 ) )
			
			if GroundDist > 32 then anim_key = "fallledgedown64"
			elseif GroundDist > 96 then anim_key = "fallledgedown96"
			elseif GroundDist > 128 then anim_key = "fallledgedown128"
			elseif GroundDist > 192 then anim_key = "fallledgedown192"
			elseif GroundDist > 256 then anim_key = "fallledgedown256"
			end
			
			self:PlaySequenceAndMove( anim_key, 1, function( self, cycle) end)
			self:RemoveState("Combat_Walk") 
			
		end
	end
	
	----------------------------------------------------------------------------------------------------
	-- Events
	----------------------------------------------------------------------------------------------------
	
	function ENT:HandleAnimEvent(event, time, cycle, type, options)
		local event = string.Explode(" ", options)
		
		if event[1] == "attack" and IsValid(self:GetEnemy()) then
			if event[2] == "melee" then
				self:Attack({
				damage = math.random(15,20),
				angle = 90,
				range = 70,
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
			elseif event[2] == "melee_special" then
				if math.random(3) == 1 then self:AttackSounds() end
				self:Attack({
				damage = math.random(20,25),
				angle = 120,
				range = 70,
				type = DMG_SLASH,
				viewpunch = Angle(10, math.random(-5, 5), 0)
				},
				function(self, hit)
					if #hit > 0 then
						sound.Play("doom/monsters/melee_hit_" .. math.random(2) .. ".ogg",self:GetPos(),75, math.random(98,102))
					else
						sound.Play("npc/zombie/claw_miss" .. math.random(2) .. ".wav",self:GetPos(),65, math.random(98,102))
					end
				end)
			end
		elseif event[1] == "emit" then
		
			if event[2] == "step" then
				sound.Play("npc/zombie/foot"..math.random(3)..".wav",self:GetPos(),65, math.random(98,102) )
			elseif event[2] == "fall" then
			end
				
		end
		
	end
	
	----------------------------------------------------------------------------------------------------
	-- Death
	----------------------------------------------------------------------------------------------------
	
	function ENT:RX_CreateRagdoll( dmg, body)
	
		local ragdoll = ents.Create( "prop_ragdoll" )
		
		ragdoll:SetPos( self:GetPos() )
		ragdoll:SetAngles( self:GetAngles() )
		ragdoll:SetModel( self:GetModel() )
		
		if isnumber(body) then
			ragdoll:SetModel( self:GetModel() )
			if body ~= 0 then
				ragdoll:SetBodygroup( 0, 1 )
				ragdoll:SetBodygroup( body, 1 )
			end
		else
			ragdoll:SetModel( body )
		end
			
		ragdoll:SetOwner(self)
			
		ragdoll:Spawn()
		ragdoll:Activate()
		
		local phys = ragdoll:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity( VectorRand() * 80 + self:GetUp() * 100 + dmg:GetDamageForce() )
		end
		
		timer.Simple(5, function()
			ragdoll:Remove()
		end)
	
	end
	
	ENT.Tbl_Gore = {
	[0] = { BodyGroup = {},  }
	}
	
	function ENT:OnDeath( dmg, hitgroup )
		
		local damage = dmg:GetDamage()
		
		if damage < 150 and ( hitgroup ~= HITGROUP_HEAD ) then
			
			self:SetBodygroup( 0, 1 )
			
			if math.random(2) == 1 then
				--self:RX_CreateRagdoll( dmg, 3)
				self:RX_CreateRagdoll( dmg, 3)
				self:SetBodygroup( 4, 1 )
			else
				--self:RX_CreateRagdoll( dmg, 1)
				self:RX_CreateRagdoll( dmg, 1)
				self:SetBodygroup( 2, 1 )
			end
			
			self:PlayAnimationAndMove( "gore_death5_scientist_"..math.random(3), 1, function( self, cycle ) if cycle > 0.8 then self:BecomeRagdoll() return true end end)
			
		end
		
		self:BecomeRagdoll()
		
	end
	
	
else

	function ENT:CustomDraw()
	
		--self:SetIK(true)
	
		if self:HasEnemy() and IsValid(self:GetEnemy()) then
			local enemypos = self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter()
			self:BoneLook("Head", enemypos, 80, 60, 10, 0.5)
			self:BoneLook("Spine", enemypos, 40, 20, 10, 0.5)
		end
	end

end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)
