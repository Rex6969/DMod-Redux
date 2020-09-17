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

ENT.Animtbl_Melee = {
	["melee_Stand"] = {"melee_lunge_short_right_arm"}
}

if SERVER then
	
else

	function ENT:CustomDraw()
		if self:HasEnemy() then
			local enemypos = self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter()
			self:BoneLook("SideHead", enemypos, 60, 40, 10, 0.5)
		end
	end

end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)
