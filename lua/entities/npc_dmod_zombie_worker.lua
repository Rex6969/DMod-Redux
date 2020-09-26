if not DrGBase then return end
ENT.Base = "npc_dmod_zombie"

ENT.PrintName = "Possessed Worker"
ENT.Category = "DOOM"
ENT.Models = {"models/doom/monsters/zombie/zombie_worker.mdl"}

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
	
	function ENT:HandleDeath( dmg, hitgroup )
		
		local anim_key = nil
		
		local damage = dmg:GetDamage()
		local damagetype = dmg:GetDamageType()
		local inflictor = dmg:GetInflictor()
		
		if hitgroup == 8 then
		
			self.CurrentDeathAnimation = "headshot_"..math.random(2)
			
		else
			self:RX_GenericGibs( dmg, 8 )
			local rand = math.random(1,8)
			if rand == 1 then
				self.CurrentDeathAnimation = "gore_death5_scientist_1"
				self:SetBodygroup( 0, 1 ) 
				self:RX_CreateRagdoll( dmg, directory.."death1_worker_left.mdl")
			elseif rand == 2 then
				self.CurrentDeathAnimation = "gore_death5_scientist_1"
				self:SetBodygroup( 0, 2 ) 
				self:RX_CreateRagdoll( dmg, directory.."death1_worker_left.mdl")
			elseif rand == 3 then
				self.CurrentDeathAnimation = "gore_death5_scientist_2"
				self:SetBodygroup( 0, 2 ) 
				self:RX_CreateRagdoll( dmg, directory.."death1_worker_left.mdl")
			elseif rand == 4 then
				self.CurrentDeathAnimation = "gore_death5_scientist_3"
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
		
		self:CallInCoroutineOverride(function()
			self:PlayAnimationAndMove( self.CurrentDeathAnimation )
			self:RX_RagdollDeath()
		end) 
		
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
