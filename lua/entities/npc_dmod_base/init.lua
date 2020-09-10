if !CPTBase then return end

AddCSLuaFile('shared.lua')
include('shared.lua')

--ENT.Model = "models/error.mdl"
ENT.Health = 999
ENT.Faction = "FACTION_DOOM"

-- Custom variables

ENT.i_CurrentState = 0

ENT.v_TargetPos = Vector()

---------------------------------------------------------------------------------------------------------------------------------------------
-- New custom functions.
---------------------------------------------------------------------------------------------------------------------------------------------

-- Custom state system functions. Obsolete.

function ENT:SetState(arg)
	if not self.i_CurrentState then return end
	self.i_CurrentState = arg
end

function ENT:GetState()
	if not self.i_CurrentState then return end
	return self.i_CurrentState
end

function ENT:State(arg)
	if not self.i_CurrentState then return end
	return (self.i_CurrentState == arg)
end

-- Useful shit

function ENT:SetRunAnimation(anim)
	self.tbl_Animations["Run"] = {anim}
end

function ENT:SetWalkAnimation(anim)
	self.tbl_Animations["Walk"] = {anim}
end

function ENT:SetLastPos(pos)
	self.v_TargetPos = pos
	self:SetLastPosition(pos)
end

function ENT:GetLastPos(pos)
	return self.v_TargetPos
end

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
	
	for k,v in pairs(self.GibTable[1]) do
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
-- Based on the legacy range attack projectile function
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:D_RangeAttack(proj, att, forcemul, vector)

	--self.NEXTATTACK = CurTime()+math.Rand(1,3)

	local fireball = ents.Create( proj )
	
	fireball:SetPos(self:GetAttachment(self:LookupAttachment(att)).Pos)
	fireball:SetOwner(self)
	fireball:Spawn()
	fireball:Activate()
	
	local phys = fireball:GetPhysicsObject()
	
	if IsValid(phys) then
	
		phys:SetVelocity(self:SetUpRangeAttackTarget() * forcemul + vector)
		
	end
	
end

function ENT:D_RangeAttack_Normalized(proj, att, force, vector)

	--self.NEXTATTACK = CurTime()+math.Rand(1,3)

	local fireball = ents.Create( proj )
	
	fireball:SetPos(self:GetAttachment(self:LookupAttachment(att)).Pos)
	fireball:SetOwner(self)
	fireball:Spawn()
	fireball:Activate()
	
	local phys = fireball:GetPhysicsObject()
	
	if IsValid(phys) then
	
		phys:SetVelocity(self:SetUpRangeAttackTarget():GetNormalized() * force + vector)
		
	end
	
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- Stole that one from CBTBase. Replaced virgin self.ViewAngle with chad self.MeleeAngle.
-- 99% of credit goes to CBT Hazama
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:DoDamage(dist,dmg,dmgtype,force,viewPunch,OnHit)
	local pos = self:GetPos() +self:OBBCenter() +self:GetForward() *20
	local posSelf = self:GetPos()
	local center = posSelf +self:OBBCenter()
	local didhit
	local tblhit = {}
	local tblprops = {}
	local hitpos = Vector(0,0,0)
	for _,ent in ipairs(ents.FindInSphere(pos,dist)) do
		if ent:IsValid() && self:Visible(ent) then
			if self.AllowPropDamage then
				if table.HasValue(self.tbl_AttackablePropNames,ent:GetClass()) then
					table.insert(tblprops,ent)
				end
				self:AttackProps(tblprops,dmg,dmgtype,force,OnHit)
			end
			if ((ent:IsNPC() && ent != self && ent:GetModel() != self:GetModel()) || (ent:IsPlayer() && ent:Alive())) && (self:GetForward():Dot(((ent:GetPos() +ent:OBBCenter()) -pos):GetNormalized()) > math.cos(math.rad(self.MeleeAngle))) then
				if self.CheckDispositionOnAttackEntity && self:Disposition(ent) == D_LI then return end
				if self:CustomChecksBeforeDamage(ent) then
					if force then
						local forward,right,up = self:GetForward(),self:GetRight(),self:GetUp()
						force = forward *force.x +right *force.y +up *force.z
					end
					didhit = true
					local dmgpos = ent:NearestPoint(center)
					local dmginfo = DamageInfo()
					if self.HasMutated == true && (self.MutationType == "damage" or self.MutationType == "both") then
						dmg = math.Round(dmg *1.65)
					end
					if dmgtype != DMG_FROST then
						local finaldmg = AdaptCPTBaseDamage(dmg)
						dmginfo:SetDamage(finaldmg)
						dmginfo:SetAttacker(self)
						dmginfo:SetInflictor(self)
						dmginfo:SetDamageType(dmgtype)
						dmginfo:SetDamagePosition(dmgpos)
						hitpos = dmgpos
						if force then
							dmginfo:SetDamageForce(force)
						end
						if(OnHit) then
							OnHit(ent,dmginfo)
						end
						table.insert(tblhit,ent)
						if self.CanRagdollEnemies then
							if math.random(1,self.RagdollEnemyChance) == 1 then
								self:RagdollEnemy(dist,self.RagdollEnemyVelocity,tblhit)
							end
						end
						ent:TakeDamageInfo(dmginfo)
						if ent:IsPlayer() then
							if viewPunch then
								ent:ViewPunch(viewPunch)
							else
								ent:ViewPunch(Angle(math.random(-1,1)*dmg,math.random(-1,1)*dmg,math.random(-1,1)*dmg))
							end
						elseif ent:GetClass() == "npc_turret_floor" then
							ent:Fire("selfdestruct","",0)
							ent:GetPhysicsObject():ApplyForceCenter(self:GetForward() *10000)
						end
					else
						util.DoFrostDamage(dmg,ent,self)
					end
				end
			end
		end
	end
	if didhit == true then
		self:OnHitEntity(tblhit,hitpos)
	else
		self:OnMissEntity()
	end
	self:OnDoDamage(didhit,tblhit,hitpos)
	table.Empty(tblhit)
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- For the pose parameters
---------------------------------------------------------------------------------------------------------------------------------------------


function ENT:D_MoveBlend(pos,moveparameter,speed,docheck)
	local moveparameter = moveparameter or "move_yaw"
	local speed = speed or 10
	local selfang = self:GetAngles()
	local targetang = (pos - ( self:GetPos() + self:OBBCenter() )):Angle()
	self:SetPoseParameter(moveparameter, math.ApproachAngle(self:GetPoseParameter(moveparameter), self:D_PreventWrongMoveBlend(math.AngleDifference(targetang.y,selfang.y),true,pos) ,speed))
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- That thing should limit restrain pose parameters from being used
-- Without that little think there would be some leg-related bugs and other weird shit.
-- DOOM game uses the same system, as ID showed in their GDC video
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:D_PreventWrongMoveBlend(p,docheck,pos)
	if (p > -15 and p < 15) or (p > 80 and p < 100) or (p > 170 and p < -170) or (p < -85 and p > -100) or docheck == false then
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
	return 0
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- For the Gore Nest
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:OnRemove()

	if not IsValid(self:GetOwner()) then return end
	local _owner = self:GetOwner()
	if IsGoreNest(_owner) then
		_owner.i_Spawned = _owner.i_Spawned - 1
	end

end


-- Empty shit
-- Fuck this function btw, it's only being ran if there is a enemy and not ai_ignoreplayers set to 1, it doesn't allow me to use alert code without stealing and modifying one of cptbase functions

function ENT:HandleSchedules()
end

--Idk lol