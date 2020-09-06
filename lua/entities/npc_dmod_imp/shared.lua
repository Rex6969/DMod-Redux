ENT.Base = "npc_dmod_base"
ENT.Type = "ai"
ENT.PrintName = "Imp"
ENT.Author = "Rex"
ENT.Category = "DOOM"
ENT.RenderGroup = RENDERGROUP_OPAQUE

if not (CLIENT) then return end

function ENT:Draw()
		
	self:DrawModel()
	
	render.SetMaterial( Material("particle/particle_glow_04_additive","smooth") )
	
	local eye_left = self:LookupAttachment( "eye_left" )
	render.DrawSprite(self:GetAttachment(eye_left).Pos,4,4,Color(255,100,0,19))
	
	local eye_right = self:LookupAttachment( "eye_right" )
	render.DrawSprite(self:GetAttachment(eye_right).Pos,4,4,Color(255,100,0,19))

end