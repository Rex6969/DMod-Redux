if !DrGBase then return end

----------------------------------------------------------------------------------------------------
-- INCLUDE START
----------------------------------------------------------------------------------------------------

include("modules/server/dmod_sv_util.lua")
include("modules/server/dmod_sv_ai.lua")
include("modules/server/dmod_sv_anim.lua")
include("modules/server/dmod_sv_gore.lua")

include("modules/client/dmod_cl_util.lua")
AddCSLuaFile("modules/client/dmod_cl_util.lua")

include( "modules/dredux/server/ai_core.lua" )
include( "modules/dredux/rx_table_extension.lua" )
include( "modules/dredux/rx_anim.lua" )

----------------------------------------------------------------------------------------------------
-- INCLUDE END
----------------------------------------------------------------------------------------------------

ENT.Base = "ai_dmod_base"
ENT.PrintName = "Cyberdemon"
ENT.Category = "DOOM"

ENT.Models = { "models/doom/monsters/cyberdemon/cyberdemon.mdl" }
ENT.CollisionBounds = Vector( 60, 60, 250 )

ENT.StartHealth = 7000

ENT.MaxYawRate = 50
ENT.UseWalkframes = true

ENT.BehaviourType = AI_BEHAV_CUSTOM
ENT.Factions = {"FACTION_DOOM"}

ENT.Conditions = {}
ENT.State = ""

ENT.Stomp = {}
ENT.Stomp.damage = math.random( 20, 25 )
ENT.Stomp.angle = 180
ENT.Stomp.range = 350
ENT.Stomp.type = DMG_BLAST
ENT.Stomp.viewpunch = Angle( 20, 0, 0)

if SERVER then
	
	ENT.Tbl_Animations = {
	
		["Walk_N"] = {"walk_forward"},
		["Walk_W"] = {"walk_left"},
		["Walk_E"] = {"walk_right"},
		["Walk_S"] = {"walk_back"},
		
		["Turn_N"] = {""},
		["Turn_W"] = {"turn90left"},
		["Turn_E"] = {"turn90right"},
		["Turn_S"] = {"turn157left","turn157right"},
		
		["Turn_Aiming_N"] = {""},
		["Turn_Aiming_W"] = {"aiming_turn90left"},
		["Turn_Aiming_E"] = {"aiming_turn90right"},
		["Turn_Aiming_S"] = {"aiming_turn90right"}
		
	}
	
	
	function ENT:Precache() return end
	
	function ENT:OnSpawn() 
	
		self:SetIdleAnimation( "idle_aiming" )
		self:SetRunAnimation( "walk_forward" )
		
		self:SetState( "COMBAT_MOVING" )
		
		--self:ManipulateBoneAngles( self:LookupBone( "spine" ), Angle( 0, 90, 0 ) )
		
	end
	
	----------------------------------------------------------------------------------------------------
	
	function ENT:UpdateConditions() 
	
		local COND = self.Conditions
	
		if self:HasEnemy() then
		
			local Enemy = self:GetEnemy()
			local DistSqr = self:GetPos():DistToSqr( Enemy:GetPos() )
		
			COND["COND_HAS_ENEMY"] = true
			COND["COND_SEE_ENEMY"] = self:Visible( Enemy )
			
			COND["COND_CAN_MELEE_ATTACK"] = DistSqr < 350^2
			COND["COND_CAN_RANGE_ATTACK"] = ( DistSqr < 2000^2 && !COND["COND_CAN_MELEE_ATTACK"] )
			
		else
			COND["COND_HAS_ENEMY"] = false
		end
		
	end
	
	function ENT:HandleConditions( COND )

		if ( COND["COND_HAS_ENEMY"] && !COND["COND_IN_COMBAT"] ) then
		
			COND["COND_IN_COMBAT"] = true
			self:SetState( "ALERT" )
			
		elseif ( !COND["COND_HAS_ENEMY"] && COND["COND_IN_COMBAT"] ) then
		
			COND["COND_IN_COMBAT"] = false
			self:StopParticles()
			self:SetState( "IDLE" )
			
		end

		if self:HasEnemy() then
		
			local Enemy = self:GetEnemy()
			local EnemyPos = Enemy:GetPos()
			local Dist = Enemy:GetPos()
		
			--[[if self:IsRunning() and COND["COND_SEE_ENEMY"] then]] --end
			
			self.Next_Rocket = self.Next_Rocket || CurTime()
			if ( self.Next_Rocket < CurTime() && COND["COND_SEE_ENEMY"] && COND["COND_CAN_RANGE_ATTACK"] && self:FindInCone( Enemy, 50 ) ) then
			
				self:StopParticles()
				ParticleEffectAttach( "d_cyberdemon_rocket_explosion", PATTACH_POINT_FOLLOW, self, self:LookupAttachment( "weapon" ) )
				self:EmitSound( "doom/monsters/cyberdemon/CyberDemon_RocketLaunch_"..math.random( 4 )..".ogg", 80 )
				
				local rocket = self:CreateProjectile( "proj_dmod_cyberdemon_rocket" )
				rocket:SetPos( self:GetAttachment( self:LookupAttachment("weapon") ).Pos )
				rocket:SetAngles( ( EnemyPos - ( self:GetPos()+self:OBBCenter() ) ):Angle() )
				
				local force = self:AimProjectile( rocket, 800 )
				local phys = rocket:GetPhysicsObject()
				
				if IsValid( phys ) then
					rocket:SetVelocity( force - ( Enemy:GetVelocity() * math.random() ) + VectorRand() * 30 )
				end
				
				self.Next_Rocket = CurTime() + 0.25
				
			end
			
			self.Next_Melee = self.Next_Melee || CurTime()
			if ( self.Next_Melee < CurTime() && COND["COND_SEE_ENEMY"] && COND["COND_CAN_MELEE_ATTACK"] && self:FindInCone( Enemy, 90 ) ) then
			
				self:EmitSound( "doom/monsters/cyberdemon/cyberdemon_stomp.ogg", 80 )
				self:PlayAnimationAndMove( "stomp_front_into" )
				self:PlayAnimationAndMove( "stomp_front_attack" )
				self:PlayAnimationAndMove( "stomp_front_toidle" )
				
				self.Next_Melee = CurTime() + math.random( 10, 20 ) * 0.1
				
			end
			

		end
		
	end
	
	function ENT:PoseParameters( COND )
	
		if self:HasEnemy() and COND["COND_SEE_ENEMY"] then
			local Enemy = self:GetEnemy():GetPos()
			self:DirectPoseParametersAt( Enemy, "aim_pitch", "aim_yaw", self:GetPos() )
		end
	
	end

	----------------------------------------------------------------------------------------------------

	function ENT:State_IDLE()
		if ( !self:GetInState() ) then self:SetInState( true ) end
	end
	
	----------------------------------------------------------------------------------------------------
	
	function ENT:State_ALERT()
		if ( !self:GetInState() ) then self:SetInState( true ) end
		self:SetState( "COMBAT_MOVING" )
	end
	
	----------------------------------------------------------------------------------------------------

	function ENT:State_COMBAT_MOVING()
	
		if ( !self:GetInState() ) then self:SetIdleAnimation( "idle_aiming" ) self:SetInState( true ) end

		if not self:HasEnemy() then return end
		
		self.NextMovement = self.NextMovement || CurTime()
		if self.NextMovement < CurTime() and self:HasEnemy() then
		
			local Enemy = self:GetEnemy()
			local DistSqr = self:GetPos():DistToSqr( Enemy:GetPos() )
		
			if DistSqr < 2000^2 and self.Conditions["COND_SEE_ENEMY"] then
				local path = self:RecomputeSurroundPath( self:GetEnemy(), 750, 1200 )
				if path then 
					self:SetMovementTarget( path )
				end
			else
				self:SetMovementTarget( self:GetEnemy():GetPos() )
			end
			self.NextMovement = CurTime() + math.random( 5, 7 )
		end
		
		if ( self:GetMovementTarget() ) then
			if self:IsMoving() then self:FaceEnemy() end
			self:FollowPath( self:GetMovementTarget(), 300 )
		end
		
		self:Turn( "Aiming_" )
		
	end
	
	function ENT:Turn( add )
	
		if not self:GetMovementTarget() then return end

		self.Next_Turn = self.Next_Turn || CurTime()
		if self.Next_Turn < CurTime() and self:GetMovementTarget() then

			if ( self:HasEnemy() && self.Conditions["COND_CAN_SEE_ENEMY"] ) then self:SetMovementTarget( self:GetEnemy():GetPos() ) end
		
			add = add || ""
			local dir = self:CalcPosDirection( self:GetEnemy():GetPos() )
			local Anim_Key = !(dir == "N" || dir == "NE" || dir == "NW") && ( "Turn_"..add..dir ) || ""
			
			--print( dir, Anim_Key )
			
			if Anim_Key ~= "" then
				self:PlayAnimationAndMove( self:Table_ExtractAnimation( self.Tbl_Animations, Anim_Key ), 1, function()
					self:DirectPoseParametersAt( self:GetEnemy():GetPos(), "aim_pitch", "aim_yaw", self:GetPos() )
				end)
				self.NextMovement = CurTime() + math.random()
				self.Next_Turn = CurTime() + ( math.random( 5, 10 ) * 0.1 )
			end
			
		end

	end
	
	function ENT:OnUpdateAnimation()
		if self:IsDown() || self:IsDead() then return end
		if self:IsClimbingUp() then return self.ClimbUpAnimation, self.ClimbAnimRate
		elseif self:IsClimbingDown() then return self.ClimbDownAnimation, self.ClimbAnimRate
		elseif not self:IsOnGround() then return self.JumpAnimation, self.JumpAnimRate
		elseif self:IsRunning() then
		
			local Anim_Key = "Walk_"..self:CalcPosDirection( self:GetPos() + self:GetVelocity() )
			return self:Table_ExtractAnimation( self.Tbl_Animations, Anim_Key ), self.RunAnimRate
		
		elseif self:IsMoving() then return self.WalkAnimation, self.WalkAnimRate
		else return self.IdleAnimation, 1 end
		
	end
	
	function ENT:HandleAnimEvent(event, time, cycle, type, options)
	
		local event = string.Explode(" ", options)
		
		print( event[1], event[2], event[3] )
		
		if event[1] == "emit" then
			if event[2] == "step" then
			
				local step = event[3] == "left" && "L" || "R"
				self:EmitSound( "doom/monsters/cyberdemon/CyberDemonSteps_"..step.."_0"..math.random(4)..".ogg", 90 )
				util.ScreenShake( self:GetPos(), 30, 10, 0.5, 400 )
				
			end
			
		elseif event[1] == "attack" then
			
			if event[2] == "stomp" then
			
				ParticleEffectAttach( "d_cyberdemon_stomp", PATTACH_POINT_FOLLOW, self, self:LookupAttachment( "rightleg" ) )
				util.ScreenShake( self:GetPos(), 50, 10, 0.5, 400 )
				self:Attack(self.Stomp)
				
			end
			
		end
		
	end
	
else
	
end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)

local CyberdemonRocket = {}

	CyberdemonRocket.Type = "anim"
	CyberdemonRocket.Base = "proj_drg_default"
	
	CyberdemonRocket.Models = {"models/weapons/w_missile_launch.mdl"}
	CyberdemonRocket.Gravity = false
	CyberdemonRocket.OnContactEffects = {"d_cyberdemon_rocket_explosion"}
	CyberdemonRocket.OnContactDecals = {"FadingScorch"}
	CyberdemonRocket.OnContactDelete = 0
	
	function CyberdemonRocket:CustomInitialize()
		ParticleEffectAttach( "d_cyberdemon_rocket", 1, self, 0)
		self:DynamicLight( Color( 255, 120, 0 ), 400, 0.75 )
	end
	
	function CyberdemonRocket:OnContact( ent )
		self:EmitSound( "doom/monsters/cyberdemon/sfx_cyberdemon_burstRocket_explo_0"..math.random( 6 )..".ogg", 80, nil, nil )
		util.ScreenShake( self:GetPos(), 30, 10, 0.5, 100 )
		self:DealDamage( ent,  math.random( 10, 15 ), DMG_BLAST )
	end

	scripted_ents.Register( CyberdemonRocket, "proj_dmod_cyberdemon_rocket" )