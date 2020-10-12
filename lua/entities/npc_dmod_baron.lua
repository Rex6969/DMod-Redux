if !DrGBase then return end

----------------------------------------------------------------------------------------------------
-- Obsolete

include("modules/server/dmod_sv_util.lua")
include("modules/server/dmod_sv_ai.lua")
include("modules/server/dmod_sv_anim.lua")
include("modules/server/dmod_sv_gore.lua")

include("modules/client/dmod_cl_util.lua")
AddCSLuaFile("modules/client/dmod_cl_util.lua")

--include("modules/dmod_meta.lua")

----------------------------------------------------------------------------------------------------
-- INCLUDE START
----------------------------------------------------------------------------------------------------

include( "modules/dredux/server/ai_core.lua" )
include( "modules/dredux/server/dredux_gore.lua" )
include( "modules/dredux/rx_table_extension.lua" )

----------------------------------------------------------------------------------------------------
-- INCLUDE END
----------------------------------------------------------------------------------------------------

ENT.Base = "ai_dmod_base"

ENT.PrintName = "Baron of Hell"
ENT.Category = "DOOM"

ENT.StartHealth = 1500

ENT.Models = { "models/doom/monsters/baron/baron.mdl" }
ENT.CollisionBounds = Vector(35, 35, 145)

ENT.MaxYawRate = 150
ENT.UseWalkframes = true

ENT.BehaviourType = AI_BEHAV_CUSTOM
ENT.Factions = {"FACTION_DOOM","FACTION_BRUISER"}

--ENT.PossessionEnabled = true

ENT.Conditions = {}
ENT.State = ""

ENT.GibDamage = 100

if SERVER then
	
	ENT.Tbl_Animations = {
	
	["Charge_N"] = {"charge"},
	["Charge_NE"] = {"charge"},
	["Charge_NW"] = {"charge"},
	["Charge_W"] = {"charge_left"},
	["Charge_E"] = {"charge_right"},
	["Charge_S"] = {"charge_back"},
	
	["Melee_150"] = {"meleeforward_150_left","meleeforward_150_right"},
	["Melee_300"] = {"meleeforward_300_left","meleeforward_300_right"},
	["Melee_450"] = {"meleeforward_450_left","meleeforward_450_right"},
	
	["Charge_Leap"] = {"charge_leapattack1","charge_leapattack2","charge_leapattack3"},
	
	["Stand_Leap"] = {"charge_leapattack1"},
	
	["Melee_W"] = {"meleeleft"},
	["Melee_E"] = {"meleeright"},
	["Melee_S"] = {"meleeback"},
	
	["Ranged_N"] = {"throw",--[["throw_lefthand",]]"throw_righthand"},
	["Ranged_W"] = {"throw_left"},
	["Ranged_E"] = {"throw_right"},
	
	["Turn_N"] = {""},
	["Turn_W"] = {"turn90left"},
	["Turn_E"] = {"turn90right"},
	["Turn_S"] = {"turn157left"},
	
	["Melee_Moving"] = {"meleeforward_charge1"},
	
	["Pain_N"] = {"pain_leftarm", "pain_rightarm"},
	["Pain_W"] = {"pain_left"},
	["Pain_E"] = {"pain_right"},
	["Pain_S"] = {"pain_left","pain_right"},
	
	["Pain_Charge_N"] = {"pain_charge_head", "pain_charge_leftarm", "pain_charge_rightarm"},
	
	}

	function ENT:Precache()
		util.PrecacheModel( "models/doom/monsters/baron/baron.mdl" )
	end
	
	----------------------------------------------------------------------------------------------------
	
	function ENT:OnSpawn()
	
		self:EmitSound( "doom/monsters/baron/baron_sight_"..math.random(2)..".ogg", 90 )
		self:PlayAnimationAndWait( "spawn_teleport2" )
		
		self:SetCooldown( "NEXT_Wander", math.random(10,40)*0.1 )
		self:SetCooldown( "NEXT_LeapAttack", math.random( 30, 50 )*0.1 ) 
		
		self.Num_MFailed = 0
		
		self.EnableFocusTracking = true
		
		self:SetState( "IDLE" )
		
		self:SetIdleAnimation( "idle" )
		self:SetWalkAnimation( "walk" )
	
	end
	
	----------------------------------------------------------------------------------------------------

	function ENT:AIBehaviour()
	
		self:UpdateConditions()
		self:HandleConditions()
		
		self:UpdateState()
	end

	
	----------------------------------------------------------------------------------------------------
	
	function ENT:UpdateConditions()
	
		if !SERVER then return end

		if self:GetCooldown( "NEXT_UpdateConditions" ) <= 0 then

			local COND = self.Conditions
			
			if ( self:HasEnemy() ) then
			
				COND["COND_HAS_ENEMY"] = true
				
				local Enemy = self:GetEnemy()
				local DistSqr = self:GetPos():DistToSqr( Enemy:GetPos() )
				
				COND["COND_CAN_MELEE_ATTACK"] = ( DistSqr < 450*450 )
				COND["COND_CAN_RANGE_ATTACK"] = ( !COND["COND_CAN_MELEE_ATTACK"] && DistSqr < 1500*1500 )
				COND["COND_CAN_LEAP_ATTACK"] = ( DistSqr < 750*750 )
				
				COND["COND_CAN_SEE_ENEMY"] = self:Visible( Enemy )
				
				COND["COND_MOVING"] = self:IsMoving()
				
				COND["COND_CAN_FOCUS_TRACK"] = ( ( COND["COND_CAN_MELEE_ATTACK"] || COND["COND_CAN_RANGE_ATTACK"] ) && COND["COND_CAN_SEE_ENEMY"] && self:IsInCone( Enemy, 270 ) && self.EnableFocusTracking )
				
			else
			
				COND["COND_HAS_ENEMY"] = false
				
				COND["COND_CAN_FOCUS_TRACK"] = false
				COND["COND_CAN_MELEE_ATTACK"] = false
				COND["COND_CAN_LEAP_ATTACK"] = false
				
				COND["COND_CAN_RANGE_ATTACK"] = false
				
				
			end
			
			self:SetCooldown( "NEXT_UpdateConditions", 0.2 )
			
		end
		
	end
	
	function ENT:HandleConditions()
	
		if !SERVER then return end
	
		local COND = self.Conditions
		
		if ( COND["COND_HAS_ENEMY"] && !COND["COND_IN_COMBAT"] ) then
		
			COND["COND_IN_COMBAT"] = true
			self:SetState( "COMBAT" )
			
		elseif ( !COND["COND_HAS_ENEMY"] && COND["COND_IN_COMBAT"] ) then
		
			COND["COND_IN_COMBAT"] = false
			self:StopParticles()
			self:SetState( "IDLE" )
			
		end
		
		if ( self:GetCooldown( "NEXT_FocusTrackUpdate" ) <= 0 ) then
			self:SetNWBool( "CAN_FOCUS_TRACK", COND["COND_CAN_FOCUS_TRACK"] )
			self:SetCooldown( "NEXT_FocusTrackUpdate", 0.5 )
		end
		
		local Enemy = self:GetEnemy()
		
		----------------------------------------------------------------------------------------------------
		
		if IsValid( Enemy ) then
		
			if ( COND["COND_CAN_MELEE_ATTACK"] && COND["COND_CAN_SEE_ENEMY"] && !(self.Num_MFailed >= 3  && math.random( 2 ) == 1 ) ) then
			
				if self:GetCooldown( "NEXT_MeleeAttack" ) <= 0 then
				
					local DistSqr = self:GetPos():DistToSqr( Enemy:GetPos() )
					local Anim_Key = ""
					
					if DistSqr < 200^2 then
						local dir = self:CalcPosDirection( Enemy:GetPos() )
						Anim_Key = ( dir == "N" ) && "Melee_150" || "Melee_"..dir
					elseif self:FindInCone( Enemy, 45 ) then
						Anim_Key = ( DistSqr <= 300^2 ) && "Melee_300" || "Melee_450"
						self:FaceEnemy()
					end
					
					if Anim_Key then
						self:EmitSound( "doom/monsters/baron/vo_baron_melee_" .. math.random(3) .. ".ogg", 75 )
					end
					
					self:PlayAnimationAndMove( self:Table_ExtractAnimation( self.Tbl_Animations, Anim_Key ), nil, function( self, cycle )
						if cycle > 0.35 && cycle < 0.5 then self:FaceEnemy() end
					end)
					
					self:SetCooldown( "NEXT_MeleeAttack", 0.5 ) 
					
				end
			
			end
				
			----------------------------------------------------------------------------------------------------
				
			if ( COND["COND_CAN_LEAP_ATTACK"] && COND["COND_CAN_SEE_ENEMY"] ) then
			
				if self:GetCooldown( "NEXT_LeapAttack" ) <= 0 || self.Num_MFailed >= 5 then
				
					local DistSqr = self:GetPos():DistToSqr( Enemy:GetPos() )
					
					local Anim_Key = self:FindInCone( Enemy, 30 ) && ( self:IsMoving() && "Charge_Leap" || "Stand_Leap" ) || ""
					
					--self:FaceEnemy()
					
					self:SetVelocity( Vector( 0, 0, 0 ) )
					self:SetNWBool( "CAN_FOCUS_TRACK", false )
					self:PlayAnimationAndMove( self:Table_ExtractAnimation( self.Tbl_Animations, Anim_Key ), nil, function( self, cycle )
						if cycle < 0.1 then self:FaceEnemy() end
					end)
					
					self:SetCooldown( "NEXT_LeapAttack", math.random( 30, 50 )*0.1 ) 
					
				end
				
			end
				
			----------------------------------------------------------------------------------------------------
				
			if ( COND["COND_CAN_RANGE_ATTACK"] && COND["COND_CAN_SEE_ENEMY"] ) then
			
				if self:GetCooldown( "NEXT_RangeAttack" ) <= 0 then
				
					local InRangeAttackCone = self:FindInCone( Enemy, 270 )
				
					local Anim_Key = InRangeAttackCone && ( "Ranged_"..self:CalcPosDirection( Enemy:GetPos() ) ) || ""
					if Anim_Key then self:SetVelocity( Vector( 0, 0, 0 ) ) end
					
					self:PlayAnimationAndMove( self:Table_ExtractAnimation( self.Tbl_Animations, Anim_Key ), nil, function( self, cycle )
						if cycle > 0.5 then self:FaceEnemy() end
					end)
					
					if Anim_Key then 
						self:SetCooldown( "NEXT_RangeAttack", math.random( 10, 40 )*0.1 ) 
						self:SetCooldown( "NEXT_LeapAttack", math.random( 5, 20 )*0.1 ) 
						self:DelayAllyRangeAttack()
					end
				
				end
				
			end
			
			if ( self:GetCooldown( "NEXT_Turn" ) <= 0 ) then
				self:Turn()
			end
		
			
		end
		
	end
	
	----------------------------------------------------------------------------------------------------

	function ENT:State_IDLE()
	
		if ( !self:GetInState() ) then self:SetInState( true ) end
	
		if ( self:GetCooldown( "NEXT_Wander" ) <= 0 ) then
		
			self:SetMovementTarget( self:RX_RandomPos( self, 500, 600 ) )
			
			self:SetCooldown( "NEXT_Wander", math.random( 70, 90 )*0.1 )
			
			self:Turn()
			
		end
	
		local targ = self:GetMovementTarget()
		if targ then self:FollowPath( targ, 200 ) end
	
	end
	
	function ENT:State_COMBAT()
	
		if ( !self:GetInState() ) then self:SetInState( true ) end
	
		if not self:HasEnemy() then return end
		self:SetMovementTarget( self:GetEnemy():GetPos() )
		local targ = self:GetMovementTarget()
		if targ then self:FollowPath( targ, 100 ) end
	
	end
	
	----------------------------------------------------------------------------------------------------
	
	function ENT:HandleAnimEvent(event, time, cycle, type, options)
		local event = string.Explode(" ", options)
		
		local Enemy = self:GetEnemy()
		
		if ( event[1] == "attack" ) && IsValid( Enemy ) then
		
			if event[2] == "melee" then
			
				self:Attack({
				damage = math.random( 30, 35 ),
				angle = 160,
				range = 154,
				type = DMG_SLASH,
				viewpunch = Angle(8, math.random(-5, 5), 0)
				},
				function(self, hit)
					if #hit > 0 then
						sound.Play("doom/monsters/melee_hit_" .. math.random(2) .. ".ogg",self:GetPos(), 75,math.random(98,102))
						self.Num_MFailed = 0
					else
						sound.Play("npc/zombie/claw_miss" .. math.random(2) .. ".wav",self:GetPos(), 65,math.random(98,102))
						self.Num_MFailed = self.Num_MFailed + 1
					end
				end)
				
			elseif event[2] == "melee_special" then

				self:Attack({
				damage = math.random( 30, 40 ),
				angle = 360,
				range = 150,
				type = DMG_BLAST,
				viewpunch = Angle(20, math.random(-10, 10), 0)
				})
				
				self:SetVelocity( self:GetUp()* -300 )
				
				self:StopParticles()
				ParticleEffect("d_baron_shockwave", self:GetPos() + self:GetForward()*90, self:GetAngles() )
				
				util.ScreenShake( self:GetPos(), 50, 5, 0.5, 600 )
				
				self.Num_MFailed = 0
				self.Conditions["COND_IN_AIR"] = false
				
				self:EmitSound( "doom/monsters/baron/groundpound" .. math.random(5) .. ".ogg", 80 )
				
			elseif event[2] == "ranged" then

				local att = event[3].."hand"
				
				self:StopParticles()
				self:EmitSound( "doom/monsters/baron/throw_fireball.ogg", 85 )
				
				local fireball = self:CreateProjectile( "proj_dmod_baron_fireball" )
				fireball:SetPos( self:GetAttachment( self:LookupAttachment(att) ).Pos )
				
				local force = self:AimProjectile( fireball, 1200 )
				local add = ( Enemy:GetVelocity():Length() > 200 ) && 100 || 0
				local phys = fireball:GetPhysicsObject()
				
				if IsValid( phys ) then
					fireball:SetVelocity( force + Enemy:GetVelocity()*0.25 + VectorRand()*add )
				end
				
			end
			
		elseif ( event[1] == "emit" ) then
		
			if ( event[2] == "step" ) then
			
				self:EmitSound( "doom/monsters/pinky/pinky_step"..math.random(4)..".ogg", 70 )
				--[[if ( event[3] == "left" ) then
					ParticleEffectAttach("d_step_dust_medium",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("rig_leg_left_target"))
				else
					ParticleEffectAttach("d_step_dust_medium",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("rig_leg_right_target"))
				end]]
				
			elseif ( event[2] == "fall") then
			
				ParticleEffectAttach("d_step_dust_medium",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("rig_leg_right_target"))
				ParticleEffectAttach("d_step_dust_medium",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("rig_leg_left_target"))
				self:EmitSound( "doom/monsters/pinky/pinky_step"..math.random(4)..".ogg", 70 )
				
			elseif ( event[2] == "fireleft" ) then
			
				ParticleEffectAttach("d_baron_fireball",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("lefthand"))
				
			elseif ( event[2] == "fireright" ) then
			
				ParticleEffectAttach("d_baron_fireball",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("righthand"))
				
			end
		
			
		elseif ( event[1] == "jump" ) && IsValid( Enemy ) then
	
			local EnemyDist = self:GetPos():Distance( Enemy:GetPos() )
		
			if ( event[2] == "leap_start"  ) then
				
				self:EmitSound( "doom/monsters/baron/jump.ogg" )
				
				self.Conditions["COND_IN_AIR"] = true
				
				self:LeaveGround()
				self:SetVelocity( self:GetUp()*500 + self:GetForward()*EnemyDist*0.5 )
			
			elseif ( event[2] == "leap_highest" ) then
			
				local Enemy = self:GetEnemy()
				if not IsValid( Enemy ) then return end
				local Dist = self:GetPos():Distance( Enemy:GetPos() )
				self:SetVelocity( self:GetUp()* -300 + self:GetForward()*EnemyDist*0.5 )
			
			end
		
		end
		
		--print( event[1], " ", event[2] )
		
	end
	
	----------------------------------------------------------------------------------------------------
	
	function ENT:Turn()
	
		if not self:GetMovementTarget() then return end

		if ( self:HasEnemy() && self.Conditions["COND_CAN_SEE_ENEMY"] ) then self:SetMovementTarget( self:GetEnemy():GetPos() ) end
	
		local dir = self:CalcPosDirection( self:GetMovementTarget() )
		local Anim_Key = !(dir == "N" || dir == "NE" || dir == "NW") && ( self:IsRunning() && "Turn_Charge_"..dir || "Turn_"..dir ) || ""
		if Anim_Key ~= "" then
			self:SetCooldown( "NEXT_Turn", math.random( 5, 15 ) * 0.1 )
			self:PlayAnimationAndMove( self:Table_ExtractAnimation( self.Tbl_Animations, Anim_Key ) )
		end

	end
	
	----------------------------------------------------------------------------------------------------
	
	function ENT:DeathSounds()
		self:SetSkin( 1 )
	end
	
	local HITGROUP_HEAD = 8
	
	function ENT:OnTakeDamage( dmg, hitgroup )
		
		if self:Health() < 600 then self:SetSkin( 1 ) end
		
		self:Death( dmg, hitgroup )
		
		if ( dmg:GetDamage() > 100 && self:GetCooldown( "NEXT_Pain" ) <= 0 && math.random( 3 ) == 1 && !self:IsDead() ) then

			self:StopParticles()
			
			self:SetSkin( 1 )
			self:DOOM_ApplyWound( "Head" )
			self:DOOM_ApplyWound( "Body" )
			self:DOOM_ApplyWound( "LeftArm" )
			self:DOOM_ApplyWound( "RightArm" )
			self:DOOM_ApplyWound( "LeftLeg" )
			self:DOOM_ApplyWound( "RightLeg" )
		
			if !self.Conditions["COND_IN_AIR"] then
				if ( self:IsRunning() ) then
					self:CallInCoroutineOverride( function() self:PlayAnimationAndMove( self:Table_ExtractAnimation( self.Tbl_Animations, "Pain_Charge_N" ), 1 ) end )
				else
					self:CallInCoroutineOverride( function() self:PlayAnimationAndMove( self:Table_ExtractAnimation( self.Tbl_Animations, "Pain_"..self:CalcPosDirection( dmg:GetDamagePosition() ) ), 1 ) end )
				end
			end
			
			self:SetCooldown( NEXT_Pain, math.random( 30, 45 ) * 0.1 )
			
		end
		
	end
	
	function ENT:Death(dmg, hitgroup)
		if dmg:GetDamage() > self:Health() and self:Alive() then
			self:SetNW2Bool("DrGBaseDead", true)
			self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			if dmg:GetDamage() >= self.GibDamage or dmg:GetDamageType() == DMG_BLAST then
				self:HandleDeath( dmg, hitgroup )
			else
				self:DeathSounds()
				local ragdoll = self:RX_RagdollDeath( dmg )
				ragdoll:DOOM_ApplyWound( "Head" )
				ragdoll:DOOM_ApplyWound( "Body" )
				ragdoll:DOOM_ApplyWound( "LeftArm" )
				ragdoll:DOOM_ApplyWound( "RightArm" )
				ragdoll:DOOM_ApplyWound( "LeftLeg" )
				ragdoll:DOOM_ApplyWound( "RightLeg" )
				
			end
		end
	
	end
	
	function ENT:HandleDeath( dmg, hitgroup )
	
		local Anim_Key
		local hitgroup = self:RX_Damage_FixHitGroup( dmg, hitgroup )
		local changedmodel = false
	
		self:SetSkin( 1 )
		self:StopParticles()
		
		self:SetNWBool( "CAN_FOCUS_TRACK", false )
		
		if hitgroup == 8 then
			self:SetModel( "models/doom/monsters/baron/gore/baron_death2_body.mdl" )
			changedmodel = true
			self:SetSkin( 1 )
			self:RX_GenericGibs( dmg, 10, Vector( 0, 0, 70 ) )
			Anim_Key = "death_classic_head"
		else
			self:SetModel( "models/doom/monsters/baron/gore/baron_death7_body.mdl" )
			changedmodel = true
			self:SetSkin( 1 )
			self:RX_GenericGibs( dmg, 13, Vector( 0, 0, 20 )  )
			Anim_Key = self:Table_Get( {"death_classic_gut", "death_classic_chest"} )
		end
		
		if ( Anim_Key && !self.Conditions["COND_IN_AIR"] ) then 
			self:CallInCoroutineOverride( function() 
				self:PlayAnimationAndMove( Anim_Key, 1 ) 
				local ragdoll = self:RX_RagdollDeath()
			end )
		end
		
	end
	
	----------------------------------------------------------------------------------------------------
	
	function ENT:OnUpdateAnimation()
		if self:IsDown() || self:IsDead() then return end
		if self:IsClimbingUp() then return self.ClimbUpAnimation, self.ClimbAnimRate
		elseif self:IsClimbingDown() then return self.ClimbDownAnimation, self.ClimbAnimRate
		elseif not self:IsOnGround() then return self.JumpAnimation, self.JumpAnimRate
		elseif self:IsRunning() then

			local Anim_Key = "Charge_"..self:CalcPosDirection( self:GetPos() + self:GetVelocity() )
			return self:Table_ExtractAnimation( self.Tbl_Animations, Anim_Key ), self.RunAnimRate
		
		elseif self:IsMoving() then return self.WalkAnimation, self.WalkAnimRate
		else return self.IdleAnimation, 1 end
	end
	
	function ENT:BodyMoveXY( options )
		local velocity = self:GetVelocity()
		return ( !self:IsPlayingAnimation() && self:IsOnGround() && !self:IsClimbing() && !velocity:IsZero() ) && self:SetPlaybackRate(1) || true
	end
	
	function ENT:DelayAllyRangeAttack()
		local allies = self:GetAlliesInSight( spotted )
		for k,v in pairs( allies ) do
			if v:GetClass() == "npc_dmod_baron" then
				v:SetCooldown( "NEXT_RangeAttack", math.random( 5, 10 ) * 0.1 )
			end
		end
	end
	
else

end

function ENT:CustomThink()

	local CanFocusTrack = self:GetNWBool( "CAN_FOCUS_TRACK", false )
	
	if ( CLIENT && !self:IsDead() ) then
	
		if ( CanFocusTrack && self:HasEnemy() && !self:IsAIDisabled() ) then
			local EnemyPos = self:GetEnemy():GetPos()
			
			self:BoneLook("head", EnemyPos, 60, 30, 6, 0.5)
			self:BoneLook("spine", EnemyPos, 30, 60, 2, 0.5)
			
		else
		
			self:ResetManipulateBoneAngles( "head" )
			self:ResetManipulateBoneAngles( "spine" )
			
		end
		
	end
	
end

local BaronProjectile = {}

	BaronProjectile.Type = "anim"
	BaronProjectile.Base = "proj_drg_default"
	
	BaronProjectile.Gravity = false
	BaronProjectile.AttachEffects = {"d_baron_fireball"}
	BaronProjectile.OnContactEffects = {"d_baron_fireballexplosion"}
	BaronProjectile.OnContactDecals = {"Scorch"}
	BaronProjectile.OnContactDelete = 0
	
	
	function BaronProjectile:CustomInitialize()
		self:DynamicLight( Color( 0, 255, 0 ), 300, 0.5 )
	end
	
	function BaronProjectile:OnContact( ent )
		self:EmitSound( "doom/monsters/baron/sfx_baron_fireball"..math.random( 5 )..".ogg", 90 )
		util.ScreenShake( self:GetPos(), 5, 5, 0.5, 200 )
		self:DealDamage( ent, ( ent:IsPlayer() && math.random( 34, 35 ) || math.random( 34, 35 )*2 ), DMG_BLAST )
	end

	scripted_ents.Register( BaronProjectile, "proj_dmod_baron_fireball" )


AddCSLuaFile()
DrGBase.AddNextbot(ENT)