-- Experimental state machine implementation by Rex, 2020.

-- Purpose:
-- ~ Advanced and more deep AI control.
-- ~ Complex behaviors can co-exist within single NPC
-- ~ Transitions between states may also be customized
-- ~ Making the code look better

-- Limitations
-- ~ By far, it's purpose is only to use it with NextBots, and i've never tested it with any NPCs. It should work tho.

if not SERVER then return end

----------------------------------------------------------------------------------------------------
-- State example
----------------------------------------------------------------------------------------------------

function ENT:State_Empty() -- 'State_' is only a prefix and it is being added in the code real-time. It helps distinguish states and other functions.
	if !self:GetInState() then
		-- Here goes state intro code. Transitions, etc. Something that should be ran only once.
		return self:SetInState(true) -- It's done with the state intro, next think will call the state body code
	end
	local data = self:StateData() -- In most cases it's not necessary to use that function.
	-- Here goes all the shit that should be called continuously.
	if true then return self:RemoveState() --[[or self:OverwriteState("")]] end -- Simple state transition code. Next think will run the next selected state
end



----------------------------------------------------------------------------------------------------
-- Shared states
----------------------------------------------------------------------------------------------------

function ENT:State_Fail() -- State version of SCHED_FAIL
	if !self:GetInState() then
		--self:Wait(1)
		self:AddState( "Idle" )
	end
end


function ENT:State_Forced_Go() -- State version of TASK_FAIL
	if !self:GetInState() then
		self:Wait(1)
		self:AddState( "Idle" )
	end
end

----------------------------------------------------------------------------------------------------
-- State init functions. They allow me to use state intro code only once.
----------------------------------------------------------------------------------------------------

function ENT:SetInState(arg)
	self.InState = arg and isbool(arg) or false
end
	
function ENT:GetInState()
	return self.InState or false
end

----------------------------------------------------------------------------------------------------
-- State functions
----------------------------------------------------------------------------------------------------

-- Purpose: state transitions. Adds current state from the stack. Writes 'arg' as state data. 

function ENT:AddState( state, arg )
	self:SetInState(false)
	return table.insert(self.Tbl_State,{ "State_"..state, arg } )
end

-- Purpose: state transitions. Removes current state from the stack.
	
function ENT:RemoveState( task )
	self:SetInState(false)
	return table.remove(self.Tbl_State,#self.Tbl_State)
end

-- Purpose: state transitions. Overwrites current state in the stack. Writes 'arg' as new state data. 
	
function ENT:OverwriteState (task, arg )
	self:RemoveState()
	self:AddState(task,arg)
	return
end
	
-- Purpose: updates state stack and calls RunState()
-- Note: It should be called every think. 

function ENT:UpdateState(_max)
	--if not self.Tbl_State then self.Tbl_State = {} end
	if ( #self.Tbl_State > _max ) then table.remove( self.Tbl_State, 1 )
	elseif ( #self.Tbl_State == 0 ) then self:AddState("Fail")	
	end
	self:RunState()
end

-- Purpose: runs current state.

function ENT:RunState()
	local func = self.Tbl_State[#self.Tbl_State][1]
	if not func then return end 
	return self[func](self)
end

----------------------------------------------------------------------------------------------------
-- State data functions
----------------------------------------------------------------------------------------------------
	
-- Purpose: returns the state data table

function ENT:StateData()
	return self.Tbl_State[1][2] or {}
end

-- Purpose: writes 'key = value' pair into a state table of CURRENT ACTIVE STATE. Useful for changing state data inside of a state.
	
function ENT:WriteStateData(key,value)
	self.Tbl_State[1][2] = self.Tbl_State[1][2] or {}
	self.Tbl_State[1][2][key] = value
end
