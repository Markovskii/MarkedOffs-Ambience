AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")



-- Server-side initialization function for the entity
function ENT:Initialize()

	self:SetModel( "models/hunter/blocks/cube05x05x05.mdl" )
	
	if IsValid(self:GetCreator()) then
		self:PhysicsInit( SOLID_VPHYSICS )
		--self:EnableCustomCollisions()
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		self:DrawShadow(false)
	
	
	else 
		self:EnableCustomCollisions()
		self:SetNoDraw(true)
	end
end



--This is the example from the wiki page
--"Allows players to shoot through the entity, but still stand on it and use the Physics Gun on it, etc."
--local sent_contents = CONTENTS_DEBRIS
local sent_contents = CONTENTS_SOLID
function ENT:TestCollision( startpos, delta, isbox, extents, mask )
	if bit.band( mask, sent_contents ) != 0 then return true end
end

