function ENT:SetSpawnEntity(ent)
	--self.ToSpawn = ent
end

function ENT:SetSpawnParticle(particle)
	if not particle then return end
	self.SpawnParticle = particle
end