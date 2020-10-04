SWEP.Base = "weapon_dmod_base"

SWEP.PrintName = "Combat Shotgun"
SWEP.Category = "DOOM"
SWEP.Spawnable = true

SWEP.Primary.Damage = 10
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Ammo = "buckshot" --The ammo type will it use
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Spread = 0.75
SWEP.Primary.NumberofShots = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 0.5
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
SWEP.ViewModelFOV		= 40
SWEP.ViewModel			= "models/doom/weapons/shotgun/shotgun.mdl"
SWEP.WorldModel			= "models/doom/weapons/shotgun/w_shotgun.mdl"
SWEP.UseHands           = false

SWEP.PumpAnimations = {"shoot_delay","shoot_delay_alt1","shoot_delay_alt2","shoot_delay_alt3"}

SWEP.FirstDeploy = true
SWEP.IsEmpty = false

SWEP.Reticle = {}

-- Weapon functions

function SWEP:OnInitialize()

	self:SetWeaponHoldType( "shotgun" )
	
	if SERVER then
	
		self.StartLight1 = ents.Create( "light_dynamic" )
		self.StartLight1:SetKeyValue("brightness", "3")
		self.StartLight1:SetKeyValue("distance", "200")
		self.StartLight1:SetLocalPos( self:GetPos() )
		self.StartLight1:SetLocalAngles( self:GetAngles() )
		
		self.StartLight1:Fire("Color", "255 120 0")
		self.StartLight1:SetParent(self)
		self.StartLight1:Spawn()
		self.StartLight1:Activate()
		self.StartLight1:Fire( "SetParentAttachment", "muzzle" )
		self.StartLight1:Fire("TurnOff", "", 0)
		self:DeleteOnRemove(self.StartLight1)
	
	end
	
	if CLIENT then
	
		self.Reticle.Key = 1
		self.Reticle[1] = Material("hud/reticle/sg/ret_1.png", "noclamp transparent smooth" )
	
	end
	
end

-- Think --

function SWEP:Think()

	if self.IsEmpty and self:Ammo1() > 0 then
		self:PlayVMSequence( "bringup" )
		self.IsEmpty = false
	end
	
end

-- Deployment --

function SWEP:OnDeploy()
	if not IsFirstTimePredicted() then return end
	self:EmitSound( "doom/weapons/switch_weapon.ogg" )
	self:SetWeaponHoldType( "shotgun" )
	--self.NextIdleAnimation = CurTime() + 0.5
	
	self:SetNextPrimaryFire( CurTime() + 0.35 )
	
	if self.FirstDeploy and self:Ammo1() > 0 then
		self:PlayVMSequence( "bringup_accent_pump" )
		self:EmitSoundWDelay( "doom/weapons/shotgun/shotgun_pull.ogg", nil, nil, nil, CHAN_AUTO, 0.8 )
		self:EmitSoundWDelay( "doom/weapons/shotgun/shotgun_push.ogg", nil, nil, nil, CHAN_AUTO, 1 )
		self.FirstDeploy = false
	else
		local hasammo = ( self:Ammo1() > 0 )
		local seq = hasammo and "bringup" or "bringup_empty"
		self.IsEmpty = hasammo
		self:PlayVMSequence( seq )
	end
	
end

-- Primary attack

function SWEP:PrimaryAttack()

	if not IsFirstTimePredicted() then return end

	if self:Ammo1() < self.Primary.TakeAmmo then
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextPrimaryFire( CurTime() + 0.2 )
		--self:PlayVMSequence( "dryfire" )
		return 
	end
	
	local vm = self.Owner:GetViewModel()
	ParticleEffectAttach( "d_muzzleflash", PATTACH_POINT_FOLLOW, vm, vm:LookupAttachment( "muzzle" ) )
	
	self:TakePrimaryAmmo( self.Primary.TakeAmmo )
	self:BulletAttack()
	
	self:EmitSound( "doom/weapons/shotgun/shotgun_fire_"..math.random(5)..".ogg", nil, nil, nil, CHAN_WEAPON )
	
	self:PlayVMSequence( "shoot" )
	local pump_anim = self:GetTableValue( self.PumpAnimations )
	self:PlayVMSequenceWDelay( pump_anim, self:VMSequenceDuration() )
	
	if self:Ammo1() < self.Primary.TakeAmmo then
		local lastweapon = self.Owner:GetPreviousWeapon()
		self.IsEmpty = true
		timer.Simple( 0.65, function() 
			if !IsValid( self ) then return end
			self:PlayVMSequence( "idle_empty" )
		end )
	end
	
	self.StartLight1:Fire("TurnOn", "", 0)
	timer.Simple( 0.15, function() if self:IsValid() then self.StartLight1:Fire("TurnOff", "", 0) end end)
	
	-- Sounds

	self:EmitSoundWDelay( "doom/weapons/shotgun/shotgun_pull.ogg", nil, nil, nil, CHAN_AUTO, 0.25 )
	self:EmitSoundWDelay( "doom/weapons/shotgun/shotgun_push.ogg", nil, nil, nil, CHAN_AUTO, 0.45 )
	
	-- Recoil
	
	self.Owner:ViewPunch( Angle( -3, 0, 0 ) )
	
	-- Timers
	
	self:SetNextPrimaryFire( CurTime() + 0.65 )

end

-- Crosshair

function SWEP:DoDrawCrosshair( x, y )
	surface.SetMaterial( self.Reticle[self.Reticle.Key] )
	surface.SetDrawColor( 255, 255, 255, 140 )
	surface.DrawTexturedRectRotated( ScrW()/2, ScrH()/2, 150, 150, 0 )
	return true
end
