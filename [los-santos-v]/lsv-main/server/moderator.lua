local function isPlayerModerator(player)
	if not Scoreboard.IsPlayerModerator(player) then
		TriggerEvent('lsv:banPlayer', player, 'Fake moderator permission')
		return false
	end

	return true
end


RegisterNetEvent('lsv:kickPlayer')
AddEventHandler('lsv:kickPlayer', function(target, reason)
	local player = source

	if not Scoreboard.IsPlayerOnline(player) or not Scoreboard.IsPlayerOnline(target) then return end
	if not isPlayerModerator(player) then return end

	Discord.ReportKickedPlayer(target, player, reason)

	DropPlayer(target, 'You were kicked from the session by moderator for '..reason..'.')
end)


RegisterNetEvent('lsv:banPlayer')
AddEventHandler('lsv:banPlayer', function(target, reason)
	local player = source

	if not Scoreboard.IsPlayerOnline(player) or not Scoreboard.IsPlayerOnline(target) then return end
	if not isPlayerModerator(player) or Scoreboard.GetPlayerModeratorLevel(player) < Settings.moderatorLevel.Administrator then return end

	local targetName = GetPlayerName(target)

	Db.BanPlayer(target, function()
		Discord.ReportBanPlayer(target, player, reason)
		DropPlayer(target, 'You\'re permanently banned from this server by moderator for '..reason..'.')
		TriggerClientEvent('lsv:playerBanned', -1, targetName, reason)
	end)
end)

RegisterNetEvent('lsv:tempBanPlayer')
AddEventHandler('lsv:tempBanPlayer', function(target, reason, duration)
	local player = source

	if not Scoreboard.IsPlayerOnline(player) or not Scoreboard.IsPlayerOnline(target) then return end
	if not isPlayerModerator(player) or Scoreboard.GetPlayerModeratorLevel(player) < Settings.moderatorLevel.SuperModerator then return end

	local targetName = GetPlayerName(target)
	local expiresDate = os.time() + duration * 24 * 3600

	Db.TempBanPlayer(target, expiresDate, function()
		Discord.ReportBanPlayer(target, player, reason, duration)
		DropPlayer(target, 'You\'re temporarily banned from this server by moderator for '..reason ..'.\nBan expires in '..os.date('%Y-%m-%d %X '..Settings.serverTimeZone, expiresDate))
		TriggerClientEvent('lsv:playerBanned', -1, targetName, reason)
	end)
end)