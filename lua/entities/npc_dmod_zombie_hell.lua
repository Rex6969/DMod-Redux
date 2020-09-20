if not DrGBase then return end
ENT.Base = "npc_dmod_zombie"
--DEFINE_BASECLASS("npc_dmod_base")

ENT.PrintName = "Unwilling"
ENT.Category = "DOOM"
ENT.Models = {"models/doom/monsters/zombie/zombie_hell.mdl"}

ENT.StartHealth = 150
ENT.Factions = {"FACTION_DOOM"}

AddCSLuaFile()
DrGBase.AddNextbot(ENT)

if SERVER then

	function ENT:OnDeath( dmg, hitgroup )
		
		self:BecomeRagdoll()
		
	end
	
end
