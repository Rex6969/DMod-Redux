----------------------------------------------------------------------------------------------------
-- Purpose: fuck poseparameters
-- ~ Fuck poseparameters
----------------------------------------------------------------------------------------------------

function ENT:BoneLook(bone, pos, lim_pitch, lim_yaw, speed, mul)
		--print( heck )
	local bone = self:LookupBone(bone)
	local selfang, curang, targang = self:GetAngles(), self:GetManipulateBoneAngles( bone ), (pos - self:GetPos()):Angle()
			
	local ang_pitch, ang_yaw = math.AngleDifference( targang.p, selfang.p ) * mul, math.AngleDifference( targang.y, selfang.y ) * mul
			
	local val_pitch = math.Clamp( math.ApproachAngle( curang.p, ang_pitch, speed*mul ), -lim_pitch, lim_pitch ) -- math.ApproachAngle( curang.p, ang_pitch, speed )
	local val_yaw = math.Clamp( math.ApproachAngle( curang.y, ang_yaw, speed*mul ), -lim_yaw, lim_yaw ) -- math.ApproachAngle( curang.y, ang_yaw, speed )
			
	self:ManipulateBoneAngles(bone, Angle( val_pitch , val_yaw, 0 ) )
end

function ENT:ResetManipulateBoneAngles( bone )
	local bone = self:LookupBone(bone)
	self:ManipulateBoneAngles(bone, Angle() )
end