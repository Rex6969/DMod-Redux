----------------------------------------------------------------------------------------------------
-- Purpose: fuck poseparameters
-- ~ Fuck poseparameters
----------------------------------------------------------------------------------------------------

function ENT:BoneLook(bone, pos, lim_yaw, lim_roll, speed, mul)
		--print( heck )
	local bone = self:LookupBone(bone)
	if !bone then return end
	local selfang, curang, targang = self:GetAngles(), self:GetManipulateBoneAngles( bone ), (pos - self:GetPos()):Angle()
	local ang_yaw, ang_roll = math.AngleDifference( targang.p, selfang.p ) * mul, math.AngleDifference( targang.y, selfang.y ) * mul
	local val_yaw = math.Clamp( math.ApproachAngle( curang.y, ang_yaw, speed*mul ), -lim_yaw, lim_yaw ) -- math.ApproachAngle( curang.p, ang_pitch, speed )
	local val_roll = math.Clamp( math.ApproachAngle( curang.r, ang_roll, speed*mul ), -lim_roll, lim_roll ) -- math.ApproachAngle( curang.y, ang_yaw, speed )
	self:ManipulateBoneAngles(bone, Angle( 0, val_yaw, val_roll ) )
	
end

function ENT:ResetManipulateBoneAngles( bone )

	local bone = self:LookupBone(bone)
	if !bone then return end
	self:ManipulateBoneAngles(bone, Angle() )
	
end