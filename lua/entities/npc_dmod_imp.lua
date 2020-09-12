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
ENT.MeleeDamage = 8

-- AI --
ENT.BehaviourType = AI_BEHAV_CUSTOM

ENT.RangeAttackRange = 2000
ENT.MeleeAttackRange = 150
ENT.AvoidEnemyRange = 300

ENT.ReachEnemyRange = 100
ENT.MaxSurroundDist = 1000
ENT.MinSurroundDist = 800

ENT.NextPath = CurTime()

ENT.MoveTarget = nil

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
	
		--self:PlayAnimationAndWait("spawn_teleport_"..math.random(1,5))
		self:PlayAnimationAndMove("diveforward_forward_1")
		self:Wait(math.Rand(0,2))
		
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
			
		if relationship == D_HT then
			
			if self:IsInRange(enemy, self.AvoidEnemyRange) then
			
			else
			
				if  self.NextPath < CurTime() and !self:IsMoving() then
					self.MoveTarget = self:RecomputeSurroundPath( self:GetEnemy(), self.MinSurroundDist, self.MaxSurroundDist)	
					self.NextPath = CurTime() + math.Rand(3,7)
				end
					
			end
			
			if self.MoveTarget then 
				self:FollowPath(self.MoveTarget, 50) 
			end
				
		end
		
	end
	
	function ENT:RecomputeSurroundPath(ent, _min, _max)
		
		-- Just a placeholder. I have no idea how to make this shit work with NextBot, because it just doesn't
		
		returnpos = ent:GetPos()
		
		return returnpos
	
	end
	
	function ENT:HandleAnimEvent(event, _, _, _, options)
		
		local event = string.Explode(" ", options, false)
	
		if event[1] == "sound" then
			
			--sound.Play("doom/monsters/imp/imp_"..event[2]..".ogg",self:GetPos()) -- Requires some work with the events
			sound.Play("doom/monsters/imp/imp_sight"..math.random(1,4)..".ogg",self:GetPos(),75,100+math.random(-4,4),0.7)
			
		end
	
	end

else

end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)