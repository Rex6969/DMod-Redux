if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)
DEFINE_BASECLASS("drgbase_nextbot")

-- Misc --
ENT.PrintName = "Template"
ENT.Category = "Other"
ENT.Models = {"models/Kleiner.mdl"}

ENT.UseWalkframes = true

if SERVER then

	ENT.BehaviourType = AI_BEHAV_CUSTOM
	ENT.Factions = {"FACTION_DOOM"}
	ENT.Schedule ={}

	-- WHY THE FUCK DOESN'T DRGBASE HAVE THIS
	
	function ENT:GetTableValue( tbl )
		if not tbl then return end
		return ( tbl[math.random( #tbl ) ] )
	end
	
	function ENT:ExtractAnimation(tbl,key)
		if not tbl then return end
		return( self:GetTableValue( tbl[key] ) )
	end
	
	function ENT:ExtractAnimation2( tbl, key1, key2 )
		if not tbl then return end
		return( tbl[ key1 ][ key2 ] )
	end
	
	-- WHY THE FUCK IS IT BROKEN IN DRGBASE
	-- Based on DrG_RandomPos but edited and exists only for this base and it's children
	-- 2x shorter but i am sure it works
	-- I renamed it with kewl name so it won't cause any conflict
	
	function ENT:RX_RandomPos(_entity, _min, _max)
		if not IsValid(_entity) then return end
		if isnumber(_max) then
			local pos = _entity:GetPos() + Vector(math.random(-100, 100), math.random(-100, 100), 0):GetNormalized() * math.random(_min, _max)
			if navmesh.IsLoaded() then
				local area = navmesh.GetNearestNavArea(pos)
				if IsValid(area) then
					local pos = area:GetClosestPointOnArea(pos)
					return pos
				end
			end
		end
		return self:RX_RandomPos(_entity, 0, _max)
	end
	
	function ENT:GoTo(pos, tolerance, callback)
		if not isfunction(callback) then callback = function() end end
		while true do
		local res = self:FollowPath(pos, tolerance)
		if res == "reached" then return true
		elseif res == "unreachable" then
			return false
		else
			res = callback(self, self:GetPath())
			if isbool(res) then return res end
				self:YieldCoroutine(true)
			end
		end
		return false
	end
	
	-- Some setters/getters lol
	
	function ENT:SetIdleAnimation(anim)
		self.IdleAnimation = anim
	end
	
	function ENT:SetWalkAnimation(anim)
		self.WalkAnimation = anim
	end
	
	function ENT:SetRunAnimation(anim)
		self.RunAnimation = anim
	end

	-- Schedule

	function ENT:AddAIState(task,arg)
		return table.insert(self.Schedule,{task,arg})
	end
	
	function ENT:RemoveAIState(task,arg)
		return table.remove(self.Schedule,#self.Schedule)
	end
	
	function ENT:OverwriteAIState(task,arg)
		self:RemoveAIState()
		self:AddAIState(task,arg)
		return
	end

	function ENT:RunAIState() -- FUCKING HACK
		local func = self.Schedule[#self.Schedule][1]
		if not func then return end 
		return self[func](self)
	end
	
	function ENT:UpdateAIState(maximum)
		if #self.Schedule > maximum then
			table.remove(self.Schedule,1)
		elseif #self.Schedule == 0 then
			self:AddAIState("TaskFail")
			self:RunAIState()
		end
		self:RunAIState()
	end
	
	function ENT:AIStateData()
		return self.Schedule[1][2] or {}
	end
	
	function ENT:WriteAIStateData(key,value)
		if not self.Schedule[1][2] then self.Schedule[1][2] = {} end
		self.Schedule[1][2][key] = value
	end
	
	-- Shared states
	
	function ENT:State_Fail()
		self:Wait( 1 )
		self:OverwriteAIState( "State_Idle" )
	end

	-- gibbing function

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

end

	---------------------------------------------------------------------------------------------------------------------------------------------
	-- Fuck poseparameters
	-- Legacy function, it's going to be here until i find something better
	---------------------------------------------------------------------------------------------------------------------------------------------
	
	function ENT:BoneLook(bone, pos, limitx, limity, speed, mul)
		local mul = mul or 1
		local bone = self:LookupBone(bone)
		local selfpos = self:GetPos() + self:OBBCenter()
		local selfang = self:GetAngles()
		local targetang = (pos - selfpos):Angle()
		local rotpitch = math.AngleDifference(targetang.p,selfang.p) * mul
		local rotyaw = math.AngleDifference(targetang.y,selfang.y) * mul
		local curang = self:GetManipulateBoneAngles(bone)
		
		if (rotpitch > -limitx and rotpitch < limitx) and (rotyaw > -limity and rotyaw < limity) then
			self:ManipulateBoneAngles(bone, Angle( math.ApproachAngle(curang.p,rotpitch,speed), math.ApproachAngle(curang.y,rotyaw,speed), 0 ) )
		end
	end

-- DO NOT TOUCH --
AddCSLuaFile()