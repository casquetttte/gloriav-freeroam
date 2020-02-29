local function RegisterEmoteSuggestion(command, withoutParam)
	local param = nil
	if not withoutParam then param = { { name = 'playerid', help = 'Optionnel' } } end

	TriggerEvent('chat:addSuggestion', command, '', param)
end


AddEventHandler('lsv:init', function()
	TriggerEvent('chat:addSuggestion', '/t', 'Envoyer un message privé à un autre joueur', {
		{ name = 'playerid' },
		{ name = 'message' },
	})

	TriggerEvent('chat:addSuggestion', '/c', 'Envoyer un message à votre Crew', {
		{ name = 'message' },
	})

	TriggerEvent('chat:addSuggestion', '/eventvote', 'Votez pour le prochain événement', {
		{ name = 'eventid', help = 'Utilisez sans arguments pour voir la liste des événements' },
	})

	if Player.Moderator and Player.Moderator == Settings.moderatorLevel.Administrator then
		TriggerEvent('chat:addSuggestion', '/unban', 'Débannir un joueur', {
			{ name = 'playerid' },
		})
	end

	RegisterEmoteSuggestion('/agree')
	RegisterEmoteSuggestion('/amaze')
	RegisterEmoteSuggestion('/angry')
	RegisterEmoteSuggestion('/apologize')
	RegisterEmoteSuggestion('/applaud')
	RegisterEmoteSuggestion('/attack')

	RegisterEmoteSuggestion('/bashful')
	RegisterEmoteSuggestion('/beckon')
	RegisterEmoteSuggestion('/beg')
	RegisterEmoteSuggestion('/bite')
	RegisterEmoteSuggestion('/bleed', true)
	RegisterEmoteSuggestion('/blow')
	RegisterEmoteSuggestion('/blush')
	RegisterEmoteSuggestion('/bored')
	RegisterEmoteSuggestion('/bounce')
	RegisterEmoteSuggestion('/bow')
	RegisterEmoteSuggestion('/brb')
	RegisterEmoteSuggestion('/bye')

	RegisterEmoteSuggestion('/cackle')
	RegisterEmoteSuggestion('/calm')
	RegisterEmoteSuggestion('/cat')
	RegisterEmoteSuggestion('/charge', true)
	RegisterEmoteSuggestion('/cheer')
	RegisterEmoteSuggestion('/chew')
	RegisterEmoteSuggestion('/chicken')
	RegisterEmoteSuggestion('/chuckle')
	RegisterEmoteSuggestion('/clap')
	RegisterEmoteSuggestion('/cold')
	RegisterEmoteSuggestion('/comfort')
	RegisterEmoteSuggestion('/commend')
	RegisterEmoteSuggestion('/confused')
	RegisterEmoteSuggestion('/congrats')
	RegisterEmoteSuggestion('/cough')
	RegisterEmoteSuggestion('/cower')
	RegisterEmoteSuggestion('/crack')
	RegisterEmoteSuggestion('/cringe')
	RegisterEmoteSuggestion('/cry')
	RegisterEmoteSuggestion('/cuddle')
	RegisterEmoteSuggestion('/curious')

	RegisterEmoteSuggestion('/dance')
	RegisterEmoteSuggestion('/disappointed')
	RegisterEmoteSuggestion('/doom')
	RegisterEmoteSuggestion('/drink')
	RegisterEmoteSuggestion('/duck')

	RegisterEmoteSuggestion('/facepalm')

	RegisterEmoteSuggestion('/helpme', true)
	RegisterEmoteSuggestion('/hi')

	RegisterEmoteSuggestion('/jk')

	RegisterEmoteSuggestion('/laugh')

	RegisterEmoteSuggestion('/money', true) -- Not an emote at all
	RegisterEmoteSuggestion('/mute') -- Not an emote at all
	RegisterEmoteSuggestion('/unmute') -- Not an emote at all

	RegisterEmoteSuggestion('/ping') -- Not an emote at all

	RegisterEmoteSuggestion('/help', true) -- Not an emote at all
	RegisterEmoteSuggestion('/ammo', true) -- Not an emote at all
	RegisterEmoteSuggestion('/report', true) -- Not an emote at all
	RegisterEmoteSuggestion('/cash', true) -- Not an emote at all
	RegisterEmoteSuggestion('/quit', true) -- Not an emote at all
	RegisterEmoteSuggestion('/vehicle', true) -- Not an emote at all

	RegisterEmoteSuggestion('/id', true) -- Not an emote at all
end)


RegisterNetEvent('lsv:addCrewMessage')
AddEventHandler('lsv:addCrewMessage', function(message)
	if #Player.CrewMembers == 0 then return end
	TriggerServerEvent('lsv:addCrewMessage', Player.CrewMembers, message)
end)


AddEventHandler('lsv:setupHud', function(hud)
	if hud.discordUrl ~= '' then
		TriggerEvent('chat:addSuggestion', '/discord', 'Copier-coller le lien d\'invitation Discord', {
			{ name = hud.discordUrl },
		})
	end
end)