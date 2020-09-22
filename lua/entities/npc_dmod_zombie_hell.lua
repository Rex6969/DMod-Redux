if not DrGBase then return end
ENT.Base = "npc_dmod_zombie"
--DEFINE_BASECLASS("npc_dmod_base")

ENT.PrintName = "Unwilling"
ENT.Category = "DOOM"
ENT.Models = {"models/doom/monsters/zombie/zombie_hell.mdl"}

ENT.StartHealth = 150
ENT.Factions = {"FACTION_DOOM"}

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
				self:RX_CreateRagdoll( dmg, directory.."death1_hell_left.mdl")
			elseif rand == 2 then
				anim_key = "gore_death5_scientist_1"
				self:SetBodygroup( 0, 2 ) 
				self:RX_CreateRagdoll( dmg, directory.."death1_hell_left.mdl")
			elseif rand == 3 then
				anim_key = "gore_death5_scientist_2"
				self:SetBodygroup( 0, 2 ) 
				self:RX_CreateRagdoll( dmg, directory.."death1_hell_left.mdl")
			elseif rand == 4 then
				anim_key = "gore_death5_scientist_3"
				self:SetBodygroup( 0, 2 ) 
				self:RX_CreateRagdoll( dmg, directory.."death1_hell_left.mdl")
			else
				local gib = math.random(2)
				if gib == 1 then
					self:RX_CreateRagdoll( dmg, directory.."death5_hell_lower.mdl")
					self:RX_CreateRagdoll( dmg, directory.."death1_hell_left.mdl")
				else
					self:RX_CreateRagdoll( dmg, directory.."death1_hell_right.mdl")
					self:RX_CreateRagdoll( dmg, directory.."death1_hell_left.mdl")
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
				self:BoneLook("head", enemypos, 80, 60, 10, 0.5)
				self:BoneLook("spine", enemypos, 40, 20, 10, 0.5)
			end
			self:SetNextClientThink( CurTime() + 0.1 )
		end
		--return true
	end
	
end


AddCSLuaFile()
DrGBase.AddNextbot(ENT)