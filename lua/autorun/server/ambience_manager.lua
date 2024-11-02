-- SETUP MUSIC TABLE

local function MusicTableInit()
	local tabl = {}
	local _, directories = file.Find( "sound/music/*", "GAME" )
	for i=1,#directories do 
		local files, _ = file.Find( "sound/music/"..directories[i].."/*", "GAME" )
		for j=1,#files do
			tabl["music/"..directories[i].."/"..files[j]] = "music/"..directories[i].."/"..files[j]
		end
	end
	return tabl
end
music_table = MusicTableInit()



util.AddNetworkString( "CombatAmbienceTrigger" )

--util.AddNetworkString( "PlaceAmbience" )
--util.AddNetworkString( "RemoveAmbience" )
util.AddNetworkString( "RaiseAmbience" )
util.AddNetworkString( "PlaceAmbience" )

local ambient_entities = {}

local function SpawnAmbience()
	ambient_entities = {}
--	print("spawning ambience")
	if not file.Exists( "Ambience/"..game.GetMap()..".json", "DATA" ) then return end
	
	local json = file.Read( "Ambience/"..game.GetMap()..".json", "DATA" )
	tabl = util.JSONToTable( json )
	
	for i, ent in pairs( tabl ) do
		local ambience = ents.Create( "ambience" )
		ambience:SetPos( ent[1] )
		ambience:Spawn()
		
		if not music_table[ent[2]] == nil then ambience:SetPanicSoundPath(ent[2]) else ambience:SetSoundPath("music/Vanilla/default_song.wav") end
		if not music_table[ent[3]] == nil then ambience:SetSoundPath(ent[3]) else ambience:SetSoundPath("music/Vanilla/default_song.wav") end
		ambience:SetRange(ent[4])
		ambience:SetIsolation(ent[5])
		ambience:SetVolume(ent[6])
		ambience:SetFadeTime(ent[7])
		ambience:Hide()
		table.insert( ambient_entities, ambience )
	end
end

local function RaiseAmbience()
--	PrintTable(ambient_entities)
	for i, ent in pairs( ambient_entities ) do
		ent:Show()
	end
--	json = util.TableToJSON( {} )
--	file.Write( "Ambience/"..game.GetMap()..".json", json )
	file.Delete( "Ambience/"..game.GetMap()..".json", "DATA")
	ambient_entities = {}
end

local function PlaceAmbience(len, pla)
--	local first = false
--	if not file.Exists( "Ambience/"..game.GetMap()..".json", "DATA" ) then
--		first = true
--	end
	
	local tabl = {}
	for i, ambience in pairs( ents.FindByClass( "ambience" ) ) do
		local ambience_entity = {
			{
				ambience:GetPos(),
				ambience:GetPanicSoundPath(),
				ambience:GetSoundPath(),
				ambience:GetRange(),
				ambience:GetIsolation(),
				ambience:GetVolume(),
				ambience:GetFadeTime()
			}
		}
--		PrintTable(ambience_entity)
		ambience:Hide()
		table.Add( ambient_entities, {ambience} )
		table.Add( tabl, ambience_entity )
	end
--	PrintTable(tabl)
--	PrintTable(ambient_entities)
	json = util.TableToJSON( tabl )
	file.Write( "Ambience/"..game.GetMap()..".json", json )
end

--local function DeleteAmbience()
--	PrintTable(ambient_entities)
--	for i, ent in pairs( ambient_entities ) do
--		ent:Remove()
--	end
--	ambient_entities = {}
--end

--timer.Simple( 1, SpawnAmbience )

--local function PlaceAmbience(len, pla)
--	
--	local first = false
--	if not file.Exists( "Ambience/"..game.GetMap()..".json", "DATA" ) then
--		first = true
--	end
--	
--	local ambience = net.ReadEntity()
--	local pos = ambience:GetPos()
--	local pos = Vector(math.floor(pos.x),math.floor(pos.y),math.floor(pos.z))
--	ambience:SetPos(pos)
--	local ambience_entity = {
--		--- Player index 1, since its the first in the table
--		{
--			pos,
--			ambience:GetPanicSoundPath(),
--			ambience:GetSoundPath(),
--			ambience:GetRange(),
--			ambience:GetIsolation(),
--			ambience:GetVolume(),
--			ambience:GetFadeTime()
--		}
--	}
--	
--	local tabl = {}
--	if !first then
--		local json = file.Read( "Ambience/"..game.GetMap()..".json", "DATA" )
--		tabl = util.JSONToTable( json )
--	end
--	
--	PrintTable(tabl)
--	PrintTable(ambience_entity)
--	table.Add( tabl, ambience_entity )
--	PrintTable(tabl)
--	
--	json = util.TableToJSON( tabl )
--	
--	file.Write( "Ambience/"..game.GetMap()..".json", json )
--end

--local function RemoveAmbience(len, pla)
--	
--	local ambience = net.ReadEntity()
--	local pos = ambience:GetPos()
--	
--	local json = file.Read( "Ambience/"..game.GetMap()..".json", "DATA" )
--	tabl = util.JSONToTable( json )
--	
--	for i, ent in pairs( tabl ) do
--		print(i,ent[1],pos)
--		if ent[1] == pos then table.remove( tabl, i ) return end
--	end
--	
--	PrintTable(tabl)
--	
--	json = util.TableToJSON( tabl )
--	file.Write( "Ambience/"..game.GetMap()..".json", json )
--
--	ambience:Remove()
--end




local function PlayerHurt( victim, attacker, healthRemaining, damageTaken )
	if victim == attacker or damageTaken <= 0 then return end
	local peril = damageTaken/healthRemaining*50
	if peril > 15 then peril = 15 end
	peril = peril-8
	net.Start( "CombatAmbienceTrigger" )
	net.WriteInt( peril, 4 )
	net.Send( victim )
	if attacker:IsPlayer() then
		net.Start( "CombatAmbienceTrigger" )
		net.WriteInt( peril, 4 )
		net.Send( attacker )
	end
end

hook.Add( "PlayerHurt", "CombatAmbienceFilter", PlayerHurt)
hook.Add( "InitPostEntity", "SpawnAmbienceSpawn", SpawnAmbience)
hook.Add( "PostCleanupMap", "SpawnAmbienceCleanup", SpawnAmbience)

--net.Receive( "PlaceAmbience", PlaceAmbience)
--net.Receive( "RemoveAmbience", RemoveAmbience)
net.Receive( "RaiseAmbience", RaiseAmbience)
net.Receive( "PlaceAmbience", PlaceAmbience)
--net.Receive( "DeleteAmbience", DeleteAmbience)
