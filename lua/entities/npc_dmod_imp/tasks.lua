---------------------------------------------------------------------------------------------------------------------------------------------
-- Melee Attack
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:Task_MeleeAttack(dist, enemy)

	if self.t_NextMeleeAttack < CurTime() then
		
				if dist < 120 then
				
					self:TASKFUNC_FACEPOSITION(enemy:GetPos())
				
					if self:FindInCone(enemy,60) then
				
						self:PlayActivity(self:SelectFromTable({"melee_forward_1","melee_forward_2"}))
					
						self.t_NextMeleeAttack = CurTime() + math.Rand(0,1)
				
						return
				
					end
				
					
				elseif dist < 200 and self:IsMoving() and self:FindInCone(enemy,15) then
				
					self:PlayActivity(self:SelectFromTable({"melee_moving_1","melee_moving_2"}))
				
					self.t_NextMeleeAttack = CurTime() + math.Rand(1,2)
					
					return
				
				end
				
	end
	
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- This function generates new point around the enemy, within _min and _max distances
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:Task_RecomputeSurroundPath(enemy, _min, _max)

	local b_FoundPath = false
	local _tries = 0
	
	local _selfpos = self:GetPos()
	local _enemypos = enemy:GetPos() + enemy:OBBCenter()

	-- It is doing multiple checks here, up to 8

	while true do

		_tries = _tries + 1
			
		local _startpos = ( _enemypos + ( Vector(math.Rand(-1,1),math.Rand(-1,1),0):GetNormalized() * math.random(_min, _max) ) + Vector(0,0,50) )
		
		local _trace = util.TraceLine({
		
			start = _startpos,
			endpos = _startpos + Vector(0,0,-512),
			filter = self
		
		})
		
		local _endpos = _trace.HitPos
		
		if _trace.HitWorld then
		
			local LOSCheck = enemy:VisibleVec(_endpos + Vector(0,0,50))
			
			if ( ( self:GetPos():DistToSqr(_endpos) > ( 400*400 ) ) and not util.IsInWorld( startpos ) ) and ( LOSCheck or math.random(1,3) == 1 ) then
				
				-- Fucntion ran succesfully
				
				self:SetLastPos(_endpos)
				
				debugoverlay.Line(_selfpos, _endpos, 1, Color(0,255,0), true)
				
				debugoverlay.Cross( _endpos ,10, 5, Color(0,255,0),true)
				
				break
				
			else
			
				debugoverlay.Line(_selfpos, _endpos, 1, Color(255,0,0),true)
				
				debugoverlay.Cross( _endpos ,10, 5, Color(255,0,0),true)
				
			end
			
		end
		
		-- The function couldn't find the correct point and gave up
		
		if _tries >= 8 then self:SetLastPos(_endpos) break end
	
	end
	
	print("recomputed the path in ".._tries.." tries")

end

---------------------------------------------------------------------------------------------------------------------------------------------
-- This function sets correct stats and behaviour, depending on the randomly selected type
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:HandleType()

	self.Behaviour = self:SelectFromTable()

end
