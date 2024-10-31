-- Defines the Entity's type, base, printable name, and author for shared access (both server and client)
ENT.Type = "anim" -- Sets the Entity type to 'anim', indicating it's an animated Entity.
ENT.Base = "base_gmodentity" -- Specifies that this Entity is based on the 'base_gmodentity', inheriting its functionality.
ENT.PrintName = "Ambience" -- The name that will appear in the spawn menu.
ENT.Author = "MarkedOff" -- The author's name for this Entity.
ENT.Category = "MarkedOff" -- The category for this Entity in the spawn menu.
ENT.Contact = "" -- The contact details for the author of this Entity.
ENT.Purpose = "" -- The purpose of this Entity.
ENT.Spawnable = true -- Specifies whether this Entity can be spawned by players in the spawn menu.
ENT.Editable = true
ENT.IconOverride = "sprites/sprite_ambience.png"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT


function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "SoundPath",	{ KeyName = "SoundPath",	Edit = { type = "String", order = 1, category = "Main Music",	waitforenter = true } })
	self:NetworkVar( "Int", 0, "Range",	{ KeyName = "Range",	Edit = { type = "Int",	order = 2, category = "Main Music", min = 0, max = 10000 } })
	self:NetworkVar( "Float", 0, "Isolation",	{ KeyName = "Isolation",	Edit = { type = "Float",	order = 3, category = "Main Music", min = 0, max = 1 } })
	self:NetworkVar( "Float", 1, "Volume",	{ KeyName = "Volume",	Edit = { type = "Float",	order = 4, category = "Main Music", min = 0, max = 1 } })
	self:NetworkVar( "Float", 2, "FadeTime",	{ KeyName = "FadeTime",	Edit = { type = "Float",	order = 5, category = "Main Music", min = 0, max = 10 } })
	
	self:NetworkVar( "String", 1, "PanicSoundPath",	{ KeyName = "PanicSoundPath",	Edit = { type = "String", order = 1, category = "Combat Music",	waitforenter = true } })
	
	self:SetPanicSoundPath("music/Paladin's Quest/10.wav")
	self:SetSoundPath("music/Record of Lodoss War/1.wav")
	self:SetRange(1000)
	self:SetIsolation(0.7)
	self:SetVolume(1)
	self:SetFadeTime(3)
	
	if ( CLIENT ) then
		self:NetworkVarNotify( "SoundPath", self.OnSoundPathChanged )
		self:NetworkVarNotify( "Volume", self.OnVolumeChanged )
	end
end


