
function ENT:AimController( controller, axis, mul, max )

	local current = self:GetAngles()[axis]
	local target = (self:GetEnemy():GetPos() - self:GetPos()):Angle()[axis]
	
	local ang = ( target - current )
	
	print( "=="	)
	print( current )
	print( ang )
	print( target )
	
	self:SetBoneController( controller, target ) --[pmath.Clamp( value, -max, max ) * mul )

end