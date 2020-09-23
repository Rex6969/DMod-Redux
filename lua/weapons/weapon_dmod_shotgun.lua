SWEP.Base = "weapon_base"

SWEP.PrintName = "Combat Shotgun"
    
SWEP.Author = "Rex"
SWEP.Contact = ""
SWEP.Purpose = "Rip and Tear!"
SWEP.Instructions = "Aim and pull the trigger. R to change weapon mods. RMB to use them."
SWEP.Category = "DOOM"

SWEP.Spawnable= true
SWEP.AdminOnly = false

SWEP.Primary.Damage = 15
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = "buckshot" --The ammo type will it use
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Spread = 20
SWEP.Primary.NumberofShots = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 0.1 -- Delay before the next shot
SWEP.Primary.Force = 100

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
SWEP.ViewModelFOV		= 35
SWEP.ViewModel			= "models/doom/weapons/shotgun/shotgun.mdl"
SWEP.WorldModel			= "models/weapons/w_shotgun.mdl"
SWEP.UseHands           = false

function SWEP:PlayVMSequence( seq )
	local vm = self.Owner:GetViewModel( )
	print(vm:LookupSequence( seq ))
	vm:SendViewModelMatchingSequence( vm:LookupSequence( seq ) )
end

function SWEP:Initialize()
	self:SetWeaponHoldType( "crossbow" )
	print("init")
end

function SWEP:Deploy()
	self:PlayVMSequence( "intro" )
	print("equip")
end