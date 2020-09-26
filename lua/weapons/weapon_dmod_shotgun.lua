SWEP.Base = "weapon_base"

SWEP.PrintName = "Combat Shotgun"
    
SWEP.Author = "Rex"
SWEP.Contact = ""
SWEP.Purpose = "Rip and Tear!"
SWEP.Instructions = "Aim and pull the trigger. R to change weapon mods. RMB to use them."
SWEP.Category = "DOOM"

SWEP.Spawnable= true
SWEP.AdminOnly = false

SWEP.Primary.Damage = 10
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = "buckshot" --The ammo type will it use
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Spread = 0.75
SWEP.Primary.NumberofShots = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 0.1 -- Delay before the next shot
SWEP.Primary.Force = 1

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 43
SWEP.ViewModel			= "models/doom/weapons/shotgun/shotgun.mdl"
SWEP.WorldModel			= "models/weapons/w_shotgun.mdl"
SWEP.UseHands           = false

SWEP.PumpAnimations = {"shoot_delay","shoot_delay_alt1","shoot_delay_alt2","shoot_delay_alt3"}

SWEP.FirstDeploy = true

-- Shared functions

function SWEP:GetTableValue( tbl )
	if not tbl then return end
	return tbl[math.random( #tbl ) ]
end

function SWEP:PlayVMSequence( seq )
	if not IsValid( self ) then return end 
	local vm = self.Owner:GetViewModel( )
	vm:SendViewModelMatchingSequence( vm:LookupSequence( seq ) )
end

function SWEP:VMSequenceDuration( seq )
	if not IsValid( self ) then return 0 end 
	local vm = self.Owner:GetViewModel( )
	local seq = seq or self:GetSequence()
	return vm:SequenceDuration( vm:LookupSequence( seq ) )
end

function SWEP:BulletAttack()
	local bullet = {} 
	bullet.Num = self.Primary.NumberofShots 
	bullet.Src = self.Owner:GetShootPos() 
	bullet.Dir = self.Owner:GetAimVector() 
	bullet.Spread = Vector( self.Primary.Spread*0.1 , self.Primary.Spread*0.1, 0)
	bullet.Tracer = 1
	bullet.TracerName = Tracer
	bullet.Force = self.Primary.Force 
	bullet.Damage = self.Primary.Damage 
	bullet.AmmoType = self.Primary.Ammo 
	self.Owner:FireBullets( bullet ) 
end

-- Weapon functions

function SWEP:Initialize()
	self:SetWeaponHoldType( "shotgun" )
end


-- Deployment --

function SWEP:Deploy()
	if not IsFirstTimePredicted() then return end
	self:EmitSound( "doom/weapons/switch_weapon.ogg" )
	self:SetWeaponHoldType( "shotgun" )
	if self.FirstDeploy then
		self:PlayVMSequence( "bringup_accent_pump" )
		timer.Simple( 0.8, function()
			if not IsValid(self) then return end
			self:EmitSound( "doom/weapons/shotgun/shotgun_pull.ogg" )
		end)
		timer.Simple( 1, function()
			if not IsValid(self) then return end
			self:EmitSound( "doom/weapons/shotgun/shotgun_push.ogg" )
		end)
		self.FirstDeploy = false
	else
		self:PlayVMSequence( "bringup" )
	end
	print("equip")
end

-- Primary attack

function SWEP:PrimaryAttack()

	if not IsFirstTimePredicted() then return end

	if self:Ammo1() < self.Primary.TakeAmmo then
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextPrimaryFire( CurTime() + 0.2 )
		self:PlayVMSequence( "dryfire" )
		return 
	end
	
	local vm = self.Owner:GetViewModel()
	ParticleEffectAttach( "d_muzzleflash", PATTACH_POINT_FOLLOW, vm, vm:LookupAttachment( "muzzle" ) )
	
	

	self:TakePrimaryAmmo( self.Primary.TakeAmmo )
	self:BulletAttack()
	
	self:EmitSound( "doom/weapons/shotgun/shotgun_fire_"..math.random(5)..".ogg", nil, nil, nil, CHAN_WEAPON )
	
	self:PlayVMSequence( "shoot" )
	
	-- Pump
	
	timer.Simple( self:VMSequenceDuration()+0.025, function()
		if not IsValid(self) then return end
		self:PlayVMSequence( self:GetTableValue( self.PumpAnimations ) )
	end)
	
	-- Sounds

	timer.Simple( 0.25, function()
		if not IsValid(self) then return end
		self:EmitSound( "doom/weapons/shotgun/shotgun_pull.ogg", nil, nil, nil, CHAN_AUTO )
	end)
	
	timer.Simple( 0.45, function()
		if not IsValid(self) then return end
		self:EmitSound( "doom/weapons/shotgun/shotgun_push.ogg", nil, nil, nil, CHAN_AUTO )
	end)
	
	-- Recoil
	
	self.Owner:ViewPunch( Angle( -3, 0, 0 ) )
	
	-- Timers
	
	self:SetNextPrimaryFire( CurTime() + 0.65 )

end
