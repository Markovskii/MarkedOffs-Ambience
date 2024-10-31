

include("shared.lua")

local sprite = Material( "sprites/sprite_ambience" )

function ENT:Draw()
	--self:DrawModel()
	if self == halo.RenderedEntity() then return end
	
	local pos = self:GetPos()
	local size = 25
	
	render.SetMaterial(sprite)
	render.DrawSprite( pos, size, size, Color(255,255,255))

	return
end

function ENT:Initialize()
	table.insert( ambient_entities, self )
end

function ENT:OnSoundPathChanged()
	AmbiencePathChange(self)
end

function ENT:OnVolumeChanged()
	AmbienceVolumeChange(self)
end

function ENT:OnRemove()
	self:OnSoundPathChanged()
	table.RemoveByValue( ambient_entities, self )
	if ambient_tracks[self] then table.RemoveByValue( ambient_tracks, ambient_tracks[self] ) end
end

function ENT:CanSee(pos)
	if ((pos + Vector(0,0,30)) - self:GetPos()):LengthSqr() > self:GetRange()^2 then return false end

	local tracedata = {}
	tracedata.start = self:GetPos()
	tracedata.endpos = pos + Vector(0,0,30)
	tracedata.filter = self
	tracedata.collisiongroup = COLLISION_GROUP_DEBRIS
	local trace = util.TraceLine(tracedata)
	
	if trace.Fraction < self:GetIsolation() then return false end
	return true
end