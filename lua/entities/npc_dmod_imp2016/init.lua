if !CPTBase or (CLIENT) then return end

AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')
include('shared.lua')
include('cl_init.lua')

ENT.Model = "models/doom/monsters/imp/imp.mdl"
ENT.Skin = 0

ENT.StartHealth = 250

ENT.Schedule = {}

-- State enums

local STATE_NO_AI = 0
local STATE_IDLE = 1
local STATE_ALERTED = 2
local STATE_COMBAT_MOVING = 3
local STATE_COMBAT_STANDING = 4
local STATE_FLEE = 5

local AI_ENABLED = true

-- Local variables

local b_CanPlayAlertAnimation = false

---------------------------------------------------------------------------------------------------------------------------------------------
-- Init function
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:SetInit()

	self:SetModel(self.Model)
	self:SetBodygroup(0,self.Skin)
	
	self:SetCollisionBounds(Vector(-18,-18,1),Vector(18,18,50))
	
	self:SetMaxYawSpeed(30)
	
	self:_SetState(STATE_NO_AI)
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- AI Module
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:OnThink()

	if not self:CanPerformProcess() then return end

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
	
	-- Blank state --
	
	if self:_State(STATE_NO_AI) then
	
		if AI_ENABLED then
	
			self:PlayActivity(self:SelectFromTable({"spawn_teleport_1","spawn_teleport_2","spawn_teleport_3","spawn_teleport_4","spawn_teleport_5"}))
			
			if IsValid(enemy) then
			
				self:_SetState(STATE_ALERTED)
				
			else
			
				self:_SetState(STATE_IDLE)
				
			end
			
			return
			
		end
		
	end
	
	-- Idle

	if self:_State(STATE_IDLE) then
	
		self:SetIdleAnimation("idle_combat")
	
		-- Alert Code
	
		if IsValid(self:GetEnemy()) then 
		
			if math.random(1,3) == 1 then
				
				self:PlayActivity("spawn_teleport_4",2) 
				
			end
				
			self:_SetState(STATE_ALERTED)
				
			return
			
		end
	
	end
	
	-- Alerted state --
	
	if self:_State(STATE_ALERTED) then
	
		if not IsValid(enemy) then
		
			self:_SetState(STATE_IDLE)
		
			return
		
		end
	
	end
	
	print(self:_GetState())

end

---------------------------------------------------------------------------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:HandleEvents(...)

	local event = select(1,...)
	
	local arg1 = select(2,...)
	
	local arg2 = select(3,...)
	
	if (event == "sound") then
	
		sound.Play("doom/monsters/imp/"..tostring(arg1)..".ogg", self:GetPos(), 70, math.random(98,102))
		
		return true
	
	end
	
end