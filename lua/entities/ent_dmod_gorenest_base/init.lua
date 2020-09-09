AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/doom/goretotem/gore_totem.mdl"
ENT.IsGoreNest = true
ENT.ViewAngle = 360

ENT.i_Current = 1
ENT.i_Spawned = 0
ENT.i_ToKill = 0
ENT.t_NextEnt = CurTime()

-- {"class", maximum amount of npcs left to spawn next one (0 to spawn them immediately) , "spawn particle"}

ENT.SpawnTable = {
{"npc_zombie",0,"d_monster_spawn_small_01"}
}

function ENT:SetInit()

	self:SetModel(self.Model)
	
	self:SetSolid(SOLID_OBB)
	self:SetCollisionBounds(Vector(-30,-30,0),Vector(30,30,50))

	self.Active = false
	self.t_NextSpawn = CurTime()
	
	self.CanSetEnemy = false
	self.IsEssential = true
	self.CanMove = false
	
end

function ENT:OnThink()

	local _tbl = self.SpawnTable

	if  self.i_Current > #_tbl or not self.Active then return end

	local _currenttbl = _tbl[self.i_Current]
	
	if ( self.i_Spawned < _currenttbl[2] or _currenttbl[2] == 0 ) and (self.t_NextEnt < CurTime()) then
			
		local _navarea = navmesh.GetNearestNavArea( self:GetPos() + ( Vector(math.Rand(-1,1),math.Rand(-1,1)):GetNormalized() * math.random(800,1500) ),false,6000)
		if not IsValid(_navarea) then print("Navmesh not detected! If NPCs were succesfully spawned, disregard this message. If not, refer to this manual for instructions on how to generate a navmesh > https://steamcommunity.com/sharedfiles/filedetails/?id=434705456") return end
		if _navarea:IsUnderwater() then return end
		local _ent = ents.Create( "ent_dmod_single_spawner" )
			
		_ent:SetPos( _navarea:GetRandomPoint() )
		_ent:SetOwner(self)
		_ent:Spawn()
		_ent:SetSpawnEntity(self.SpawnTable[self.i_Current][1])
		_ent:SetSpawnParticle(self.SpawnTable[self.i_Current][3])
			
		if not self:Visible(_ent) --[[or not self:GetEnemy():Visible(_ent)]] then _ent:Remove() return end
			
		print("npcspawn")
		print("current = "..self.i_Current)
			
		_ent:SpawnEntity()
		self.i_Current = self.i_Current + 1
		self.i_Spawned = self.i_Spawned + 1

		
		return
		
	end
	
	print("npc amount = "..self.i_Spawned)
	
end

function ENT:OnInputAccepted(input,activator)
	
	if self.Active == false then
		self.Active = true
		self:SetEnemy(activator,true)
		sound.Play( "doom/demonic_scream_"..math.random(1,1)..".ogg",self:GetPos(), 80, math.random(98,102) )
		
		timer.Simple(2, 
			function()
				self:SetNoDraw(true)
				self:SetCollisionBounds(Vector(0,0,0),Vector(0,0,0))
				
				self.Faction = "FACTION_DOOM"
				self.CanSetEnemy = true
				
				print("Gore nest activated")
			
			end
		)
		
		self.t_NextEnt = CurTime() + math.Rand(4,5)
	end
	
end



