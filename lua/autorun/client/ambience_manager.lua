ambient_entities = {}

ambient_tracks = {}

local king_ambience = NULL

local ambient_jeopardy = 0

local panicked = false

local desired_volume = 0.5

concommand.Add( "desired_volume", function( ply, cmd, args, str )
	local volume = tonumber(args[1])
	if not volume then return end
	if volume > 1 or 0 > volume then print("please enter a number from 0 to 1") return end
	desired_volume = args[1]
	AmbienceVolumeChange(king_ambience)
	print("desired volume set to ".. args[1])
end )

local function AppropriateAmbienceFor(ent)
	if !panicked then return ent:GetSoundPath() end
	return ent:GetPanicSoundPath()
end

local function Purge()
	if IsValid(king_ambience) then 
		ambient_tracks[king_ambience]:ChangeVolume( 0, king_ambience:GetFadeTime() )
	end
	table.Empty( ambient_tracks )
	king_ambience = NULL
end


function AmbienceVolumeChange(ambience)
	if IsValid(king_ambience) and king_ambience == ambience then
		ambient_tracks[king_ambience]:ChangeVolume( king_ambience:GetVolume()*desired_volume , 1 )
	end
end

function AmbiencePathChange(ambience)
	if IsValid(king_ambience) and king_ambience == ambience then
		Purge()
	end
end

local function Compete()
	local player_pos = LocalPlayer():GetPos()
	local best_dist = -1
	local best_ambience = NULL
	for _, ambience in pairs( ambient_entities ) do
		if !ambience:CanSee(player_pos) then continue end
		local dist = (ambience:GetPos() - player_pos):LengthSqr()
		if dist > best_dist and best_dist != -1 then continue end
		best_ambience = ambience
		best_dist = dist
	end
	return best_ambience
end



local function JeopardyTick()
	if ambient_jeopardy == 0 then return end
	ambient_jeopardy = ambient_jeopardy - 1
	
	if ambient_jeopardy == 5 and panicked then
		Purge()
		panicked = false
	end
end

local function JeopardyAmbience()
	local danger = net.ReadInt( 4 )+8
	--print(danger, "!")
	if ambient_jeopardy < danger then
		ambient_jeopardy = danger
	end
	
	if ambient_jeopardy > 5 and not panicked then
		Purge()
		panicked = true
	end
end


local function Enter(new)
	if not ambient_tracks[new] then
		local ambience_track = CreateSound( LocalPlayer(), AppropriateAmbienceFor(new) )
		ambience_track:Play()
		ambience_track:ChangeVolume( 0, 0 )
		ambient_tracks[new] = ambience_track
	end
	ambient_tracks[new]:ChangeVolume( new:GetVolume()*desired_volume, new:GetFadeTime() )
end

local function Exit(old)
	ambient_tracks[old]:ChangeVolume( 0, old:GetFadeTime() )
	
	timer.Simple(old:GetFadeTime(), function() 
	
	if not ambient_tracks[old] then return end
	if ambient_tracks[old]:GetVolume() != 0 then return end
	ambient_tracks[old]:Stop(); table.RemoveByValue( ambient_tracks, ambient_tracks[old] ) 
	
	end  )

end

local function Crown(old, new)
	if IsValid(old) then
		Exit(old)
	end
	if IsValid(new) then
		Enter(new)
	end
	
end

timer.Create( "MarkedOff_Ambience", 3, 0, function() 
	JeopardyTick()
	
	if table.IsEmpty( ambient_entities ) then return false end
	
	local best_ambience = Compete()
	
--	PrintTable(ambient_entities)
--	print(king_ambience, best_ambience, ambient_jeopardy)
--	PrintTable(ambient_tracks)
	
	if best_ambience == king_ambience then return false end
	
	if IsValid(best_ambience) and IsValid(king_ambience) then
		if AppropriateAmbienceFor(best_ambience) == AppropriateAmbienceFor(king_ambience) then return false end
	end
	Crown(king_ambience, best_ambience)
	king_ambience = best_ambience
	
--	if IsValid(best_ambience) then
--		timer.Adjust( "MarkedOff_Ambience", best_ambience:GetRange()/500+1)
--	else
--		timer.Adjust( "MarkedOff_Ambience", 3)
--	end
end )

net.Receive( "CombatAmbienceTrigger", JeopardyAmbience)






concommand.Add( "ambience_list", function( ply, cmd, args, str )

	local _, directories = file.Find( "sound/music/*", "GAME" )
	
	
	for i=1,#directories do 
		print("---- "..directories[i].." ----")
		local files, _ = file.Find( "sound/music/"..directories[i].."/*", "GAME" )
		for j=1,#files do 
			print("music/"..directories[i].."/"..files[j])
		end
	end 
	
end )





-- PERMAPROP CODE
concommand.Add( "ambience_place", function( ply, cmd, args, str )
	if not ply:IsAdmin() then return end
	if not IsValid(king_ambience) then return end
	
	net.Start( "PlaceAmbience" )
	net.WriteEntity( king_ambience )
	net.SendToServer()
	
end )

concommand.Add( "ambience_remove", function( ply, cmd, args, str )
	if not ply:IsAdmin() then return end
	if not IsValid(king_ambience) then return end

	net.Start( "RemoveAmbience" )
	net.WriteEntity( king_ambience )
	net.SendToServer()
	
	
end )