if not DrGBase then return end

----------------------------------------------------------------------------------------------------

include("modules/server/dmod_sv_util.lua")
include("modules/server/dmod_sv_ai.lua")
include("modules/server/dmod_sv_anim.lua")

include("modules/client/dmod_cl_util.lua")
AddCSLuaFile("modules/client/dmod_cl_util.lua")

include("modules/dmod_meta.lua")

----------------------------------------------------------------------------------------------------

ENT.Base = "drgbase_nextbot"
DEFINE_BASECLASS( "drgbase_nextbot" )

ENT.PrintName = "Baron of Hell"
ENT.Category = "DOOM"

ENT.Models = { "models/doom/monsters/baron/baron.mdl" }
ENT.CollisionBounds = Vector(35, 35, 145)

ENT.MaxYawRate = 200
ENT.UseWalkframes = true

ENT.BehaviourType = AI_BEHAV_CUSTOM
ENT.Factions = {"FACTION_DOOM","FACTION_BRUISER"}

--ENT.PossessionEnabled = true

local baron_Health = 1750

ENT.Conditions = {}

if SERVER then
	
	ENT.Tbl_State = {}
	
	ENT.Tbl_Animations = {
	
	["Charge_N"] = {"charge"},
	["Charge_NE"] = {"charge"},
	["Charge_NW"] = {"charge"},
	["Charge_E"] = {"charge_left"},
	["Charge_W"] = {"charge_right"},
	["Charge_S"] = {"charge_back"},
	
	["Melee_150"] = {"meleeforward_150_left","meleeforward_150_right"},
	["Melee_300"] = {"meleeforward_300_left","meleeforward_300_right"},
	["Melee_450"] = {"meleeforward_450_left","meleeforward_450_right"},
	
	["Charge_Leap"] = {"charge_leapattack1","charge_leapattack2","charge_leapattack3"},
	
	["Stand_Leap"] = {"charge_leapattack1"},
	
	["Melee_W"] = {"meleeleft"},
	["Melee_E"] = {"meleeright"},
	["Melee_S"] = {"meleeback"},
	
	["Ranged_N"] = {"throw","throw_lefthand","throw_righthand"},
	["Ranged_W"] = {"throw_left"},
	["Ranged_E"] = {"throw_right"},
	
	["Turn_N"] = {""},
	["Turn_W"] = {"turn90left"},
	["Turn_E"] = {"turn90right"},
	["Turn_S"] = {"turn157left"},
	
	
	
	["Melee_Moving"] = {"meleeforward_charge1"}
	
	}

	function ENT:Precache()
		--util.PrecacheModel( "models/doom/monsters/baron/baron.mdl" )
	end
	
	----------------------------------------------------------------------------------------------------

	function ENT:CustomInitialize()
		
		self:Precache()
		
		self:SetDefaultRelationship( D_HT )
		
		--self:SetHullType( HULL_LARGE )
		
		self:SetHealth( baron_Health )
		self:SetMaxHealth( baron_Health )
		
		self:SetIdleAnimation( "idle" )
		self:SetWalkAnimation( "walk" )
		self:SetRunAnimation( "Charge" )
		
		self.EnableFocusTracking = true
		
	end
	
	function ENT:OnSpawn()
	
		self:EmitSound( "doom/monsters/baron/baron_sight_"..math.random(2)..".ogg", 90 )
		self:PlayAnimationAndWait( "spawn_teleport2" )
		
		self:SetCooldown( "NEXT_Wander", math.random(10,40)*0.1 )
		self:SetCooldown( "NEXT_LeapAttack", math.random( 30, 50 )*0.1 ) 
		
		self.Num_MFailed = 0
		
		self:OverwriteState( "IDLE" )
	
	end
	
	----------------------------------------------------------------------------------------------------

	function ENT:AIBehaviour()
	
		self:UpdateConditions()
		self:HandleConditions()
		
		self:UpdateState( 1 )
		
		--print("fuck")
		
		--PrintTable( self.Conditions )
		--print("")
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
				print( COND["COND_CAN_FOCUS_TRACK"] )
				
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
			self:OverwriteState( "COMBAT" )
			
		elseif ( !COND["COND_HAS_ENEMY"] && COND["COND_IN_COMBAT"] ) then
		
			COND["COND_IN_COMBAT"] = false
			self:StopParticles()
			self:OverwriteState( "IDLE" )
			
		end
		
		if ( self:GetCooldown( "NEXT_FocusTrackUpdate" ) <= 0 ) then
			self:SetNWBool( "CAN_FOCUS_TRACK", COND["COND_CAN_FOCUS_TRACK"] )
			self:SetCooldown( "NEXT_FocusTrackUpdate", 0.5 )
		end
		
		if ( self:GetCooldown( "NEXT_Turn" ) <= 0 ) then
			self:Turn()
		end
		
		local Enemy = self:GetEnemy()
		
		----------------------------------------------------------------------------------------------------
		
		if IsValid( Enemy ) then
		
			if ( COND["COND_CAN_MELEE_ATTACK"] && COND["COND_CAN_SEE_ENEMY"] && !(self.Num_MFailed >= 3  && math.random( 2 ) == 1 ) ) then
			
				if self:GetCooldown( "NEXT_MeleeAttack" ) <= 0 then
				
					local DistSqr = self:GetPos():DistToSqr( Enemy:GetPos() )
					local InMeleeAttackCone = self:FindInCone( Enemy, 45 )
					local Anim_Key = ""
					
					if DistSqr < 200^2 then
						local dir = self:CalcPosDirection( Enemy:GetPos() )
						Anim_Key = ( dir == "N" ) && "Melee_150" || "Melee_"..dir
					elseif InMeleeAttackCone then
						Anim_Key = ( DistSqr <= 300^2 ) && "Melee_300" || "Melee_450"
						self:FaceEnemy()
					end
					
					if Anim_Key then
						self:EmitSound( "doom/monsters/baron/vo_baron_melee_" .. math.random(3) .. ".ogg", 75 )
					end
					
					self:PlayAnimationAndMove( self:ExtractAnimation( self.Tbl_Animations, Anim_Key ), nil, function( self, cycle )
						if cycle > 0.35 && cycle < 0.5 then self:FaceEnemy() end
					end)
					
					self:SetCooldown( "NEXT_MeleeAttack", 0.5 ) 
					
					self:Turn()
					
				end
			
			end
				
			----------------------------------------------------------------------------------------------------
				
			if ( COND["COND_CAN_LEAP_ATTACK"] && COND["COND_CAN_SEE_ENEMY"] ) then
			
				if self:GetCooldown( "NEXT_LeapAttack" ) <= 0 || self.Num_MFailed >= 5 then
				
					local DistSqr = self:GetPos():DistToSqr( Enemy:GetPos() )
					local InMeleeAttackCone = self:FindInCone( Enemy, 30 )
					
					local Anim_Key = InMeleeAttackCone && ( self:IsMoving() && "Charge_Leap" || "Stand_Leap" ) || ""
					
					--self:FaceEnemy()
					
					self:SetVelocity( Vector( 0, 0, 0 ) )
					self:SetNWBool( "CAN_FOCUS_TRACK", false )
					self:PlayAnimationAndMove( self:ExtractAnimation( self.Tbl_Animations, Anim_Key ), nil, function( self, cycle )
						if cycle < 0.1 then self:FaceEnemy() end
					end)
					
					self:SetCooldown( "NEXT_LeapAttack", math.random( 30, 50 )*0.1 ) 
					
					self:Turn()
					
				end
				
			end
				
			----------------------------------------------------------------------------------------------------
				
			if ( COND["COND_CAN_RANGE_ATTACK"] && COND["COND_CAN_SEE_ENEMY"] ) then
			
				if self:GetCooldown( "NEXT_RangeAttack" ) <= 0 then
				
					local InRangeAttackCone = self:FindInCone( Enemy, 270 )
				
					local Anim_Key = InRangeAttackCone && ( "Ranged_"..self:CalcPosDirection( Enemy:GetPos() ) ) || ""
					self:PlayAnimationAndMove( self:ExtractAnimation( self.Tbl_Animations, Anim_Key ), nil, function( self, cycle )
						if cycle > 0.5 then self:FaceEnemy() end
					end)
					
					if Anim_Key then 
						self:SetCooldown( "NEXT_RangeAttack", math.random( 10, 40 )*0.1 ) 
						self:SetCooldown( "NEXT_LeapAttack", math.random( 5, 20 )*0.1 ) 
						self:DelayAllyRangeAttack()
					end
					
					self:Turn()
				
				end
				
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
				
				local fireball = self:CreateProjectile( "ent_dmod_baron_fireball" )
				fireball:SetPos( self:GetAttachment( self:LookupAttachment(att) ).Pos )
				
				local force = self:AimProjectile( fireball, 1200 )
				local add = ( Enemy:GetVelocity():Length() > 200 ) && 100 || 0
				local phys = fireball:GetPhysicsObject()
				
				if IsValid( phys ) then
					fireball:SetVelocity( force + Enemy:GetVelocity()*0.1 + VectorRand()*add )
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
		
		print( event[1], " ", event[2] )
		
	end
	
	----------------------------------------------------------------------------------------------------
	
	function ENT:Turn()
	
		if not self:GetMovementTarget() then return end
	
		local dir = self:CalcPosDirection( self:GetMovementTarget() )
		local Anim_Key = !(dir == "N" || dir == "NE" || dir == "NW") && ( self:IsRunning() && "Turn_Charge_"..dir || "Turn_"..dir ) || ""
		if Anim_Key ~= "" then
			self:SetCooldown( "NEXT_Turn", math.random( 5, 15 ) * 0.1 )
			self:PlayAnimationAndMove( self:ExtractAnimation( self.Tbl_Animations, Anim_Key ) )
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
			return self:ExtractAnimation( self.Tbl_Animations, Anim_Key ), self.RunAnimRate
		
		elseif self:IsMoving() then return self.WalkAnimation, self.WalkAnimRate
		else return self.IdleAnimation, 1 end
	end
	
	function ENT:BodyMoveXY( options )
	
		local velocity = self:GetVelocity()
		local options = options || {}
		if options.rate == nil then options.rate = true end
	
		if ( options.rate && !self:IsPlayingAnimation() && self:IsOnGround() && !self:IsClimbing() ) then
			if not velocity:IsZero() then
				self:SetPlaybackRate(1)
			end
		end
	
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
	
	--print( CanFocusTrack )

	if ( CLIENT ) then
	
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


AddCSLuaFile()
DrGBase.AddNextbot(ENT)