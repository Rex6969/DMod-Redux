-- Purpose: returns random value from a table
-- I have no idea if drgbase already has this so i am putting it there

function ENT:GetTableValue( tbl )
  return tbl[math.random( #tbl ) ] or false
end

-- Purpose: getting random anim from specific animation table
	
function ENT:ExtractAnimation( tbl, key )
	return self:GetTableValue( tbl[key] ) or ""
end

-- Purpose: getting specific anim from specific animation table
  
function ENT:ExtractAnimation2( tbl, key1, key2 )
	return tbl[ key1 ][ key2 ] or ""
end
