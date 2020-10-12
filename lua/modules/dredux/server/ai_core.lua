if not SERVER then return end

----------------------------------------------------------------------------------------------------

function ENT:SetCondition( cond, value )
	self.Conditions[cond] = ( value or false )
end

function ENT:HasCondition( cond )
	return self.Conditions[cond]
end

----------------------------------------------------------------------------------------------------

function ENT:SetState( state )
	self.State = ( self.State && "State_"..state ) || {}
end

function ENT:UpdateState()
	return self[self.State] && self[self.State](self) || self:State_Fail()
end

----------------------------------------------------------------------------------------------------

function ENT:State_Fail()
	if !self:GetInState() then
		--self:Wait(1)
		self:SetState( "Idle" )
	end
end