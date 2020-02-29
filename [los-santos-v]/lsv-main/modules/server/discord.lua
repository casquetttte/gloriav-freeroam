Discord = { }


local logger = Logger.New('Discord')

local discordUrl = nil
Citizen.CreateThread(function()
	discordUrl = GetConvar('discord_reporting_url')
end)


local function buildReportMessage(reporter, target, reason)
	return '**'..GetPlayerName(reporter)..'** ||('..Scoreboard.GetPlayerIdentifier(reporter)..', '..GetPlayerPing(reporter)..' ms)|| signalé'..
		' **'..GetPlayerName(target)..'** ||('..Scoreboard.GetPlayerIdentifier(target)..', '..GetPlayerPing(target)..' ms)|| pour **'..reason..'**'
end

local function buildKickMessage(target, moderator, reason)
	local whoKickedName = moderator and 'moderator **'..GetPlayerName(moderator)..'** ||('..Scoreboard.GetPlayerIdentifier(moderator)..')||' or 'other players.'
	local message = '**'..GetPlayerName(target)..'** ||('..Scoreboard.GetPlayerIdentifier(target)..', '..GetPlayerPing(target)..' ms)|| a été expulsé de la session par '..whoKickedName
	if reason then message = message..' for **'..reason..'**' end
	return message
end

local function buildBanMessage(target, moderator, reason, duration)
	if duration then
		return '**'..GetPlayerName(target)..'** ||('..Scoreboard.GetPlayerIdentifier(target)..', '..GetPlayerPing(target)..' ms)|| a été temporairement banni du serveur par le modérateur **'..GetPlayerName(moderator)..'** ||('..Scoreboard.GetPlayerIdentifier(moderator)..')|| pour **'..reason..'** (Durée du BAN: **'..duration..' jour(s)**)'
	else
		return '**'..GetPlayerName(target)..'** ||('..Scoreboard.GetPlayerIdentifier(target)..', '..GetPlayerPing(target)..' ms)|| a été définitivement banni du serveur par le modérateur **'..GetPlayerName(moderator)..'** ||('..Scoreboard.GetPlayerIdentifier(moderator)..')|| pour **'..reason..'**'
	end
end

local function performDiscordRequest(content, callback)
	if not discordUrl then return end

	PerformHttpRequest(discordUrl, function(statusCode)
		if statusCode >= 400 then
			logger:Error('Status code: '..statusCode)
			return
		end
		if callback then callback() end
	end, 'POST', json.encode({ content = content }), { ['Content-Type'] = 'application/json' })
end


function Discord.ReportPlayer(reporter, target, reason)
	performDiscordRequest(buildReportMessage(reporter, target, reason))
end


function Discord.ReportKickedPlayer(target, moderator, reason)
	performDiscordRequest(buildKickMessage(target, moderator, reason))
end


function Discord.ReportBanPlayer(target, moderator, reason, duration)
	performDiscordRequest(buildBanMessage(target, moderator, reason, duration))
end


function Discord.ReportAutoBanPlayer(target, reason)
	local message = '**'..GetPlayerName(target)..'** ||('..Scoreboard.GetPlayerIdentifier(target)..')|| a été définitivement banni du serveur pour **'..reason..'**'
	performDiscordRequest(message)
end