local META_ENT = FindMetaTable("Entity")

----------------------------------------------------------------------------------------------------
-- Hitgroup Translator
----------------------------------------------------------------------------------------------------

local HGTable = {
	[8] = "Head",
	[2] = "Chest",
	[3] = "Stomach",
	[4] = "LeftArm",
	[5] = "RightArm",
	[6] = "LeftLeg",
	[7] = "RightLeg"
	--[1001] = "Lower",
	--[1002] = "Upper"
	--HITGROUP_GENERIC = "Generic"
}

local GoreableTable = {
	[8] = "Head",
	[4] = "LeftArm",
	[5] = "RightArm",
	[6] = "LeftLeg",
	[7] = "RightLeg",
}

function META_ENT:RX_HitGroupToString( hg )
	return HGTable[hg]-- || "Stomach"
end

function META_ENT:RX_GoreHitGroupToString( hg )
	print( hg )
	return GoreableTable[hg]-- || "Stomach"
end

----------------------------------------------------------------------------------------------------
-- Explosive damage hitgroup fix
----------------------------------------------------------------------------------------------------

function ENT:RX_Damage_FixHitGroup( dmg, hitgroup )

	if ( hitgroup ~= 0 ) then
		return hitgroup
	else
	
		local tr = {}
		
		local dmgpos = dmg:GetDamagePosition()
		tr.start = dmgpos
		tr.endpos =( self:GetPos() + self:OBBCenter() )
		--tr.endpos.z = dmgpos.z
		tr.mask = MASK_SHOT
		
		--print( dmgpos )
		
		local trace = util.TraceLine( tr )
		
		debugoverlay.Cross( tr.start, 25, 50 )
		debugoverlay.Cross( trace.HitPos, 25, 50 )
		
		--if trace.Hit then
			--print( "success" )
		return self:GetHitBoxHitGroup( trace.HitBox, 0 )
		--end
	end
	
end

----------------------------------------------------------------------------------------------------
-- Bone collapsing
----------------------------------------------------------------------------------------------------

local BoneMoveTable = {

	leftshoulder = true,
	leftclavicle = true,
	leftarm = true,
	leftarmroll = true,
	leftforearm = true,
	leftforearmroll = true,
	
	lefthand = true,
	
	--
	
	rightshoulder = true,
	rightclavicle = true,
	rightarm = true,
	rightarmroll = true,
	rightforearm = true,
	rightforearmroll = true,
	
	righthand = true,
	
	--
	
	leftupleg = true,
	leftleg = true,
	leftfoot = true,
	
	--
	
	rightupleg = true,
	rightleg = true,
	rightfoot = true,
	
	--
	
	head = true,
	neck = true
	
}

local function CollapseBone( self, bonename, boneid )
	local boneid = isstring( bonename ) && self:LookupBone( bonename ) || boneid
	local length = self:BoneLength( boneid )
	
	if BoneMoveTable[ bonename || self:GetBoneName( boneid ) ] then -- HACK
		self:ManipulateBonePosition( boneid, Vector( -( length + 5 ), 0, 0 ) )
	end
	
	self:ManipulateBoneScale( boneid, Vector( 0, 0, 0 ) )
	
end

local function CollapseChildBones() end
local function CollapseChildBones( self, boneid )

	CollapseBone( self, nil, boneid )
	local children = self:GetChildBones( boneid )
	if #children < 1 then return end
	for _, v in pairs( children ) do
		CollapseChildBones( self, v )
	end
	
end

function META_ENT:DOOM_CollapseLimb( bonename )

	local boneid = self:LookupBone( bonename )
	CollapseBone( self, nil, boneid )
	CollapseChildBones( self, boneid )
	
end

----------------------------------------------------------------------------------------------------
-- Wound and gore applying
----------------------------------------------------------------------------------------------------

function META_ENT:DOOM_ApplyWound( wound )
	print( wound )
	print( "Wound"..wound )
	self:SetFlexWeight( self:GetFlexIDByName( "Wound"..wound ), 1 )
	self:SetBodygroup( self:FindBodygroupByName( "Wound"..wound ), 1 )
end

function META_ENT:DOOM_ApplyGore( wound )
	self:DOOM_CollapseLimb( wound )
	self:SetBodygroup( self:FindBodygroupByName( "Gore"..wound ), 1 )
end