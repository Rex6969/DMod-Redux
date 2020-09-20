-- Purpose: returns random value from a table
-- I have no idea if drgbase already has this so i am putting it there

function ENT:GetTableValue( tbl )
	if not tbl then return end
	return tbl[math.random( #tbl ) ]
end

-- Purpose: getting random anim from specific animation table
	
function ENT:ExtractAnimation( tbl, key )
	return self:GetTableValue( tbl[key] ) or ""
end

-- Purpose: getting specific anim from specific animation table
  
function ENT:ExtractAnimation2( tbl, key1, key2 )
	return tbl[ key1 ][ key2 ] or ""
end

function ENT:GroundDist( pos, dist )
	local trdata = {}
	trdata.start = pos
	trdata.endpos = pos - Vector ( 0, 0, dist)
	trdata.filter = {self}
	local tr = util.TraceLine(trdata)
	return tr.Fraction*dist
end