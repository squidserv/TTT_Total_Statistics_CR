include('shared.lua')

local AccessButton = vgui.Create("DButton")
AccessButton:SetText("Total Statistics")
AccessButton:SetPos(ScrW()-160, ScrH()-60)
AccessButton:SetSize(150, 50)
AccessButton:Hide()

local ShowButton = false

hook.Add("TTTEndRound", "TotalStatistics_ShowButtonEndRound", function(result)
	ShowButton = true
end)

hook.Add("TTTPrepareRound", "TotalStatistics_HideButtonPrepareRound", function()
	ShowButton = false
end)

hook.Add("Think", "TotalStatistics_IsButtonVisible", function()
	if ((LocalPlayer():IsDeadTerror() or LocalPlayer():Team() == TEAM_SPEC) or ShowButton) then
		AccessButton:Show()
	else
		AccessButton:Hide()
	end
end)

surface.CreateFont( "TotalStatistics_DefaultItalics", {
	italic = true,
	size=14,
})

local PlayerStats = nil
local CustomRolesEnabled = false

--v crude way of finding out if custom roles have been mounted
if ROLE_KILLER == 12 then
	CustomRolesEnabled = true
end

local function GetPlayerData()
	net.Start("TotalStatistics_RequestPlayerStats")
	net.SendToServer()
end

net.Receive("TotalStatistics_PlayerStatsMessage", function()
	PlayerStats = net.ReadTable()
end)

local function DisplayWindow()
	
	GetPlayerData()

	local MainWindow = vgui.Create("DFrame")
	MainWindow:SetTitle("Total Statistics for Trouble in Terrorist Town")
	MainWindow:SetPos(ScrW() - 410, ScrH() - 495)
	MainWindow:SetSize(400, 425)
	MainWindow:SetDeleteOnClose(true)
	function MainWindow:OnClose() 
		gui.EnableScreenClicker(false)
	end

	local DataDisplay = vgui.Create("DListView", MainWindow)
	DataDisplay:SetPos(15, 125)
	DataDisplay:SetSize(370, 240)
	DataDisplay:SetMultiSelect(false)
	DataDisplay:AddColumn("", 1)
	DataDisplay:AddColumn("", 2)
	DataDisplay:SetSortable(true)
	
	local RefreshButton = vgui.Create("DButton", MainWindow)
	RefreshButton:SetText("Refresh window")
	RefreshButton:SetPos(MainWindow:GetWide()-115, MainWindow:GetTall()-45)
	RefreshButton:SetSize(100, 30)
	RefreshButton.DoClick = function()
		MainWindow:Close()
		DisplayWindow()
	end

	local DescriptionLabel = vgui.Create("DLabel", MainWindow)
	DescriptionLabel:SetText("")
	DescriptionLabel:SetPos(20, 95)
	DescriptionLabel:SetSize(360, 25)
	DescriptionLabel:SetContentAlignment(4)
	DescriptionLabel:SetFont("TotalStatistics_DefaultItalics")

	local StatisticLabel = vgui.Create("DLabel", MainWindow)
	StatisticLabel:SetText("Select statistic:")
	StatisticLabel:SetPos(20, 35)
	StatisticLabel:SetSize(90, 25)
	
	local RoleLabel = vgui.Create("DLabel", MainWindow)
	RoleLabel:SetText("Select role:")
	RoleLabel:SetPos(20, 65)
	RoleLabel:SetSize(90, 25)
	RoleLabel:Hide()
	
	local RoleDropdown = vgui.Create("DComboBox", MainWindow)
	RoleDropdown:SetText("")
	RoleDropdown:SetPos(110, 65)
	RoleDropdown:SetSize(275, 25)
	RoleDropdown:SetSortItems(false)
	RoleDropdown:AddChoice("Detective")
	RoleDropdown:AddChoice("Innocent")
	RoleDropdown:AddChoice("Traitor")
	if CustomRolesEnabled then
		RoleDropdown:AddChoice("Assassin")
		RoleDropdown:AddChoice("Hypnotist")
		RoleDropdown:AddChoice("Vampire")
		RoleDropdown:AddChoice("Zombie")
		RoleDropdown:AddChoice("Mercenary")
		RoleDropdown:AddChoice("Phantom")
		RoleDropdown:AddChoice("Glitch")
		RoleDropdown:AddChoice("Jester")
		RoleDropdown:AddChoice("Swapper")
		RoleDropdown:AddChoice("Killer")
	end
	RoleDropdown.OnSelect = function(index, value, str)
		DataDisplay:Clear()
		if str == "Detective" then
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.DetectiveWins/record.DetectiveRounds*100, 1))
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Innocent" then
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.InnocentWins/record.InnocentRounds*100, 1))
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Traitor" then
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.TraitorWins/record.TraitorRounds*100, 1))
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Assassin" then
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.AssassinWins/record.AssassinRounds*100, 1))
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Hypnotist" then
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.HypnotistWins/record.HypnotistRounds*100, 1))
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Vampire" then
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.VampireWins/record.VampireRounds*100, 1))
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Zombie" then
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.ZombieWins/record.ZombieRounds*100, 1))
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Mercenary" then
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.MercenaryWins/record.MercenaryRounds*100, 1))
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Phantom" then
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.PhantomWins/record.PhantomRounds*100, 1))
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Glitch" then
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.GlitchWins/record.GlitchRounds*100, 1))
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Jester" then
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.JesterWins/record.JesterRounds*100, 1))
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Swapper" then
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.SwapperWins/record.SwapperRounds*100, 1))
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Killer" then
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.KillerWins/record.KillerRounds*100, 1))
				DataDisplay:SortByColumn(2, true)
			end
		end
	end
	RoleDropdown:Hide()
	
	local YourStatsLabel = vgui.Create("DLabel", MainWindow)
	YourStatsLabel:SetText("Subcategory:")
	YourStatsLabel:SetPos(20, 65)
	YourStatsLabel:SetSize(90, 25)
	YourStatsLabel:Hide()
	
	local YourStatsDropdown = vgui.Create("DComboBox", MainWindow)
	YourStatsDropdown:SetText("")
	YourStatsDropdown:SetPos(110, 65)
	YourStatsDropdown:SetSize(275, 25)
	YourStatsDropdown:SetSortItems(false)
	YourStatsDropdown:AddChoice("Role win rate")
	YourStatsDropdown:AddChoice("Times played role")
	YourStatsDropdown:AddChoice("Best traitor partners")
	YourStatsDropdown:AddChoice("Favourite detective equipment")
	YourStatsDropdown:AddChoice("Favourite traitor equipment")
	YourStatsDropdown.OnSelect = function(index, value, str)
		DataDisplay:Clear()
		if str == "Role win rate" then
			DescriptionLabel:SetText("Average role win rate (%).")
			for id, record in pairs(PlayerStats) do
				if(id==LocalPlayer():SteamID()) then
					DataDisplay:AddLine("Detective", math.Round(record.DetectiveWins/record.DetectiveRounds*100), 1)
					DataDisplay:AddLine("Innocent", math.Round(record.InnocentWins/record.InnocentRounds*100), 1)
					DataDisplay:AddLine("Traitor", math.Round(record.TraitorWins/record.TraitorRounds*100), 1)
				end
			end
			if(CustomRolesEnabled) then
				for id, record in pairs(PlayerStats) do
					if(id==LocalPlayer():SteamID()) then
						DataDisplay:AddLine("Assassin", math.Round(record.AssassinWins/record.AssassinRounds*100), 1)
						DataDisplay:AddLine("Hypnotist", math.Round(record.HypnotistWins/record.HypnotistRounds*100), 1)
						DataDisplay:AddLine("Vampire", math.Round(record.VampireWins/record.VampireRounds*100), 1)
						DataDisplay:AddLine("Zombie", math.Round(record.ZombieWins/record.ZombieRounds*100), 1)
						DataDisplay:AddLine("Mercenary", math.Round(record.MercenaryWins/record.MercenaryRounds*100), 1)
						DataDisplay:AddLine("Phantom", math.Round(record.PhantomWins/record.PhantomRounds*100), 1)
						DataDisplay:AddLine("Glitch", math.Round(record.GlitchWins/record.GlitchRounds*100), 1)
						DataDisplay:AddLine("Jester", math.Round(record.JesterWins/record.JesterRounds*100), 1)
						DataDisplay:AddLine("Swapper", math.Round(record.SwapperWins/record.SwapperRounds*100), 1)
						DataDisplay:AddLine("Killer", math.Round(record.KillerWins/record.KillerRounds*100), 1)
					end
				end
			end
		
		elseif str == "Times played role" then
		DescriptionLabel:SetText("Rounds playing each role (times role played/total rounds played).")
			for id, record in pairs(PlayerStats) do
				if(id==LocalPlayer():SteamID()) then
					DataDisplay:AddLine("Detective", record.DetectiveRounds.."/"..record.TotalRoundsPlayed)
					DataDisplay:AddLine("Innocent", record.InnocentRounds.."/"..record.TotalRoundsPlayed)
					DataDisplay:AddLine("Traitor", record.TraitorRounds.."/"..record.TotalRoundsPlayed)
				end
			end
			if(CustomRolesEnabled) then
				for id, record in pairs(PlayerStats) do
					if(id==LocalPlayer():SteamID()) then
						DataDisplay:AddLine("Assassin", record.AssassinRounds.."/"..record.TotalRoundsPlayed)
						DataDisplay:AddLine("Hypnotist", record.HypnotistRounds.."/"..record.TotalRoundsPlayed)
						DataDisplay:AddLine("Vampire", record.VampireRounds.."/"..record.TotalRoundsPlayed)
						DataDisplay:AddLine("Zombie", record.ZombieRounds.."/"..record.TotalRoundsPlayed)
						DataDisplay:AddLine("Mercenary", record.MercenaryRounds.."/"..record.TotalRoundsPlayed)
						DataDisplay:AddLine("Phantom", record.PhantomRounds.."/"..record.TotalRoundsPlayed)
						DataDisplay:AddLine("Glitch", record.GlitchRounds.."/"..record.TotalRoundsPlayed)
						DataDisplay:AddLine("Jester", record.JesterRounds.."/"..record.TotalRoundsPlayed)
						DataDisplay:AddLine("Swapper", record.SwapperRounds.."/"..record.TotalRoundsPlayed)
						DataDisplay:AddLine("Killer", record.KillerRounds.."/"..record.TotalRoundsPlayed)
					end
				end
			end
		
		elseif str == "Best traitor partners" then
			DescriptionLabel:SetText("Win rate when on a traitor team with each player (%).")
			
			if (PlayerStats[LocalPlayer():SteamID()]["TraitorPartners"]==nil) then
				DataDisplay:AddLine("No partners yet", "No partners yet")
			else
				for partnerID, partnerTable in pairs(PlayerStats[LocalPlayer():SteamID()]["TraitorPartners"]) do
					DataDisplay:AddLine(partnerTable.Nick, math.Round(partnerTable.Wins/partnerTable.Rounds*100), 1)
				end
			end
			DataDisplay:SortByColumn(2, true)
			
		elseif str == "Favourite detective equipment" then
			DescriptionLabel:SetText("Times you've bought each detective item")
			
			if (PlayerStats[LocalPlayer():SteamID()]["DetectiveEquipment"]==nil) then
				DataDisplay:AddLine("No equipment yet", "No equipment yet")
			else
				for itemName, timesBought in pairs(PlayerStats[LocalPlayer():SteamID()]["DetectiveEquipment"]) do
					DataDisplay:AddLine(itemName, timesBought)
				end
			end
			DataDisplay:SortByColumn(2, true)
		
		elseif str == "Favourite traitor equipment" then
			DescriptionLabel:SetText("Times you've bought each traitor item")
			
			if (PlayerStats[LocalPlayer():SteamID()]["TraitorEquipment"]==nil) then
				DataDisplay:AddLine("No equipment yet", "No equipment yet")
			else
				for itemName, timesBought in pairs(PlayerStats[LocalPlayer():SteamID()]["TraitorEquipment"]) do
					DataDisplay:AddLine(itemName, timesBought)
				end
			end
			DataDisplay:SortByColumn(2, true)
		
		end
		
	end
	YourStatsDropdown:Hide()
	
	local StatisticDropdown = vgui.Create("DComboBox", MainWindow)
	StatisticDropdown:SetText("")
	StatisticDropdown:SetPos(110, 35)
	StatisticDropdown:SetSize(275, 25)
	StatisticDropdown:SetSortItems(false)
	StatisticDropdown:AddChoice("Your stats...")
	StatisticDropdown:AddChoice("Server average role win rates")
	StatisticDropdown:AddChoice("Best at role...")
	StatisticDropdown:AddChoice("Most rounds played")
	StatisticDropdown:AddChoice("Most often killed first")
	StatisticDropdown:AddChoice("Most crooked cop")
	StatisticDropdown:AddChoice("Most trigger-happy innocent")
	StatisticDropdown:AddChoice("Least safe near ledges")
	StatisticDropdown:AddChoice("Best traitor partners")
	StatisticDropdown:AddChoice("Favourite detective equipment")
	StatisticDropdown:AddChoice("Favourite traitor equipment")
	StatisticDropdown.OnSelect = function(index, value, str)
		RoleLabel:Hide()
		YourStatsLabel:Hide()
		RoleDropdown:Hide()
		YourStatsDropdown:Hide()
		DataDisplay:Clear()
		if str == "Your stats..." then
			DescriptionLabel:SetText("")
			YourStatsDropdown:Show()
			YourStatsLabel:Show()
			
		elseif str == "Server average role win rates" then
			DescriptionLabel:SetText("Server-wide role average win rates (%).")
			local AvgDRate = 0
			local AvgIRate = 0
			local AvgTRate = 0
			for id, record in pairs(PlayerStats) do
				AvgDRate = AvgDRate + (record.DetectiveWins/record.DetectiveRounds*100)
				AvgIRate = AvgIRate + (record.InnocentWins/record.InnocentRounds*100)
				AvgTRate = AvgTRate + (record.TraitorWins/record.TraitorRounds*100)
			end
			AvgDRate = math.Round(AvgDRate / table.Count(PlayerStats), 1)
			AvgIRate = math.Round(AvgIRate / table.Count(PlayerStats), 1)
			AvgTRate = math.Round(AvgTRate / table.Count(PlayerStats), 1)
			DataDisplay:AddLine("Detective", AvgDRate)
			DataDisplay:AddLine("Innocent", AvgIRate)
			DataDisplay:AddLine("Traitor", AvgTRate)
			
			if(CustomRolesEnabled) then
				local AvgARate = 0
				local AvgHRate = 0
				local AvgVRate = 0
				local AvgZRate = 0
				local AvgMRate = 0
				local AvgPRate = 0
				local AvgGRate = 0
				local AvgJRate = 0
				local AvgSRate = 0
				local AvgKRate = 0
				for id, record in pairs(PlayerStats) do
					AvgARate = AvgARate + (record.AssassinWins/record.AssassinRounds*100)
					AvgHRate = AvgHRate + (record.HypnotistWins/record.HypnotistRounds*100)
					AvgVRate = AvgVRate + (record.VampireWins/record.VampireRounds*100)
					AvgZRate = AvgZRate + (record.ZombieWins/record.ZombieRounds*100)
					AvgMRate = AvgMRate + (record.MercenaryWins/record.MercenaryRounds*100)
					AvgPRate = AvgPRate + (record.PhantomWins/record.PhantomRounds*100)
					AvgGRate = AvgGRate + (record.GlitchWins/record.GlitchRounds*100)
					AvgJRate = AvgJRate + (record.JesterWins/record.JesterRounds*100)
					AvgSRate = AvgSRate + (record.SwapperWins/record.SwapperRounds*100)
					AvgKRate = AvgKRate + (record.KillerWins/record.KillerRounds*100)
				end
				AvgARate = math.Round(AvgARate / table.Count(PlayerStats), 1)
				AvgHRate = math.Round(AvgHRate / table.Count(PlayerStats), 1)
				AvgVRate = math.Round(AvgVRate / table.Count(PlayerStats), 1)
				AvgZRate = math.Round(AvgZRate / table.Count(PlayerStats), 1)
				AvgMRate = math.Round(AvgMRate / table.Count(PlayerStats), 1)
				AvgPRate = math.Round(AvgPRate / table.Count(PlayerStats), 1)
				AvgGRate = math.Round(AvgGRate / table.Count(PlayerStats), 1)
				AvgJRate = math.Round(AvgJRate / table.Count(PlayerStats), 1)
				AvgSRate = math.Round(AvgSRate / table.Count(PlayerStats), 1)
				AvgKRate = math.Round(AvgKRate / table.Count(PlayerStats), 1)
				DataDisplay:AddLine("Assassin", AvgARate)
				DataDisplay:AddLine("Hypnotist", AvgHRate)
				DataDisplay:AddLine("Vampire", AvgVRate)
				DataDisplay:AddLine("Zombie", AvgZRate)
				DataDisplay:AddLine("Mercenary", AvgMRate)
				DataDisplay:AddLine("Phantom", AvgPRate)
				DataDisplay:AddLine("Glitch", AvgGRate)
				DataDisplay:AddLine("Jester", AvgJRate)
				DataDisplay:AddLine("Swapper", AvgSRate)
				DataDisplay:AddLine("Killer", AvgKRate)
			end

		elseif str == "Best at role..." then
			DescriptionLabel:SetText("Average role win rate (%).")
			RoleLabel:Show()
			RoleDropdown:Show()
		
		elseif str == "Most rounds played" then
			DescriptionLabel:SetText("Total number of rounds played.")
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, record.TotalRoundsPlayed)
				DataDisplay:SortByColumn(2, true)
			end
			
		elseif str == "Most often killed first" then
			DescriptionLabel:SetText("Percentage of their rounds that each player is killed first (%).")
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.KilledFirst / record.TotalRoundsPlayed * 100, 2))
				DataDisplay:SortByColumn(2, true)
			end
			
		elseif str == "Most crooked cop" then
			DescriptionLabel:SetText("Average number of innocents killed per round as detective.")
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.CrookedCop/record.DetectiveRounds, 2))
				DataDisplay:SortByColumn(2, true)
			end
			
		elseif str == "Most trigger-happy innocent" then
			DescriptionLabel:SetText("Average number of innocent players killed while on the innocent team.")
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, math.Round(record.TriggerHappyInnocent/
				(record.InnocentRounds + record.MercenaryRounds + record.GlitchRounds + record.PhantomRounds), 2))
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Least safe near ledges" then
			DescriptionLabel:SetText("Total fall damage taken.")
			for id, record in pairs(PlayerStats) do
				DataDisplay:AddLine(record.Nickname, record.TotalFallDamage)
				DataDisplay:SortByColumn(2, true)
			end
		
		elseif str == "Best traitor partners" then
			DescriptionLabel:SetText("Each player's best traitor partner (win rate %).")
			
			for id, record in pairs(PlayerStats) do
				local bestPartner = {Nick = "No traitor partners yet", Winrate = -1}
				local thisPartnerWinRate = -1
				for partnerID, partnerTable in pairs(record["TraitorPartners"]) do
					thisPartnerWinRate = math.Round(partnerTable.Wins/partnerTable.Rounds*100, 1)
					if thisPartnerWinRate > bestPartner.Winrate then
						bestPartner.Winrate = thisPartnerWinRate
						bestPartner.Nick = partnerTable.Nick
					end
				end
				DataDisplay:AddLine(record.Nickname, bestPartner.Nick.." ("..bestPartner.Winrate.."%)")
			end
		
		elseif str == "Favourite detective equipment" then
			DescriptionLabel:SetText("Each player's favourite detective equipment (times bought).")
			
			for id, record in pairs(PlayerStats) do
				local favouriteEquipment = "No equipment bought yet"
				local mostTimesBought = 0
				for itemName, thisItemTimesBought in pairs(record["DetectiveEquipment"]) do
					if thisItemTimesBought > mostTimesBought then
						favouriteEquipment = itemName
						mostTimesBought = thisItemTimesBought
					end
				end
				DataDisplay:AddLine(record.Nickname, favouriteEquipment.." ("..mostTimesBought..")")
			end
		
		elseif str == "Favourite traitor equipment" then
			DescriptionLabel:SetText("Each player's favourite traitor equipment (times bought).")
			
			for id, record in pairs(PlayerStats) do
				local favouriteEquipment = "No equipment bought yet"
				local mostTimesBought = 0
				for itemName, thisItemTimesBought in pairs(record["TraitorEquipment"]) do
					if thisItemTimesBought > mostTimesBought then
						favouriteEquipment = itemName
						mostTimesBought = thisItemTimesBought
					end
				end
				DataDisplay:AddLine(record.Nickname, favouriteEquipment.." ("..mostTimesBought..")")
			end

		end
	end
	
	gui.EnableScreenClicker(true)
end

AccessButton.DoClick = function()
	DisplayWindow()
end

hook.Add("TTTBoughtItem", "TotalStatistics_PlayerBoughtItem", function(is_item, equipment)
	local error = false
	--when player buys an item, first check if its on the SWEP list
	for k, v in pairs(weapons.GetList()) do
		if equipment == v.ClassName then
			net.Start("TotalStatistics_SendClientEquipmentName")
            net.WriteString(v.PrintName)
			net.WriteBool(error)
            net.SendToServer()
			return
		elseif equipment == tostring(EQUIP_RADAR) then
			net.Start("TotalStatistics_SendClientEquipmentName")
            net.WriteString("Radar")
			net.WriteBool(error)
            net.SendToServer()
			return
		elseif equipment == tostring(EQUIP_ARMOR) then
			net.Start("TotalStatistics_SendClientEquipmentName")
            net.WriteString("Body Armor")
			net.WriteBool(error)
            net.SendToServer()
			return
		elseif equipment == tostring(EQUIP_DISGUISE) then
			net.Start("TotalStatistics_SendClientEquipmentName")
            net.WriteString("Disguise")
            net.SendToServer()
			return
		end
	end
	
	--if its not on the SWEP list, then check the equipment item menu for the role
	if LocalPlayer():GetRole() == ROLE_DETECTIVE then
		for k, v in pairs (EquipmentItems[ROLE_DETECTIVE]) do
			if equipment == v.id then
				net.Start("TotalStatistics_SendClientEquipmentName")
				net.WriteString(v.name)
				net.WriteBool(error)
				net.SendToServer()
				return
			end
		end
	elseif LocalPlayer():GetRole() == ROLE_TRAITOR then
		for k, v in pairs (EquipmentItems[ROLE_TRAITOR]) do
			if equipment == v.id then
				net.Start("TotalStatistics_SendClientEquipmentName")
				net.WriteString(v.name)
				net.WriteBool(error)
				net.SendToServer()
				return
			end
		end
	end
	
	--if we can't find it, let the server know
	error = true
	net.Start("TotalStatistics_SendClientEquipmentName")
	net.WriteString(equipment)
	net.WriteBool(error)
	net.SendToServer()
end)