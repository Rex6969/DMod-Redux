if not DrGBase then return end
ENT.Base = "npc_dmod_zombie"
--DEFINE_BASECLASS("npc_dmod_base")

ENT.PrintName = "Possessed Worker"
ENT.Category = "DOOM"
ENT.Models = {"models/doom/monsters/zombie/zombie_worker.mdl"}

ENT.StartHealth = 80

ENT.Factions = {"FACTION_DOOM"}

ENT.IdleAnimation = "idle_combat"
ENT.WalkAnimation = "walk_straight"
ENT.RunAnimation = "walk_straight"

ENT.UseWalkframes = true

ENT.Tbl_Animations = {
	["Melee"] = {"melee_lunge_short_right_arm","melee_forward"},
	["Melee_Moving"] = {"melee_moving_fwd_lunge_right_arm","melee_forward"},
	["Melee_Special"] = {"melee_special_uacsecurity"},
	["Melee_Special_Moving"] = {"melee_special_uacsecurity_moving"},
	
	["Melee_w"] = {"melee_left"},
	["Melee_E"] = {"melee_right"},
	["Melee_S"] = {"melee_back"},
	
	["Idle_To_Walk_W"] = {"idle_turn_left_to_walkforward"},
	["Idle_To_Walk_E"] = {"idle_turn_right_to_walkforward"},
	["Idle_To_Walk_SW"] = {"idle_turn_back_left_157_to_walkforward"},
	["Idle_To_Walk_SE"] = {"idle_turn_back_right_157_to_walkforward"},
	["Idle_To_Walk_S"] = {"idle_turn_back_left_157_to_walkforward","idle_turn_back_right_157_to_walkforward"},
	
	--[[["Walk_Relaxed"] = {
		"walk_forward_relaxed_1",
		"walk_forward_relaxed_2",
		"walk_forward_relaxed_3",
		"walk_forward_relaxed_4"
		},]]
	
	["Walk"] = {
		"walk_forward",
		"walk_forward_b",
		"walk_forward_c",
		"walk_forward_d",
		"walk_forward_e",
		"walk_forward_f",
		"walk_forward_g"
		}
}

if SERVER then
	
	local directory = "models/doom/monsters/zombie/gore/"
	
	function ENT:OnDeath( dmg, hitgroup )
		
		local anim_key = nil
		
		local damage = dmg:GetDamage()
		
		print(damage)
		
		local damagetype = dmg:GetDamageType()
		local inflictor = dmg:GetInflictor()
		
		dmg:GetAttacker():TakeDamage(dmg:GetDamage(), self)
		
		print(hitgroup)
		
		if hitgroup == 8 then
		
			anim_key = "headshot_"..math.random(2)
			
		elseif ( damage > 100 and hitgroup ~= 8 ) or ( damage > 300 ) or ( damagetype == DMG_BLAST ) then
			self:RX_GenericGibs( dmg, 8 )
			local rand = math.random(1,8)
			if rand == 1 then
				anim_key = "gore_death5_scientist_1"
				self:SetBodygroup( 0, 1 ) 
				self:RX_CreateRagdoll( dmg, directory.."death1_worker_left.mdl")
			elseif rand == 2 then
				anim_key = "gore_death5_scientist_1"
				self:SetBodygroup( 0, 2 ) 
				self:RX_CreateRagdoll( dmg, directory.."death1_worker_left.mdl")
			elseif rand == 3 then
				anim_key = "gore_death5_scientist_2"
				self:SetBodygroup( 0, 2 ) 
				self:RX_CreateRagdoll( dmg, directory.."death1_worker_left.mdl")
			elseif rand == 4 then
				anim_key = "gore_death5_scientist_3"
				self:SetBodygroup( 0, 2 ) 
				self:RX_CreateRagdoll( dmg, directory.."death1_worker_left.mdl")
			else
				local gib = math.random(2)
				if gib == 1 then
					self:RX_CreateRagdoll( dmg, directory.."death3_worker_lower.mdl")
					self:RX_CreateRagdoll( dmg, directory.."death1_worker_left.mdl")
				else
					self:RX_CreateRagdoll( dmg, directory.."death1_worker_right.mdl")
					self:RX_CreateRagdoll( dmg, directory.."death1_worker_left.mdl")
				end
				self:Remove()
			end
			
		end
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		local ragdoll
		if anim_key ~= nil then self:PlayAnimationAndMove( anim_key, 1) ragdoll = self:BecomeRagdoll() else self:DeathSounds() ragdoll = self:BecomeRagdoll( dmg ) end
		timer.Simple( 5, function() if IsValid( ragdoll ) then ragdoll:Remove() end end)
	end
	
else

	function ENT:CustomThink() 
		if CLIENT then
			if self:HasEnemy() and IsValid(self:GetEnemy()) then
				local enemypos = self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter()
				self:BoneLook("SideHead", enemypos, 80, 60, 10, 0.5)
				self:BoneLook("Spine", enemypos, 40, 20, 10, 0.5)
				self:SetNextClientThink( CurTime() + 0.3 )
			end
		end
		self:SetNextClientThink( CurTime() + 0.1 )
	end

end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)
