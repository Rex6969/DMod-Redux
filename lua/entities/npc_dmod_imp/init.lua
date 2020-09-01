if !CPTBase or (CLIENT) then return end

AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')
include('shared.lua')
include('cl_init.lua')
include('tasks.lua')

ENT.Model = "models/doom/monsters/imp/imp.mdl"
ENT.Skin = 0

ENT.ViewAngle = 90

ENT.StartHealth = 250

ENT.Schedule = {}

ENT.ProcessingTime = 0.3

ENT.MeleeDamage = 8

-- State enums

local STATE_NO_AI = 0
local STATE_IDLE = 1
local STATE_ALERTED = 2
local STATE_COMBAT_MOVE = 3
local STATE_COMBAT_STAND = 4
local STATE_FLEE = 5

local AI_ENABLED = true

-- Local variables

ENT.t_NextWander = CurTime()

ENT.t_NextPath = CurTime()
ENT.t_NextCombatStateChange = CurTime()

ENT.t_NextMeleeAttack = CurTime()

ENT.Behaviour = 0

ENT.CloseDist = 350

ENT.SurroundDistance_Min = 500
ENT.SurroundDistance_Max = 1000

---------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:SetInit()

	-- Model stuff

	self:SetModel(self.Model)
	self:SetBodygroup(0,self.Skin)
	
	-- Physics and movement
	
	self:SetCollisionBounds(Vector(-18,-18,1),Vector(18,18,55))
	self:SetMaxYawSpeed(15)
	
	-- Animations

	self:SetIdleAnimation("idle_combat")
	self:SetRunAnimation("run_all")
	self:SetWalkAnimation("walk_forward")
	
	-- AI-related stuff
	
	self:_SetState(STATE_NO_AI)
	self:HandleType()
	
	b_NextWander = CurTime() + math.random(0,3)

	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	self:CapabilitiesAdd(bit.bor(CAP_SQUAD))
	
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- AI Module
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:OnThink()

	if not self:CanPerformProcess() or self.IsPossessed then return end

	local enemy
	local dist
	local nearest
	local disp
	
	if IsValid(self:GetEnemy()) then

		enemy = self:GetEnemy()
		dist = self:FindCenterDistance(enemy)
		nearest = self:GetClosestPoint(enemy)
		disp = self:Disposition(enemy)
	
	end
	
	---------------------------------------------------------------------------------------------------------------------------------------------
	-- Debug shit --
	
	debugoverlay.Box(self:GetPos(),Vector(-18,-18,1),Vector(18,18,55),0.15,Color(255,255,255,0))
	
	debugoverlay.Cross(self:GetPos(),5,1,Color(255,255,0),true)
	
	--debugoverlay.Text(self:GetPos()+self:GetUp()*50,"Imp type"..self.ImpType,0.2)
	
	if enemy then debugoverlay.Line(self:GetPos(), enemy:GetPos(),0.15,Color(255,0,0),true) end
	
	--print(self:_GetState())
	
	-- Blank state --
	
	if self:_State(STATE_NO_AI) then
	
		if not AI_ENABLED then return end
	
		self:PlayActivity(self:SelectFromTable({"spawn_teleport_1","spawn_teleport_2","spawn_teleport_3","spawn_teleport_4","spawn_teleport_5"}))
			
		if IsValid(enemy) then
			
			self:_SetState(STATE_COMBAT_MOVE)
				
		else
			
			self:_SetState(STATE_IDLE)
				
		end
			
		return
		
	end
	
	---------------------------------------------------------------------------------------------------------------------------------------------
	-- Idle --

	if self:_State(STATE_IDLE) then
	
		-- Idle and wandering code
		
		self:SetIdleAnimation("idle_combat")
		
		self:SetMaxYawSpeed(10)
	
		if self.t_NextWander < CurTime() then
			
			self:StopMoving()
			
			self:ClearSchedule()
			
			timer.Simple(math.Rand(1,2), 
			
			function()
			
				if not IsValid(self) then return end
			
				self:TASKFUNC_WANDER()
			
				end
			
			)
			
			self.t_NextWander = CurTime() + math.Rand(3,7)
		
		end
	
		-- Alert Code --
	
		if IsValid(enemy) then 
		
			if math.random(1,3) == 1 then
				
				self:PlayActivity("spawn_teleport_4",2) 
				
			end
				
			self:_SetState(STATE_COMBAT_MOVE)
				
			return
			
		end
		
		return
	
	end
	
	---------------------------------------------------------------------------------------------------------------------------------------------
	-- Alerted state --
	
	if self:_State(STATE_ALERTED) then
	
		self:SetIdleAnimation("idle_combat")
		
		-- Alert Code
	
		if IsValid(enemy) then 
		
			if math.random(1,3) == 1 then
				
				self:PlayActivity("spawn_teleport_4",2) 
				
			end
				
			self:_SetState(STATE_COMBAT_MOVE)
				
			return
			
		end
		
		return
	
	end
	
	if self:_State(STATE_COMBAT_MOVE) then
		
		-- Basic functions
		
		self:SetIdleAnimation("idle_combat")
		
		self:SetMaxYawSpeed(80)
		
		-- Reset to alerted idle
		
		if not IsValid(enemy) then self:_SetState(STATE_ALERTED) return end
		
		-- State changing
		
		if self.t_NextCombatStateChange < CurTime() then
			
			
			
		end
		
		-- Melee Attack code
		
		self:Task_MeleeAttack(dist, enemy)
		
		-- Movement code, based on previous version of DOOM SNPCs
		
		if not self:Visible(enemy) then
		
			if self.t_NextPath < CurTime() then
		
				if ( math.random(1,3) == 1 ) then
				
					self:SetLastPos(enemy:GetPos())
					self:TASKFUNC_RUNLASTPOSITION()
				
					self.t_NextPath = CurTime() + 2
				
				end
			
			end
		
		end
		
		if dist > 2000 then
		
			self:ChaseEnemy()
			
			self.t_NextPath = CurTime() + 3
			
		elseif dist > self.CloseDist and dist < 2000 then
		
			if self.t_NextPath < CurTime() and not self:IsMoving() then
			
				self:Task_RecomputeSurroundPath(enemy, self.SurroundDistance_Min, self.SurroundDistance_Max)
				
				self:TASKFUNC_RUNLASTPOSITION()
				
				self.t_NextPath = CurTime() + math.Rand(5,9)
				
				return
				
			end
			
		elseif dist < self.CloseDist then
		
			self:ChaseEnemy()
			
		end

		return
		
	end
	
	if self:_State(STATE_COMBAT_STAND) then
		
		
		
	end

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
		
	elseif (event == "attack") then
	
		if (arg1 == "melee") then
	
			if not IsValid(self:GetEnemy()) then return end
	
			self:DoDamage(100,self.MeleeDamage,DMG_SLASH)
		
			return true
		
		end
	
	end
	
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- OnChangeActivity function, handles climbing and jumping
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:OnChangeActivity(act)

	if act == ACT_CLIMB_DOWN then

		self:ClearSchedule()
		self:TASKFUNC_FACEPOSITION(self:GetEnemy():GetPos())
		self:SetRunAnimation("ledge_down_500")
		
		print("climb down")
	
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

	sound.Play("npc/zombie/claw_miss" .. math.random(1,2) .. ".wav",self:GetPos(),50, math.random(98,102))

end
