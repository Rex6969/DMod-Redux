if not DrGBase then return end
ENT.Base = "npc_dmod_zombie"

ENT.PrintName = "Unwilling"
ENT.Category = "DOOM"
ENT.Models = {"models/doom/monsters/zombie/zombie_hell.mdl"}

ENT.Factions = {"FACTION_DOOM"}

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
				self:RX_CreateRagdoll( dmg, directory.."death1_hell_left.mdl", self:OBBCenter())
			elseif rand == 2 then
				self.CurrentDeathAnimation = "gore_death5_scientist_1"
				self:SetBodygroup( 0, 2 ) 
				self:RX_CreateRagdoll( dmg, directory.."death1_hell_left.mdl", self:OBBCenter())
			elseif rand == 3 then
				self.CurrentDeathAnimation = "gore_death5_scientist_2"
				self:SetBodygroup( 0, 2 ) 
				self:RX_CreateRagdoll( dmg, directory.."death1_hell_left.mdl", self:OBBCenter())
			elseif rand == 4 then
				self.CurrentDeathAnimation = "gore_death5_scientist_3"
				self:SetBodygroup( 0, 2 ) 
				self:RX_CreateRagdoll( dmg, directory.."death1_hell_left.mdl", self:OBBCenter())
			else
				local gib = math.random(2)
				if gib == 1 then
					self:RX_CreateRagdoll( dmg, directory.."death5_hell_lower.mdl")
					self:RX_CreateRagdoll( dmg, directory.."death1_hell_left.mdl", self:OBBCenter())
				else
					self:RX_CreateRagdoll( dmg, directory.."death1_hell_right.mdl")
					self:RX_CreateRagdoll( dmg, directory.."death1_hell_left.mdl", self:OBBCenter())
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
		--[[if CLIENT then
			if IsValid(self:GetEnemy()) then
				local enemypos = self:GetEnemy():GetPos()
				self:BoneLook("spine", enemypos, 60, 60, 10, 0.5)
			end
			self:SetNextClientThink( CurTime() + 0.01 )
		end]]
	end
	
end


AddCSLuaFile()
DrGBase.AddNextbot(ENT)