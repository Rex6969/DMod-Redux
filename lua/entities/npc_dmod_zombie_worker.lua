if not DrGBase then return end
ENT.Base = "npc_dmod_zombie"
--DEFINE_BASECLASS("npc_dmod_base")

ENT.PrintName = "Possessed Worker"
ENT.Category = "DOOM"
ENT.Models = {"models/doom/monsters/zombie/zombie_worker.mdl"}

ENT.StartHealth = 150

ENT.Factions = {"FACTION_DOOM"}

ENT.IdleAnimation = "idle_combat"
ENT.WalkAnimation = "walk_straight"
ENT.RunAnimation = "walk_straight"

ENT.UseWalkframes = true

ENT.Tbl_Animations = {
	["Melee"] = {"melee_lunge_short_right_arm"},
	["Melee_Moving"] = {"melee_moving_fwd_lunge_right_arm"},
	["Melee_Special"] = {"melee_special_uacsecurity"},
	["Melee_Special_Moving"] = {"melee_special_uacsecurity_moving"},
	
	["Idle_To_Walk_W"] = {"idle_turn_left_to_walkforward"},
	["Idle_To_Walk_E"] = {"idle_turn_right_to_walkforward"},
	["Idle_To_Walk_SW"] = {"idle_turn_back_left_157_to_walkforward"},
	["Idle_To_Walk_SE"] = {"idle_turn_back_right_157_to_walkforward"},
	["Idle_To_Walk_S"] = {"idle_turn_back_left_157_to_walkforward","idle_turn_back_right_157_to_walkforward"},
	
	["Walk"] = {
		"walk_straight",
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
	
	
	function ENT:OnDeath( dmg, hitgroup )
		
		self:BecomeRagdoll()
		
	end
	
else

	function ENT:CustomDraw()
	
		if self:HasEnemy() and IsValid(self:GetEnemy()) then
			local enemypos = self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter()
			self:BoneLook("SideHead", enemypos, 80, 60, 10, 0.5)
			self:BoneLook("Spine", enemypos, 40, 20, 10, 0.5)
		end
		
	end

end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)
