util.AddNetworkString( "CombatAmbienceTrigger" )

util.AddNetworkString( "PlaceAmbience" )
util.AddNetworkString( "RemoveAmbience" )



local function SpawnAmbience()

	local first = false
	if not file.Exists( "Ambience/"..game.GetMap()..".json", "DATA" ) then
		first = true
	end
	
	local tabl = {}
	if !first then
		local json = file.Read( "Ambience/"..game.GetMap()..".json", "DATA" )
		tabl = util.JSONToTable( json )
	end
	
	for i, ent in pairs( tabl ) do
		local ambience = ents.Create( "ambience" )
		ambience:SetPos( ent[1] )
		ambience:Spawn()
		ambience:SetPanicSoundPath(ent[2])
		ambience:SetSoundPath(ent[3])
		ambience:SetRange(ent[4])
		ambience:SetIsolation(ent[5])
		ambience:SetVolume(ent[6])
		ambience:SetFadeTime(ent[7])
	end
end


--timer.Simple( 1, SpawnAmbience )

local function PlaceAmbience(len, pla)
	
	local first = false
	if not file.Exists( "Ambience/"..game.GetMap()..".json", "DATA" ) then
		first = true
	end
	
	local ambience = net.ReadEntity()
	local pos = ambience:GetPos()
	local pos = Vector(math.floor(pos.x),math.floor(pos.y),math.floor(pos.z))
	ambience:SetPos(pos)
	local ambience_entity = {
		--- Player index 1, since its the first in the table
		{
			pos,
			ambience:GetPanicSoundPath(),
			ambience:GetSoundPath(),
			ambience:GetRange(),
			ambience:GetIsolation(),
			ambience:GetVolume(),
			ambience:GetFadeTime()
		}
	}
	
	local tabl = {}
	if !first then
		local json = file.Read( "Ambience/"..game.GetMap()..".json", "DATA" )
		tabl = util.JSONToTable( json )
	end
	
--	PrintTable(tabl)
--	PrintTable(ambience_entity)
	table.Add( tabl, ambience_entity )
--	PrintTable(tabl)
	
	json = util.TableToJSON( tabl )
	
	file.Write( "Ambience/"..game.GetMap()..".json", json )
end

local function RemoveAmbience(len, pla)
	
	local ambience = net.ReadEntity()
	local pos = ambience:GetPos()
	
	local json = file.Read( "Ambience/"..game.GetMap()..".json", "DATA" )
	tabl = util.JSONToTable( json )
	
	for i, ent in pairs( tabl ) do
--		print(i,ent[1],pos)
		if ent[1] == pos then table.remove( tabl, i ) continue end
	end
	
	PrintTable(tabl)
	
	json = util.TableToJSON( tabl )
	file.Write( "Ambience/"..game.GetMap()..".json", json )

	ambience:Remove()
end




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
hook.Add( "InitPostEntity", "SpawnAmbience", SpawnAmbience)

net.Receive( "PlaceAmbience", PlaceAmbience)
net.Receive( "RemoveAmbience", RemoveAmbience)
