if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)
DEFINE_BASECLASS("drgbase_nextbot")

-- Misc --
ENT.PrintName = "Template"
ENT.Category = "Other"
ENT.Models = {"models/Kleiner.mdl"}
ENT.Skins = {0}
ENT.ModelScale = 1
ENT.CollisionBounds = Vector(10, 10, 72)
ENT.BloodColor = BLOOD_COLOR_RED
ENT.RagdollOnDeath = true

-- Stats --
ENT.SpawnHealth = 100
ENT.HealthRegen = 0
ENT.MinPhysDamage = 10
ENT.MinFallDamage = 10

-- Sounds --
ENT.OnSpawnSounds = {}
ENT.OnIdleSounds = {}
ENT.IdleSoundDelay = 2
ENT.ClientIdleSounds = false
ENT.OnDamageSounds = {}
ENT.DamageSoundDelay = 0.25
ENT.OnDeathSounds = {}
ENT.OnDownedSounds = {}
ENT.Footsteps = {}

-- AI --
ENT.Omniscient = false
ENT.SpotDuration = 30
ENT.RangeAttackRange = 0
ENT.MeleeAttackRange = 50
ENT.ReachEnemyRange = 50
ENT.AvoidEnemyRange = 0

-- Relationships --
ENT.Factions = {}
ENT.Frightening = false
ENT.AllyDamageTolerance = 0.33
ENT.AfraidDamageTolerance = 0.33
ENT.NeutralDamageTolerance = 0.33

-- Locomotion --
ENT.Acceleration = 1000
ENT.Deceleration = 1000
ENT.JumpHeight = 50
ENT.StepHeight = 20
ENT.MaxYawRate = 250
ENT.DeathDropHeight = 200

-- Animations --
ENT.WalkAnimation = ACT_WALK
ENT.WalkAnimRate = 1
ENT.RunAnimation = ACT_RUN
ENT.RunAnimRate = 1
ENT.IdleAnimation = ACT_IDLE
ENT.IdleAnimRate = 1
ENT.JumpAnimation = ACT_JUMP
ENT.JumpAnimRate = 1

-- Movements --
ENT.UseWalkframes = false
ENT.WalkSpeed = 100
ENT.RunSpeed = 200

-- Climbing --
ENT.ClimbLedges = false
ENT.ClimbLedgesMaxHeight = math.huge
ENT.ClimbLedgesMinHeight = 0
ENT.LedgeDetectionDistance = 20
ENT.ClimbProps = false
ENT.ClimbLadders = false
ENT.ClimbLaddersUp = true
ENT.LaddersUpDistance = 20
ENT.ClimbLaddersUpMaxHeight = math.huge
ENT.ClimbLaddersUpMinHeight = 0
ENT.ClimbLaddersDown = false
ENT.LaddersDownDistance = 20
ENT.ClimbLaddersDownMaxHeight = math.huge
ENT.ClimbLaddersDownMinHeight = 0
ENT.ClimbSpeed = 60
ENT.ClimbUpAnimation = ACT_CLIMB_UP
ENT.ClimbDownAnimation = ACT_CLIMB_DOWN
ENT.ClimbAnimRate = 1
ENT.ClimbOffset = Vector(0, 0, 0)

-- Detection --
ENT.EyeBone = ""
ENT.EyeOffset = Vector(0, 0, 0)
ENT.EyeAngle = Angle(0, 0, 0)
ENT.SightFOV = 150
ENT.SightRange = 15000
ENT.MinLuminosity = 0
ENT.MaxLuminosity = 1
ENT.HearingCoefficient = 1

-- Weapons --
ENT.UseWeapons = false
ENT.Weapons = {}
ENT.WeaponAccuracy = 1
ENT.WeaponAttachment = "Anim_Attachment_RH"
ENT.DropWeaponOnDeath = false
ENT.AcceptPlayerWeapons = true

-- Possession --
ENT.PossessionEnabled = false
ENT.PossessionPrompt = true
ENT.PossessionCrosshair = false
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {}
ENT.PossessionBinds = {}

if SERVER then

  function ENT:CustomInitialize() end
  function ENT:CustomThink() end

  -- These hooks are called when the nextbot has an enemy (inside the coroutine)
  function ENT:OnMeleeAttack(enemy) end
  function ENT:OnRangeAttack(enemy) end
  function ENT:OnChaseEnemy(enemy) end
  function ENT:OnAvoidEnemy(enemy) end

  -- These hooks are called while the nextbot is patrolling (inside the coroutine)
  function ENT:OnReachedPatrol(pos)
    self:Wait(math.random(3, 7))
  end 
  function ENT:OnPatrolUnreachable(pos) end
  function ENT:OnPatrolling(pos) end

  -- These hooks are called when the current enemy changes (outside the coroutine)
  function ENT:OnNewEnemy(enemy) end
  function ENT:OnEnemyChange(oldEnemy, newEnemy) end
  function ENT:OnLastEnemy(enemy) end

  -- Those hooks are called inside the coroutine
  function ENT:OnSpawn() end
  function ENT:OnIdle()
    self:AddPatrolPos(self:RandomPos(1500))
  end

  -- Called outside the coroutine
  function ENT:OnTakeDamage(dmg, hitgroup)
    self:SpotEntity(dmg:GetAttacker())
  end
  function ENT:OnFatalDamage(dmg, hitgroup) end
  
  -- Called inside the coroutine
  function ENT:OnTookDamage(dmg, hitgroup) end
  function ENT:OnDeath(dmg, hitgroup) end
  function ENT:OnDowned(dmg, hitgroup) end
  
  -- Custom functions atart
  
  ---------------------------------------------------------------------------------------------------------------------------------------------
	-- Legacy angle function
	---------------------------------------------------------------------------------------------------------------------------------------------

	function ENT:D_GetAngleTo(pos)
		local targetang = ( pos - self:GetPos() + self:OBBCenter() ):Angle()
		local selfang = self:GetAngles()
		local angreturn = {["x"] = math.AngleDifference(targetang.x,selfang.x),["y"] = math.AngleDifference(targetang.y,selfang.y)}
		return angreturn
	end

	---------------------------------------------------------------------------------------------------------------------------------------------
	-- That shit returns direction as a string
	---------------------------------------------------------------------------------------------------------------------------------------------

	function ENT:D_DirectionTo(pos)
		local _ang = self:D_GetAngleTo(pos).y
		if _ang >= -45 and _ang <= 45 then
			return "forward"
		elseif _ang >= -135 and _ang <= -45 then
			return "right"
		elseif _ang <= 135 and _ang >= 45 then
			return "left"
		else
			return "back"
		end
	end

	---------------------------------------------------------------------------------------------------------------------------------------------
	-- Gibbinh function
	---------------------------------------------------------------------------------------------------------------------------------------------


	function ENT:D_Gib(tbl,dmg)

		if not tbl then return end
		
		for k,v in pairs(tbl) do
			self.gib = ents.Create("ent_dmod_gib")
			self.gib:SetPos( self:GetBonePosition( self:LookupBone( k ) ) )
			self.gib:SetAngles( self:GetAngles() + AngleRand(-30,-30) )
			self.gib:SetOwner(self)
			self.gib:SetModel(v)
				
			self.gib:Spawn()
			self.gib:Activate()

			local phys = self.gib:GetPhysicsObject()
			
			if IsValid(phys) then
				phys:SetVelocity( VectorRand() * 80 + self:GetUp()*100 + dmg:GetDamageForce():GetNormalized()*math.random(150,250) )
			end
				
		end

		self.HasDeathRagdoll = false
		self:Remove()
	end
	
	---------------------------------------------------------------------------------------------------------------------------------------------
	-- Without that little thing there would be some leg-related bugs and other weird shit.
	-- ONLY should be used with 4-way blends
	-- DOOM game uses the same system, as ID showed in their GDC video
	---------------------------------------------------------------------------------------------------------------------------------------------

	
	function ENT:D_PreventWrongMoveBlend(p,pos)
	
		if (p > -15 and p < 15) or (p > 80 and p < 100) or (p > 170 and p < -170) or (p < -85 and p > -100) then
			return p
		end
		
		local _dir = self:D_DirectionTo(pos)
		
		if _dir == "forward" then
			return 0
		elseif _dir == "right" then
			return 90
		elseif  _dir == "left" then
			return -90
		elseif  _dir == "back" then
			return 180
		end
		
		return 0 -- forward
		
	end
	
	function ENT:OnRemove()

		if not IsValid(self:GetOwner()) then return end
		local _owner = self:GetOwner()
		if IsGoreNest(_owner) then
			_owner.i_Spawned = _owner.i_Spawned - 1
		end
	
		BaseClass:OnRemove()
	
	end

else

  function ENT:CustomInitialize() end
  function ENT:CustomThink() end
  function ENT:CustomDraw() end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)