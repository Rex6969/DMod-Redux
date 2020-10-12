SWEP.Base = "weapon_dmod_base"

SWEP.PrintName = "Rocket Launcher"
SWEP.Category = "DOOM"
SWEP.Spawnable = true

SWEP.Primary.Projectile = "proj_dmod_rocket"
SWEP.Primary.Ammo = "rpg_round"
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.DefaultClip = 10

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.Weight = 15
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 45
SWEP.ViewModel			= "models/doom/weapons/rocketlauncher/rocketlauncher.mdl"
SWEP.WorldModel			= "models/doom/weapons/rocketlauncher/w_rocketlauncher.mdl"
SWEP.UseHands           = false

SWEP.FirstDeploy = true
SWEP.IsEmpty = false

SWEP.Reticle = {}

function SWEP:OnInitialize()

	self:SetWeaponHoldType( "rpg" )
	
	--[[if SERVER then
	
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
	
	end]]
	
	if CLIENT then
	
		self.Reticle.Key = 1
		self.Reticle[1] = Material("hud/reticle/rl/ret_1.png", "noclamp transparent smooth" )
		self.Reticle[2] = Material("hud/reticle/rl/ret_2.png", "noclamp transparent smooth" )
		self.Reticle[3] = Material("hud/reticle/rl/ret_3.png", "noclamp transparent smooth" )
	
	end
	
end

-- Think

function SWEP:Think()

	--print( self.IsEmpty, " ", self:Ammo1() > 0 )

	if self.IsEmpty and self:Ammo1() > 0 then
		self:PlayVMSequence( "bringup" )
		self.IsEmpty = false
	end
	
end

-- Deployment --

function SWEP:OnDeploy()
	if not IsFirstTimePredicted() then return end
	self:EmitSound( "doom/weapons/switch_weapon.ogg" )
	self:SetWeaponHoldType( "rpg" )
	
	self:SetNextPrimaryFire( CurTime() + 0.35 )
	
	if self.FirstDeploy and self:Ammo1() > 0 then
		self:PlayVMSequence( "intro" )
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
		return 
	end
	
	local vm = self.Owner:GetViewModel()
	ParticleEffectAttach( "d_rpg_muzzleflash", PATTACH_POINT_FOLLOW, vm, vm:LookupAttachment( "muzzle" ) )

	self:PlayVMSequence( "shoot", true )
	self:PlayVMSequenceWDelay( "shoot_delay", self:VMSequenceDuration()+0.025, true )

	self:ProjectileAttack( self.Primary.Projectile, ( self.Owner:GetShootPos() + self.Owner:GetAimVector() * 40 + self.Owner:GetRight()*16.5 + self.Owner:GetUp()*-5 ), 1250 )
	self:TakePrimaryAmmo( self.Primary.TakeAmmo )

	self:EmitSound( "doom/weapons/rocketlauncher/rocketlauncher_fire.ogg", nil, nil, nil, CHAN_WEAPON )

	if self:Ammo1() < self.Primary.TakeAmmo then
		local lastweapon = self.Owner:GetPreviousWeapon()
		self.IsEmpty = true
		timer.Simple( 1, function() 
			if !IsValid( self ) then return end
			self:PlayVMSequence( "idle_empty" )
		end )
	end
	
	-- Recoil
	
	self.Owner:ViewPunch( Angle( -3, 0, 0 ) )
	
	-- Timers
	
	self:SetNextPrimaryFire( CurTime() + 0.85 )

end

function SWEP:DoDrawCrosshair( x, y )
	surface.SetMaterial( self.Reticle[self.Reticle.Key] )
	surface.SetDrawColor( 255, 255, 255, 140 )
	surface.DrawTexturedRectRotated( ScrW()/2, ScrH()/2, 150, 150, 0 )
	return true
end

----------------------------------------------------------------------------------------------------

local Rocket = {}

	Rocket.Type = "anim"
	Rocket.Base = "proj_drg_default"
	
	Rocket.Models = {"models/weapons/w_missile_launch.mdl"}
	Rocket.Gravity = false
	Rocket.OnContactEffects = {"d_rpgrocket_explosion"}
	Rocket.OnContactDecals = {"Scorch"}
	Rocket.OnContactDelete = 0
	
	function Rocket:CustomInitialize()
		ParticleEffectAttach( "d_rpgrocket_trail", 1, self, 0)
		self:DynamicLight( Color( 255, 120, 0 ), 400, 0.75 )
	end
	
	function Rocket:OnContact( ent )
		self:EmitSound( "doom/weapons/rocketlauncher/rocket_explo_"..math.random( 6 )..".ogg", 90, nil, nil, CHAN_WEAPON )
		util.ScreenShake( self:GetPos(), 50, 5, 0.5, 400 )
		self:DealDamage( ent,  math.random( 110, 130 ), DMG_BLAST )
		self:RadiusDamage( math.random( 110, 130 ) , DMG_BLAST, 100, function(ent) return ent end)
	end

	scripted_ents.Register( Rocket, "proj_dmod_rocket" )
