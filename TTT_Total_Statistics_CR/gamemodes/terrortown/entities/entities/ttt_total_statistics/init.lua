AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

--declare our variables for various shenanigans
local PlayerStats = {}
local FirstBeenKilled = false
local SwapperKilled = false
local StartingTraitors = {}
local CurrentPlayers = {}
local StartingRoles = {}
local PreviousRoundDebug = ""

util.AddNetworkString("TotalStatistics_AskClientEquipmentName")
util.AddNetworkString("TotalStatistics_SendClientEquipmentName")

local function LoadPlayerStats()
	if not file.Exists("ttt", "DATA") then file.CreateDir("ttt_total_statistics") end
	if not file.Exists("ttt/ttt_total_statistics", "DATA") then file.CreateDir("ttt/ttt_total_statistics") end
	if not file.Exists("ttt/ttt_total_statistics/stats.txt", "DATA") then file.Write("ttt/ttt_total_statistics/stats.txt", "") end
	local data = file.Read("ttt/ttt_total_statistics/stats.txt", "DATA")
	if data == "" then return end
	PlayerStats = util.JSONToTable(data)
	
	--check if format is up to date and update it if not
	local updated = false
	for steamID, record in pairs(PlayerStats) do
		if PlayerStats[steamID]["DetectiveEquipment"] == nil then
			updated = true
			PlayerStats[steamID]["DetectiveEquipment"] = {}
		end
		if PlayerStats[steamID]["TraitorEquipment"] ==nil then
			updated = true
			PlayerStats[steamID]["TraitorEquipment"] = {}
		end
	end
	if updated then
		print("Updated ttt_total_statistics stats.txt to latest version!")
		updated = false
	end
end

local function AddNewPlayer(ID, nick)
	PlayerStats[ID] = {}
	local rolestring = ""
	for r = 0, ROLE_MAX do
		rolestring = ROLE_STRINGS[r]
		PlayerStats[ID][rolestring..'Rounds'] = 0
		PlayerStats[ID][rolestring..'Wins'] = 0
	end

	local stats = {'CrookedCop', 'TriggerHappyInnocent', 'TotalFallDamage', 'KilledFirst', 'TotalRoundsPlayed'}
	for _, s in ipairs(stats) do
		PlayerStats[ID][s] = 0
	end

	local statArray = {'TraitorPartners', 'DetectiveEquipment', 'TraitorEquipment'}
	for _, a in ipairs(statArray) do
		PlayerStats[ID][a] = {}
	end
end

local function SavePlayerStats()
	local str = util.TableToJSON(PlayerStats, true) 
	file.Write("ttt/ttt_total_statistics/stats.txt", str)
end

local function ResetAllPlayerStats()
	file.Delete("ttt/ttt_total_statistics/stats.txt")
	LoadPlayerStats()
end

concommand.Add("ttt_totalstatistics_reset", function(ply, cmd, args, str)
	file.Delete("ttt/ttt_total_statistics/stats.txt")
	table.Empty(PlayerStats)
	LoadPlayerStats()
	for k, v in pairs(player.GetAll()) do
		AddNewPlayer(v:SteamID(), v:Nick())
	end
	SavePlayerStats()
end)

concommand.Add("ttt_totalstatistics_printplayerstats", function(ply, cmd, args, str)
	PrintTable(PlayerStats)
end)

concommand.Add("ttt_totalstatistics_debuglastround", function(ply, cmd, args, str)
	print(PreviousRoundDebug)
end)

LoadPlayerStats()

gameevent.Listen("player_connect")
hook.Add("player_connect", "TotalStatistics_CheckIfNewPlayer", function(data)
	local record = PlayerStats[data.networkid]
	if  not record then
		AddNewPlayer(data.networkid, data.name)
	end
end)

hook.Add("TTTBeginRound", "TotalStatistics_StartOfRoundLogic", function()
	--reset our temp variables to keep track of who was what and did what for the funky roles
	FirstBeenKilled = false
	SwapperKilled = false
	table.Empty(CurrentPlayers)
	table.Empty(StartingTraitors)
	table.Empty(StartingRoles)
	PreviousRoundDebug = ""
	
	CurrentPlayers = team.GetPlayers(TEAM_TERROR) 
	
	--find traitors and their partners
	--also stuck swapper spawn and starting zombie team capture on the end
	for k, ply in pairs(CurrentPlayers) do
	
		StartingRoles[ply:SteamID()] = ply:GetRole()
	
		if ply:IsTraitorTeam() then
			table.insert(StartingTraitors, ply)
		end
	end
	
	PrintTable(StartingRoles)
end)

hook.Add("EntityTakeDamage", "TotalStatistics_FallDamageCapture", function(ply, dmginfo)
	if(ply:IsPlayer() and dmginfo:IsFallDamage()) then
		if dmginfo:GetDamage() > 100 then --cap the damage or you get +5000 for falling through the world
			PlayerStats[ply:SteamID()].TotalFallDamage = PlayerStats[ply:SteamID()].TotalFallDamage + 100 
		else
			PlayerStats[ply:SteamID()].TotalFallDamage = PlayerStats[ply:SteamID()].TotalFallDamage + math.Round(dmginfo:GetDamage())
		end
	end
end)

hook.Add("DoPlayerDeath", "TotalStatistics_MurderCapture", function(victim, attacker)
	--crooked cop capture
	if((attacker:IsPlayer() and attacker:GetRole()== ROLE_DETECTIVE) and
	(victim:IsPlayer() and (victim:IsInnocentTeam() or victim:IsJesterTeam()))) then
		PlayerStats[attacker:SteamID()].CrookedCop = PlayerStats[attacker:SteamID()].CrookedCop + 1
	end
	
	--trigger-happy innocent capture
	if((attacker:IsPlayer() and attacker:IsInnocentTeam()) and
	(victim:IsPlayer() and (victim:IsInnocentTeam() or victim:IsJesterTeam()))) then
		PlayerStats[attacker:SteamID()].TriggerHappyInnocent = PlayerStats[attacker:SteamID()].TriggerHappyInnocent + 1
	end
	
	--swapper win logic
	if(attacker:IsPlayer() and (victim:IsPlayer() and victim:GetRole()==ROLE_SWAPPER)) then
		SwapperKilled = true
	end
	
	--first killed capture
	if victim:IsValid() and not FirstBeenKilled then
		PlayerStats[victim:SteamID()].KilledFirst = PlayerStats[victim:SteamID()].KilledFirst + 1
		FirstBeenKilled = true
	end
end)

hook.Add("TTTEndRound", "TotalStatistics_EndOfRoundLogic", function(result)
	
	for k, v in pairs(CurrentPlayers) do

		if(v:IsValid()) then

			PreviousRoundDebug = PreviousRoundDebug .. v:Nick() .. " was "

			--role plays and wins capture
			PlayerStats[v:SteamID()].TotalRoundsPlayed = PlayerStats[v:SteamID()].TotalRoundsPlayed + 1
			local rolestring = ""
			local FoundRole = false
			for r = 0, ROLE_MAX do
				if StartingRoles[v:SteamID()] == r  then
					FoundRole = true
					rolestring = ROLE_STRINGS[r]
					PlayerStats[v:SteamID()][rolestring..'Rounds'] = PlayerStats[v:SteamID()][rolestring..'Rounds'] + 1
					PreviousRoundDebug = PreviousRoundDebug ..rolestring.." and "
					if r == ROLE_SWAPPER then
						if(SwapperKilled) then
							PlayerStats[v:SteamID()][rolestring..'Wins'] = PlayerStats[v:SteamID()][rolestring..'Wins'] + 1
							PreviousRoundDebug = PreviousRoundDebug .. "won. "
						else
							PreviousRoundDebug = PreviousRoundDebug .. "lost. "
						end
					elseif r == ROLE_BEGGAR then
						if v:IsBeggar() then
							PreviousRoundDebug = PreviousRoundDebug .. "lost. "
						else
							PlayerStats[v:SteamID()][rolestring..'Wins'] = PlayerStats[v:SteamID()][rolestring..'Wins'] + 1
							PreviousRoundDebug = PreviousRoundDebug .. "won. "
						end
					elseif r == ROLE_BODYSNATCHER then
						if v:IsBodysnatcher() then
							PreviousRoundDebug = PreviousRoundDebug .. "lost. "
						else
							PlayerStats[v:SteamID()][rolestring..'Wins'] = PlayerStats[v:SteamID()][rolestring..'Wins'] + 1
							PreviousRoundDebug = PreviousRoundDebug .. "won. "
						end
					elseif v:IsInnocentTeam() then
						if result == WIN_INNOCENT or result == WIN_TIMELIMIT then
							PlayerStats[v:SteamID()][rolestring..'Wins'] = PlayerStats[v:SteamID()][rolestring..'Wins'] + 1
							PreviousRoundDebug = PreviousRoundDebug .. "won. "
						else
							PreviousRoundDebug = PreviousRoundDebug .. "lost. "
						end
					elseif v:IsTraitorTeam() then
						if result == WIN_TRAITOR then
							PlayerStats[v:SteamID()][rolestring..'Wins'] = PlayerStats[v:SteamID()][rolestring..'Wins'] + 1
							PreviousRoundDebug = PreviousRoundDebug .. "won. "
						else
							PreviousRoundDebug = PreviousRoundDebug .. "lost. "
						end
					elseif v:IsJester() then
						if result == WIN_JESTER then
							PlayerStats[v:SteamID()][rolestring..'Wins'] = PlayerStats[v:SteamID()][rolestring..'Wins'] + 1
							PreviousRoundDebug = PreviousRoundDebug .. "won. "
						else
							PreviousRoundDebug = PreviousRoundDebug .. "lost. "
						end
					elseif v:IsClown() then
						if result == WIN_CLOWN then
							PlayerStats[v:SteamID()][rolestring..'Wins'] = PlayerStats[v:SteamID()][rolestring..'Wins'] + 1
							PreviousRoundDebug = PreviousRoundDebug .. "won. "
						else
							PreviousRoundDebug = PreviousRoundDebug .. "lost. "
						end
					elseif v:IsOldMan() then
						if result == WIN_OLDMAN then
							PlayerStats[v:SteamID()][rolestring..'Wins'] = PlayerStats[v:SteamID()][rolestring..'Wins'] + 1
							PreviousRoundDebug = PreviousRoundDebug .. "won. "
						else
							PreviousRoundDebug = PreviousRoundDebug .. "lost. "
						end
					elseif v:IsKiller() then
						if result == WIN_KILLER then
							PlayerStats[v:SteamID()][rolestring..'Wins'] = PlayerStats[v:SteamID()][rolestring..'Wins'] + 1
							PreviousRoundDebug = PreviousRoundDebug .. "won. "
						else
							PreviousRoundDebug = PreviousRoundDebug .. "lost. "
						end
					elseif v:IsZombie() and not v:IsTraitorTeam() and not v:IsMonsterTeam() then
						if result == WIN_ZOMBIE then
							PlayerStats[v:SteamID()][rolestring..'Wins'] = PlayerStats[v:SteamID()][rolestring..'Wins'] + 1
							PreviousRoundDebug = PreviousRoundDebug .. "won. "
						else
							PreviousRoundDebug = PreviousRoundDebug .. "lost. "
						end
					elseif v:IsMonsterTeam() then
						if result == WIN_MONSTER then
							PlayerStats[v:SteamID()][rolestring..'Wins'] = PlayerStats[v:SteamID()][rolestring..'Wins'] + 1
							PreviousRoundDebug = PreviousRoundDebug .. "won. "
						else
							PreviousRoundDebug = PreviousRoundDebug .. "lost. "
						end
					end
					break
				end
			end

			if not FoundRole then
				PreviousRoundDebug = PreviousRoundDebug .. "unknown."
				print("[TTT] Total Statistics: "..v:Nick().." has an unexpected role ("..v:GetRole()..")")
			end

			PreviousRoundDebug = PreviousRoundDebug .. "\n"
		end
	end
	
	for k1, player in ipairs(StartingTraitors) do
		for k2, partner in ipairs(StartingTraitors) do
			if(partner==player) then
			else
				if(PlayerStats[player:SteamID()]["TraitorPartners"][partner:SteamID()] == nil) then --if hasn't been paired before
					PlayerStats[player:SteamID()]["TraitorPartners"][partner:SteamID()] = {Nick = partner:Nick(), Rounds = 0, Wins = 0}
				end
				
				PlayerStats[player:SteamID()]["TraitorPartners"][partner:SteamID()].Rounds = PlayerStats[player:SteamID()]["TraitorPartners"][partner:SteamID()].Rounds + 1
				if(result==WIN_TRAITOR) then 
					PlayerStats[player:SteamID()]["TraitorPartners"][partner:SteamID()].Wins = PlayerStats[player:SteamID()]["TraitorPartners"][partner:SteamID()].Wins + 1
				end
			end
		end
	end
	
	SavePlayerStats()
end)

--recieve data request from client and table back
util.AddNetworkString("TotalStatistics_PlayerStatsMessage")
util.AddNetworkString("TotalStatistics_RequestPlayerStats")
net.Receive("TotalStatistics_RequestPlayerStats", function(len, ply)
	net.Start("TotalStatistics_PlayerStatsMessage")
	net.WriteTable(PlayerStats)
	net.Send(ply)
end)

local function RenameWeps(name)
    if name == "sipistol_name" then
        return "Silenced Pistol"
    elseif name == "knife_name" then
        return "Knife"
    elseif name == "newton_name" then
        return "Newton Launcher"
    elseif name == "tele_name" then
        return "Teleporter"
    elseif name == "hstation_name" then
        return "Health Station"
    elseif name == "flare_name" then
        return "Flare Gun"
    elseif name == "decoy_name" then
        return "Decoy"
    elseif name == "radio_name" then
        return "Radio"
    elseif name == "polter_name" then
        return "Poltergeist"
    elseif name == "vis_name" then
        return "Visualizer"
    elseif name == "defuser_name" then
        return "Defuser"
    elseif name == "stungun_name" then
        return "UMP Prototype"
    elseif name == "binoc_name" then
        return "Binoculars"
	elseif name == "item_radar" then
        return "Radar"
	elseif name == "item_armor" then
        return "Body Armor"
	elseif name == "dragon_elites_name" then
        return "Dragon Elites"
	elseif name == "silenced_m4a1_name" then
        return "Silenced M4A1"
	elseif name == "slam_name" then
        return "M4 SLAM"
	elseif name == "jihad_bomb_name" then
        return "Jihad Bomb"
    elseif name == "item_slashercloak" then --custom mods friends and I made ;)
		return "Slasher Cloak"
	elseif name == "heartbeat_monitor_name" then
		return "Heartbeat Monitor"
	else
        return name
    end
end

--recive the client name for the equipment they bought
net.Receive("TotalStatistics_SendClientEquipmentName", function(len, ply)
    local name = RenameWeps(net.ReadString())
	local error = net.ReadBool()
	if error then
		print("Failed to find equipment ("..name..") bought by "..ply:Nick().." for [TTT] Total Statistics!")
		
	elseif ply:GetRole()==ROLE_DETECTIVE then
		if(PlayerStats[ply:SteamID()]["DetectiveEquipment"][name] == nil) then --if hasn't been paired before
			PlayerStats[ply:SteamID()]["DetectiveEquipment"][name] = 0
		end
		PlayerStats[ply:SteamID()]["DetectiveEquipment"][name] = PlayerStats[ply:SteamID()]["DetectiveEquipment"][name] + 1
	
	elseif ply:IsTraitorTeam() then
		if(PlayerStats[ply:SteamID()]["TraitorEquipment"][name] == nil) then --if hasn't been paired before
			PlayerStats[ply:SteamID()]["TraitorEquipment"][name] = 0
		end
		PlayerStats[ply:SteamID()]["TraitorEquipment"][name] = PlayerStats[ply:SteamID()]["TraitorEquipment"][name] + 1
	
	end
end)