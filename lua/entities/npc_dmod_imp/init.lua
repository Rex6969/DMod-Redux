if !CPTBase or (CLIENT) then return end

AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.Model = "models/doom/monsters/imp/imp.mdl"
ENT.Skin = 0

ENT.ViewAngle = 90
ENT.StartHealth = 150
ENT.ProcessingTime = 0.2

-- AI 

ENT.i_CurrentState = 0

ENT.i_Behavior = 0

ENT.i_MeleeDmg = 8
ENT.t_NextMeleeAttack = CurTime()

ENT.b_InChargeAttack = false
ENT.t_NextRangedAttack = CurTime()
ENT.t_ChargeRelease = CurTime()

ENT.t_NextWander = CurTime()
ENT.t_NextPath = CurTime()

ENT.t_NextIdleSound = CurTime()

ENT.i_MinDist = 400
ENT.i_MaxDist = 900
ENT.i_CloseDist = 250

local STATE_NONE = 0
local STATE_IDLE = 1
local STATE_ALERT = 2 -- Unused
local STATE_COMBAT = 3

local STATE_STAGGER = 1000
local STATE_ON_WALL = 1001
---------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:SetInit()

	self:SetModel(self.Model)
	self:SetBodygroup(0,self.Skin)
	self:SetHullType(HULL_WIDE_HUMAN)
	self:SetCollisionBounds(Vector(-18,-18,1),Vector(18,18,60))
	
	self:SetNoDraw(false)

	self:SetIdleAnimation("idle_combat")
	self:SetRunAnimation("run_all")
	self:SetWalkAnimation("walk_forward")

	self:SetState(NPC_STATE_IDLE)
	self:Select_AIType()
	
	--self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP)) Not yet
	self:CapabilitiesAdd(bit.bor(CAP_SQUAD))
	
	self:PlayActivity("spawn_teleport_1")
	
	self.t_NextIdleSound = CurTime() + math.Rand(3,8)
	
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- AI Module
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:OnThink()

	if self.IsPossessed then return end

	if IsValid(self:GetEnemy()) then

		enemy = self:GetEnemy()
		enemypos = self:GetEnemy():GetPos()
		dist = self:FindCenterDistance(enemy)
		nearest = self:GetClosestPoint(enemy)
	
	end
	
	debugoverlay.Box(self:GetPos(),Vector(-18,-18,1),Vector(18,18,55),0.15,Color(255,255,255,0))
	debugoverlay.Sphere(self:GetCurWaypointPos(),5,5,Color(255,255,0,0))
	
	-- Idle state

	if ( self:State(STATE_IDLE) ) then
		
		if IsValid(enemy) then
		
			self:SetState(STATE_COMBAT)
		
		end
		
		if ( self.t_NextIdleSound < CurTime() ) and ( math.random(1,8) == 1 ) then
			
			sound.Play( "doom/monsters/imp/imp_idle"..math.random(1,4)..".ogg",self:GetPos(), 70, math.random(98,102) ) 
			self.t_NextIdleSound = CurTime() + math.Rand(3,8)
				
		end 
		
		self:SetIdleAnimation("idle_combat")
		self:SetWalkAnimation("walk_forward")
		if not self:IsMoving() and self:CanPerformProcess() then
			self:StartIdleAnimation()
		end
		
		
		self:SetMaxYawSpeed(20)
		
		if ( !self:IsMoving() ) and self.t_NextWander < CurTime() then
		
			self:SetLastPos( self:RecomputeSurroundPath(self,400,600) )
					
			timer.Simple( 2, function()
					
				--print("recomputed wander path")
				
				if not IsValid(self) then return end
					
				if ( self:GetNPCState() == NPC_STATE_IDLE ) or ( self:GetNPCState() == NPC_STATE_ALERT ) then
					self:TASKFUNC_WALKLASTPOSITION()
				end
				
			end )
			
			return
		
		end
		
		return

	-- Combat state --

	elseif ( self:State(STATE_COMBAT)) then
		-- State change code
		if not IsValid(enemy) then
			self:SetState(STATE_IDLE)
		end
		-- Idle sound
		if ( self.t_NextIdleSound < CurTime() ) and ( math.random(1,6) == 1 ) then
			
			sound.Play( "doom/monsters/imp/imp_distant_short"..math.random(1,3)..".ogg",self:GetPos(), 75, math.random(98,102) ) 
			self.t_NextIdleSound = CurTime() + math.Rand(3,8)
				
		end 
		-- Turn code
		
		self:Turn(enemypos)
		
		-- Charge attack code
		
		if self.b_InChargeAttack then
		
			print("chargeattack_into")
				
			if self.i_ChargeAttackType == 1 then
			
				self:SetIdleAnimation("throw_fastball_1_cycle")
				
				if self.t_ChargeRelease < CurTime() and self:CanPerformProcess() then
					self:PlayActivity("throw_fastball_1_out")
					self.b_InChargeAttack = false
				end
			
			elseif self.i_ChargeAttackType == 2 then
			
				self:SetIdleAnimation("throw_fastball_2_cycle")
				
				if self.t_ChargeRelease < CurTime() and self:CanPerformProcess() then
					self:PlayActivity("throw_fastball_2_out")
					self.b_InChargeAttack = false
				end
			
			end
			
			return
			
		end
		
		self:SetIdleAnimation("idle_combat")
		self:SetRunAnimation("run_all")
		
		if not self:IsMoving() and self:CanPerformProcess() then
			self:StartIdleAnimation()
		end
		
		self:MeleeAttack( dist, enemy )
		self:RangedAttack( dist, enemy )
		
		self:SetMaxYawSpeed(90)
		
		if dist < self.i_CloseDist or not self:Visible(enemy) then
			
			self:ChaseEnemy()
			
		end
		
		if ( self.t_NextPath < CurTime() ) then
			
			if ( !self:IsMoving() and self:CanPerformProcess() ) then
			
				self:SetLastPos( self:RecomputeSurroundPath( enemy, self.i_MinDist, self.i_MaxDist) )
				
				self:TASKFUNC_RUNLASTPOSITION()
				
				self.t_NextPath = CurTime() + math.Rand(5,8)
				
				return
			
			end
			
		end
		
		return
		
	end

end

---------------------------------------------------------------------------------------------------------------------------------------------
-- OnChangeActivity function, handles climbing and jumping
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:OnChangeActivity(act)

	if act == ACT_JUMP then
	
		--self:Task_HandleJumping()
	
	end

end

---------------------------------------------------------------------------------------------------------------------------------------------
-- Melee Attack
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:MeleeAttack(dist, enemy)
		
	if not self:CanPerformProcess() then return end
	if not self:Visible(enemy) then return end
		
	if self.t_NextMeleeAttack < CurTime() then
		
		if dist < 120 then
			
			self:TASKFUNC_FACEPOSITION(enemy:GetPos())
			
			if self:FindInCone(enemy,60) then
				
				self:PlayActivity(self:SelectFromTable({"melee_forward_1","melee_forward_2"}))
				self.t_NextMeleeAttack = CurTime() + math.Rand(0,1)
				
				return
				
			end
			
			
		elseif dist < 200 and self:IsMoving() and self:FindInCone(enemy,15) then
			
			self:PlayActivity(self:SelectFromTable({"melee_moving_1","melee_moving_2"}))
			self.t_NextMeleeAttack = CurTime() + math.Rand(1,2)
			
			return
			
		end
		
	end
	
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- Ranged Attack
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:RangedAttack( dist, enemy )

	if not self:CanPerformProcess() then return end

	if ( self.t_NextRangedAttack < CurTime() ) and ( dist > self.i_CloseDist or dist > 2000 ) and not self.b_InChargeAttack then
	
		if not self:VisibleVec(enemy:GetPos() + enemy:OBBCenter() + Vector(0,0,30)) then return end
	
		local _ang = self:D_GetAngleTo(enemy:GetPos())
			
		if ( self:IsMoving() ) and ( self:GetPos():Distance(self:GetLastPos()) > 300 ) and self:FindInCone(self:GetLastPos(), 90) then
				
			if self:FindInCone(enemy, 90) then
				
				self:PlayActivity("throw_fromrun_forward")
				
				self.t_NextRangedAttack = CurTime()+math.Rand(3,5)
				
			elseif _ang.y <= -90 and _ang.y > -135 then
				-- Right
				self:PlayActivity("throw_fromrun_right")
				
				self.t_NextRangedAttack = CurTime()+math.Rand(3,5)
				
			elseif _ang.y >= 90 and _ang.y < 135 then 
				-- Left
				self:PlayActivity("throw_fromrun_left")
				
				self.t_NextRangedAttack = CurTime()+math.Rand(3,5)
			
			end
				
		else
			
			if self:FindInCone(enemy, 70) then
			
				if math.random(1,3) == 1 or ( dist > 1000 and math.random(1,2) == 1 ) then
				
					self.b_InChargeAttack = true
					self.t_ChargeRelease = CurTime()+math.Rand(3,4)
					self.t_NextRangedAttack = CurTime()+math.Rand(5,7)
					sound.Play( "doom/monsters/imp/imp_charge.ogg",self:GetPos(), 80, math.random(98,102) ) 
				
					if math.random(1,2) == 1 then
						self.i_ChargeAttackType = 1
						self:PlayActivity("throw_fastball_1_into")
					else
						self.i_ChargeAttackType = 2
						self:PlayActivity("throw_fastball_2_into")
					end
					
				else
				
					self:PlayActivity(self:SelectFromTable({"throw_1", "throw_2", "step_left_throw", "step_right_throw"}))
					
				end
				
			end
		
		end
		
	end

end

---------------------------------------------------------------------------------------------------------------------------------------------
-- Ranged Attack
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:InterruptCharge()

	if not self.b_InChargeAttack then return end
	
	self:StopParticles()
	self.b_InChargeAttack = false
	self.t_NextRangedAttack = math.Rand(0,2)

end

---------------------------------------------------------------------------------------------------------------------------------------------
-- Turning code
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:Turn(enemypos)
	
	if not self:CanPerformProcess() then return end
	if not self:VisibleVec(enemypos) then return end
	
	if not self:IsMoving() then
	
		if not self:FindInCone(enemypos, 90) and math.random(1,3) == 1 then
		
			local _ang = self:D_GetAngleTo(enemypos)
			
			if _ang.y <= -70 then
				-- Right	
				self:PlayActivity("turn_right_90")
				
				self:InterruptCharge()
					
			elseif _ang.y >= 70 then 
				-- Left
				self:PlayActivity("turn_left_90")
				
				self:InterruptCharge()
				
			end
			
		end
		
	else
		
		if not self:FindInCone(enemypos, 90) then

			self:ClearPoseParameters()
			UseDefaultPoseParameters = false

		else
		
			UseDefaultPoseParameters = false

		end		
		
	end
	
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- This function generates new point around the enemy, within _min and _max distances
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:RecomputeSurroundPath(ent, _min, _max)

	local _tries = 0
	local maxtries = 20
	local _bestpos = Vector()
	
	local _selfpos = self:GetPos()
	local _enemypos = ent:GetPos()
	local _returnpos

	-- It is doing multiple checks here (max 10)

	while true do

		_tries = _tries + 1
			
		local _startpos = _enemypos + ( Vector(math.Rand(-1,1),math.Rand(-1,1),0):GetNormalized() * math.random(_min, _max) ) + Vector(0,0,50)
		local _trace = util.QuickTrace(_startpos, _startpos + Vector(0,0,-512))
		
		if _trace.HitWorld then
		
			local _endpos = _trace.HitPos
			local LOSCheck = ent:VisibleVec(_endpos + Vector(0,0,50))
			
			if ( self:GetPos():DistToSqr(_endpos) > ( 400*400 ) ) then
				
				_bestpoint = _endpos
				
				if LOSCheck or math.random(1,10) == 1 then
				
					_returnpos = _endpos
					break
				
				end
				
			end
			
		end
		
		-- The function couldn't find the correct point and gave up
		
		if _tries >= maxtries then 
		
			_returnpos = _bestpos 
			break 
		
		end
	
	end
	
	debugoverlay.Line(_selfpos, _returnpos, 1, Color(255,0,0),true)			
	debugoverlay.Cross( _returnpos ,10, 5, Color(255,0,0),true)
	print("recomputed the path in ".._tries.." tries")
	
	return _returnpos

end

---------------------------------------------------------------------------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:HandleEvents(...)

	local event = select(1,...)
	
	local arg1 = select(2,...)
	
	local arg2 = select(3,...)
	
	if (event == "sound") then
	
		sound.Play("doom/monsters/imp/"..tostring(arg1)..".ogg", self:GetPos(), 75, math.random(98,102))
		return true
		
	elseif (event == "emit") then
	
		if (arg1 == "fireball_left") then
	
			if not IsValid(self:GetEnemy()) then return true end
			
			ParticleEffectAttach("d_fireball",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("hand_left"))
			
			return true
		
		elseif (arg1 == "fireball_right") then
	
			if not IsValid(self:GetEnemy()) then return true end
			
			ParticleEffectAttach("d_fireball",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("hand_right"))
			
			return true
			
		elseif (arg1 == "fireball_special_left") then
	
			if not IsValid(self:GetEnemy()) then return true end
			
			ParticleEffectAttach("d_fireballfast",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("hand_left"))
			
			return true
		
		elseif (arg1 == "fireball_special_right") then
	
			if not IsValid(self:GetEnemy()) then return true end
			
			ParticleEffectAttach("d_fireballfast",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("hand_right"))
			
			return true
		
		end
		
	elseif (event == "attack") then
	
		if (arg1 == "melee") then
	
			if not IsValid(self:GetEnemy()) then return true end
			self:DoDamage(100,self.i_MeleeDmg,DMG_SLASH)
			return true
		
		elseif (arg1 == "ranged_left") then
	
			self:StopParticles()
	
			if not IsValid(self:GetEnemy()) then return true end
			
			sound.Play("doom/monsters/imp/fx_imp_fireball_launch"..math.random(1,3)..".ogg", self:GetPos(), 70, math.random(98,102))
			
			self:D_RangeAttack("ent_dmod_imp_projectile", "hand_left", 1.4, Vector(0,0,250) )
			
			return true
		
		elseif (arg1 == "ranged_right") then
	
			self:StopParticles()
	
			if not IsValid(self:GetEnemy()) then return true end
			
			sound.Play("doom/monsters/imp/fx_imp_fireball_launch"..math.random(1,3)..".ogg", self:GetPos(), 70, math.random(98,102))
			
			self:D_RangeAttack("ent_dmod_imp_projectile", "hand_right", 1.4, Vector(0,0,250) )
			
			return true
			
		elseif (arg1 == "ranged_special_left") then
	
			self:StopParticles()
	
			if not IsValid(self:GetEnemy()) then return true end
			
			sound.Play("doom/monsters/imp/fx_imp_fireball_launch"..math.random(1,3)..".ogg", self:GetPos(), 70, math.random(98,102))
			
			self:D_RangeAttack("ent_dmod_imp_projectile_fast", "hand_left", 1, Vector(0,0,0) )
			
			return true
		
		elseif (arg1 == "ranged_special_right") then
	
			self:StopParticles()
	
			if not IsValid(self:GetEnemy()) then return true end
			
			sound.Play("doom/monsters/imp/fx_imp_fireball_launch"..math.random(1,3)..".ogg", self:GetPos(), 70, math.random(98,102))
			
			self:D_RangeAttack("ent_dmod_imp_projectile_fast", "hand_right", 1, Vector(0,0,0) )
			
			return true
		
		end
		
	elseif (event == "util") then
	
		if (arg1 == "run") then
		
			self:TASKFUNC_RUNLASTPOSITION()
			
			return true
		
		end
	
	end
	
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- This function sets correct stats and behaviour, depending on the randomly selected type
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:Select_AIType()

	self.i_Behavior = self:SelectFromTable({0,0,0,0,1,1,2})
	
	if self.i_Behavior == 1 then
	
		self.i_MeleeDmg = 9
		self.i_CloseDist = 350
	
	elseif self.i_Behavior == 2 then
	
	print(self.i_Behavior)
	
	end

end

---------------------------------------------------------------------------------------------------------------------------------------------
-- Possessor stuff
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:Possess_OnPossessed(possessor) 

	self:SetIdleAnimation("idle_combat")
	self:SetWalkAnimation("walk_forward")
	self:SetRunAnimation("run_all")
	
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- Misc
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:OnHitEntity(hitents,hitpos)

	for _,v in ipairs(hitents) do
		if IsValid(v) then sound.Play("doom/monsters/melee_hit_" .. math.random(1,2) .. ".ogg",v:GetPos(),75, math.random(98,102)) end
	end
	
end

---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:OnMissEntity()

	sound.Play("npc/zombie/claw_miss" .. math.random(1,2) .. ".wav",self:GetPos(),70, math.random(98,102))

end
