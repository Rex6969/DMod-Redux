	
if SERVER then
	
	----------------------------------------------------------------------------------------------------
	-- Here i am fixing something from DrGBase. I had to copy that code as-is just to replace one number and remove activity support (because i don't use it and it just makes the code more cluttered)
	----------------------------------------------------------------------------------------------------

	local function CallOnAnimChange(self, old, new)
		return self:OnAnimChange(self:GetSequenceName(old), self:GetSequenceName(new))
	end
	
	----------------------------------------------------------------------------------------------------
	
	local function CallOnAnimChanged(self, old, new)
		if not isfunction(self.OnAnimChanged) then return end
		self:ReactInCoroutine(function(self)
			self:OnAnimChanged(self:GetSequenceName(old), self:GetSequenceName(new), delay)
		end)
	end
	
	----------------------------------------------------------------------------------------------------
	
	local function ResetSequence(self, seq)
		local len = self:SetSequence(seq)
		self:ResetSequenceInfo()
		self:SetCycle(0)
		return len
	end
	
	----------------------------------------------------------------------------------------------------
	
	local function SeqHasTurningWalkframes(self, seq)
		local success, _, angles = self:GetSequenceMovement(seq, 0, 1)
		return success and angles.y ~= 0
	end
	
	----------------------------------------------------------------------------------------------------

	function ENT:UpdateAnimation()
		if self:IsPlayingAnimation() then return end
		--if self:IsAIDisabled() and not self:IsPossessed() then return end
		
		local anim, rate = self:OnUpdateAnimation()
		local current = self:GetSequence()
		local validAnim = false
		
		if isstring(anim) then
			local seq = self:LookupSequence(anim)
			validAnim = seq ~= -1
			if validAnim and (self:GetCycle() > 0.95 or seq ~= current) then
				if CallOnAnimChange(self, current, seq) ~= false then
				CallOnAnimChanged(self, current, seq)
				ResetSequence(self, seq)
				end
			end
		end
		
		if validAnim and
			((not self:IsMoving() or self:GetSequenceGroundSpeed(self:GetSequence()) == 0) and
			(not self:IsTurning() or not SeqHasTurningWalkframes(self, self:GetSequence()))) then
			self:SetPlaybackRate(rate or 1)
		end
	end

end