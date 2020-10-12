SWEP.Base = "weapon_base"

SWEP.Author = "Rex"
SWEP.Contact = ""
SWEP.Purpose = "Rip and Tear!"
SWEP.Instructions = "Aim and pull the trigger. R to change weapon mods. RMB to use them."
SWEP.Category = "DOOM"

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.FirstDeploy = true

SWEP.Primary.ClipSize = -1



----------------------------------------------------------------------------------------------------
-- Weapon functions
----------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:OnInitialize()
	self.AnimationFinished = CurTime()
	self.NextAnimation = CurTime()
	self.NextIdleAnimation = CurTime()
	return
end

function SWEP:OnInitialize()
	return
end

function SWEP:Think()
	self:OnThink()
	return
end

function SWEP:Deploy()
	self.IsActiveWeapon = true
	self:OnDeploy()
	return
end

function SWEP:Holster()
	self.IsActiveWeapon = false
	return true
end

function SWEP:PrimaryAttack()
	return
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:Reload()
	return
end

function SWEP:OnThink() return end
function SWEP:OnDeploy() return end

----------------------------------------------------------------------------------------------------
-- Shared utility functions
----------------------------------------------------------------------------------------------------

function SWEP:GetTableValue( tbl )
	if not tbl then return end
	return tbl[math.random( #tbl ) ]
end

function SWEP:GetVMAttachment( att )
	local vm = self.Owner:GetViewModel( )
	return vm:GetAttachment( vm:LookupAttachment( att ) )
end

function SWEP:CanPlayAnimation()
	return self.NextAnimation < CurTime()
end

----------------------------------------------------------------------------------------------------
-- Animations
----------------------------------------------------------------------------------------------------

function SWEP:PlayVMSequence( seq, restrict )
	--if self.NextAnimation > CurTime() then return end
	local vm = self.Owner:GetViewModel( )
	vm:SendViewModelMatchingSequence( vm:LookupSequence( seq ) )
	local delay = CurTime() + self:VMSequenceDuration( seq  )
	self.NextAnimation = delay + 0.5
	self.NextIdleAnimation = delay + 0.5
	if restrict then
		self:SetNextPrimaryFire( delay )
	end
end

function SWEP:PlayIdleSequence( seq  )
	local vm = self.Owner:GetViewModel( )
	vm:SendViewModelMatchingSequence( vm:LookupSequence( seq ) )
	self.NextIdleAnimation = CurTime() + self:VMSequenceDuration( seq  )
end

function SWEP:PlayVMSequenceWDelay( seq, delay, restrict )
	local delay = delay or 0
	self.NextAnimation = delay + 0.5
	self.NextIdleAnimation = delay + 0.5
	timer.Simple( delay, function()
		if IsValid( self ) and self.IsActiveWeapon then
			self:PlayVMSequence( seq, restrict )
		end
	end)
end

function SWEP:VMSequenceDuration( seq, restrict )
	if not IsValid( self ) then return 0 end 
	local vm = self.Owner:GetViewModel( )
	local seq = seq or self:GetSequence()
	return vm:SequenceDuration( vm:LookupSequence( seq ) )
end

----------------------------------------------------------------------------------------------------
-- Sounds
----------------------------------------------------------------------------------------------------

function SWEP:EmitSoundWDelay( soundName, soundLevel, pitchPercent, volume, channel, delay )
	local delay = delay or 0
	timer.Simple( delay, function()
		if IsValid( self ) and self.IsActiveWeapon then
			self:EmitSound(soundName, soundLevel, pitchPercent, volume, channel )
		end
	end)
end

----------------------------------------------------------------------------------------------------
-- Attack functions
----------------------------------------------------------------------------------------------------

function SWEP:BulletAttack( tbl )
	local tbl = tbl or self.Primary
	local bullet = {} 
	bullet.Num = tbl.NumberofShots 
	bullet.Src = self.Owner:GetShootPos() 
	bullet.Dir = self.Owner:GetAimVector() 
	bullet.Spread = Vector( tbl.Spread*0.1 , tbl.Spread*0.1, 0)
	bullet.Tracer = 1
	bullet.TracerName = Tracer
	bullet.Force = tbl.Force 
	bullet.Damage = tbl.Damage 
	bullet.AmmoType = tbl.Ammo 
	self.Owner:FireBullets( bullet ) 
end

function SWEP:ProjectileAttack( proj, att, vel )
	local proj = proj or "rpg_missile"
	
	local vm = self.Owner:GetViewModel()
	local aim = self.Owner:GetAimVector()
	local pos = self.Owner:GetShootPos()

	local trdata = {}
	trdata.start = pos
	trdata.endpos = pos + aim * 10000
	trdata.filter = self.Owner

	local targ = util.TraceLine( trdata )
	if !targ.Hit then 
		vel = aim:GetNormalized() * vel 
	else
		vel = ( targ.HitPos - att ):GetNormalized() * vel
	end
	
	--debugoverlay.Cross( targ.HitPos, 10, 3 )
	--debugoverlay.Cross( pos + targ.HitPos:GetNormalized() + Vector( 0, 0, 10 ), 10, 3 )

	local cur_proj = ents.Create( proj )
	cur_proj:SetPos( att )
	cur_proj:SetAngles( vel:Angle() )
	cur_proj:SetOwner( self.Owner )
	
	cur_proj:Spawn()
	cur_proj:Activate()
	
	local phys = cur_proj:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetVelocity( vel )
	end
end