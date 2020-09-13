if not DrGBase then error("DrGBase is not installed! NPC failed to load!") return end
ENT.Base = "npc_dmod_base"

-- Misc --
ENT.PrintName = "Imp"
ENT.Category = "DOOM"
ENT.Models = {"models/doom/monsters/imp/imp.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED

-- Sounds --

-- Stats --

ENT.SpawnHealth = 150
ENT.AIType = 0
ENT.MeleeDamage = 8

-- AI --
ENT.BehaviourType = AI_BEHAV_CUSTOM

ENT.RangeAttackRange = 2000
ENT.MeleeAttackRange = 150

ENT.ReachEnemyRange = 100
ENT.MaxSurroundDist = 1000
ENT.MinSurroundDist = 800
ENT.CloseDist = 200

ENT.NextPath = CurTime()
ENT.NextTurn = CurTime()

ENT.MoveTarget = Vector()
ENT.Target = Vector()

-- Relationships --
ENT.Factions = {"FACTION_DOOM"}

-- Movements/animations --
ENT.UseWalkframes = true
ENT.WalkAnimation = "walk"
ENT.RunAnimation = "run"

-- Detection --
ENT.EyeBone = "Head"
ENT.EyeOffset = Vector(0, 0, 5)

if ( SERVER ) then

	-- Init/Think --

	function ENT:CustomInitialize()
	
		self:SetDefaultRelationship(D_HT)
		self.IdleAnimation = "idle_relaxed"
		
	end
	
	function ENT:OnSpawn()
	
		self:PlayAnimationAndWait("spawn_teleport_"..math.random(5))
		self:Wait(math.Rand(1,2))
		
		local typetable = {0,0,0,0,1,1,2}
		self.AIType = typetable[math.random(1,#typetable)]
		
		if self.AIType == 0 then
			
		elseif self.AIType == 1 then
			self.CloseDist = 300
		else
		end
		
		--self.MoveTarget = self:GetPos()
		self.Target = self:GetPos() + self:OBBCenter() + self:GetForward() * 100
		
	end
	
	function ENT:OnReachedPatrol()
		self:Wait(1)
	end
	
	function ENT:AIBehaviour()
		
		if not self:HasEnemy() then
		
			self.IdleAnimation = "idle_relaxed"
			self:AddPatrolPos(self:RandomPos(500))
		
			return
		
		end
		
		local enemy = self:GetEnemy()
		local relationship = self:GetRelationship(enemy)
		
		self.IdleAnimation = "idle_combat"
		self.WalkAnimation = "walk"
		self.RunAnimation = "run"
		
		if not self:IsMoving() then
			self.Target = enemy:GetPos()
			self:Turn(enemy:GetPos())
		else
			self.NextTurn = CurTime() + math.Rand(1,2)
		end
		
		if relationship == D_HT then
			
			if self:IsInRange(enemy, self.CloseDist) then
				
				if self.AIType ~= 2 then
				
					self.MoveTarget = enemy:GetPos()
					self:FollowPath(self.MoveTarget,150)
					self.NextPath = CurTime()
					
				else
					
					self.MoveTarget = self:GetPos():DrG_Away(enemy:GetPos())
					self:GoTo(self.MoveTarget,150)
					self.NextPath = CurTime()
					
				end
				
			else
			
				if  self.NextPath < CurTime() and !self:IsMoving() then
					local t = 0
					local checkpos = Vector()
					local bestpos = Vector()
					while true do
						checkpos = enemy:DrG_RandomPos(self.MinSurroundDist,self.MaxSurroundDist)+Vector(0,0,50)
						if ( self:VisibleVec(checkpos) or math.random(10) == 1 ) and ( enemy:VisibleVec(checkpos) or math.random(20) == 1 ) and ( self:GetPos():DistToSqr(checkpos) >= 300*300 ) then
							self.MoveTarget = checkpos
							print("pos gen succesful")
							self.MoveTarget = checkpos
							self:Turn(self.MoveTarget)
							break
						end
						t = t + 1
						if checkpos and t >= 10 then print("pos gen failed") self.MoveTarget = enemy:GetPos() break end
					end
					self:GoTo(self.MoveTarget, 200)
					self.NextPath = CurTime() + math.Rand(3,5)
				end
					
			end

		end
		
	end
	
	function ENT:HandleAnimEvent(event, _, _, _, options)
		
		local event = string.Explode(" ", options, false)
	
		if event[1] == "sound" then
			
			sound.Play("doom/monsters/imp/imp_"..event[2]..".ogg",self:GetPos()) -- Requires some work with the events
			print(event[2])
			
		end
	
	end
	
	function ENT:Turn(pos)
	
		if self:IsDead() or math.random(1,10) ~= 1 or self.NextTurn > CurTime() then return end
		local direction = self:CalcPosDirection(pos,subs)
		if direction == "N" then return
		elseif direction == "W" then
			self:PlaySequenceAndMove("turn_left_90")
		elseif direction == "E" then
			self:PlaySequenceAndMove("turn_right_90")
		else
			local animtable = {"turn_left_90","turn_right_90"}
			self:PlaySequenceAndMove(animtable[math.random(1,2)])
			
		end
		
	end
	
	function ENT:OnAnimChanged(old,new)
	
		self:CallInCoroutine(function () self:HandleTransitions(old,new) end)
	
	end
	
	function ENT:HandleTransitions(old,new)
	
		if old == "run" and new == "idle" then
			local dir = self:CalcPosDirection(self.Target)
			local anim
			if dir == "N" then
				anim = "run_forward_to_idle"
			elseif dir == "W" or dir == "SW" then
				anim = "run_forward_turn_left_to_idle"
			elseif dir == "E" or dir == "SE" then
				anim = "run_forward_turn_right_to_idle"
			elseif dir == "S" then
				local animtable = {"run_forward_turn_left_180_to_idle","run_forward_turn_right_180_to_idle"}
				anim = animtable[math.random(1,2)]
			end
			if self:HasEnemy() and math.random(1,2) == 1 then
				string.gsub(anim,"run_forward","run_forward_throw")
			end
			self:PlayAnimationAndMove(anim)
		end
		if old == "idle_combat" and new == "run" then
			--self:PlayAnimationAndMove("idle_to_run_forward")
		end
		
		return true
		
	end
	
	

else

end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)