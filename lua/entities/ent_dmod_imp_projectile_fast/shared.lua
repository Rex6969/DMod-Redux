ENT.Type			= "anim"
ENT.Base 			= "obj_cpt_base"
ENT.PrintName		= "Imp Fast Fireball"
ENT.Author			= "REXMaster"
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

ENT.Category = "D4TEST"
ENT.Spawnable = true

if (CLIENT) then

	function ENT:Draw()

		--self:DrawModel()

		render.SetMaterial(Material("particle/particle_glow_04_additive"))
		render.DrawSprite(self:GetPos(), 45, 45, Color( 255, 100, 5, 20 ))

	end

end
