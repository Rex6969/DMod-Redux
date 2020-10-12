
----------------------------------------------------------------------------------------------------

function ENT:Table_Get( tbl )
	return tbl && tbl[math.random( #tbl ) ] || {}
end

function ENT:Table_ExtractAnimation( tbl, key ) 
	return self:Table_Get( tbl[ key ] ) || "" 
end

----------------------------------------------------------------------------------------------------