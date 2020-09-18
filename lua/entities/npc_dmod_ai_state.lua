	function ENT:StartInitState()
		self.InState = false
	end
	
	function ENT:EndInitState()
		self.InState = true
	end

	-- State Meta 2

	function ENT:AddAIState(task,arg)
		return table.insert(self.Schedule,{task,arg})
	end
	
	function ENT:RemoveAIState(task,arg)
		return table.remove(self.Schedule,#self.Schedule)
	end
	
	function ENT:OverwriteAIState(task,arg)
		self:RemoveAIState()
		self:AddAIState(task,arg)
		return
	end

	function ENT:RunAIState() -- FUCKING HACK
		local func = self.Schedule[#self.Schedule][1]
		if not func then return end 
		return self[func](self)
	end
	
	function ENT:UpdateAIState(maximum)
		if #self.Schedule > maximum then
			table.remove(self.Schedule,1)
		elseif #self.Schedule == 0 then
			self:AddAIState("TaskFail")
			self:RunAIState()
		end
		self:RunAIState()
	end
	
	function ENT:AIStateData()
		return self.Schedule[1][2] or {}
	end
	
	function ENT:WriteAIStateData(key,value)
		if not self.Schedule[1][2] then self.Schedule[1][2] = {} end
		self.Schedule[1][2][key] = value
	end
