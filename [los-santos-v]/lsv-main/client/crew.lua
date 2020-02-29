local alreadyInvited = false


RegisterNetEvent('lsv:crewLeaved')
AddEventHandler('lsv:crewLeaved', function(player)
	if player == Player.ServerId() then
		Player.CrewMembers = { }
		Gui.DisplayNotification('Vous avez quitté le Crew.')
		return
	end

	if table.try_remove(Player.CrewMembers, player) then
		Gui.DisplayPersonalNotification(Gui.GetPlayerName(player, '~b~')..' a quitté le Crew.')
	end
end)


RegisterNetEvent('lsv:invitedToCrew')
AddEventHandler('lsv:invitedToCrew', function(player)
	if #Player.CrewMembers ~= 0 or alreadyInvited then
		TriggerServerEvent('lsv:alreadyInCrew', player)
		return
	end

	alreadyInvited = true

	local playerId = GetPlayerFromServerId(player)
	local handle = RegisterPedheadshot(GetPlayerPed(playerId))
	while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do Citizen.Wait(0) end
	local txd = GetPedheadshotTxdString(handle)

	FlashMinimapDisplay()
	PlaySoundFrontend(-1, 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET', true)
	Gui.DisplayPersonalNotification('Je voudrais vous inviter dans mon Crew.', txd, GetPlayerName(playerId), '', 7)

	local invitationTimer = Timer.New()
	while true do
		Citizen.Wait(0)

		if invitationTimer:Elapsed() >= Settings.crewInvitationTimeout then
			Gui.DisplayPersonalNotification('Vous avez refusé l\'invitation de Crew de '..Gui.GetPlayerName(player)..'.')
			TriggerServerEvent('lsv:declineInvitation', player)
			alreadyInvited = false
			return
		end

		Gui.DisplayHelpText('Appuyez sur ~INPUT_SELECT_CHARACTER_MICHAEL~ pour accepter l\'invitation de Crew de '..Gui.GetPlayerName(player))

		if IsControlPressed(0, 166) then
			table.insert(Player.CrewMembers, player)
			TriggerServerEvent('lsv:acceptInvitation', player)
			Gui.DisplayPersonalNotification('Vous avez accepté l\'invitation de Crew de '..Gui.GetPlayerName(player)..'.')
			alreadyInvited = false
			return
		end
	end
end)


RegisterNetEvent('lsv:invitationAccepted')
AddEventHandler('lsv:invitationAccepted', function(player)
	TriggerServerEvent('lsv:updateCrewMembers', player, Player.CrewMembers)
	TriggerServerEvent('lsv:addCrewMember', player)

	table.insert(Player.CrewMembers, player)

	FlashMinimapDisplay()
	PlaySoundFrontend(-1, 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET', true)
	Gui.DisplayPersonalNotification(Gui.GetPlayerName(player)..' a accepté votre invitation de Crew.')
end)


RegisterNetEvent('lsv:crewMembersUpdated')
AddEventHandler('lsv:crewMembersUpdated', function(members)
	table.iforeach(members, function(member)
		table.insert(Player.CrewMembers, member)
	end)
end)


RegisterNetEvent('lsv:addedCrewMember')
AddEventHandler('lsv:addedCrewMember', function(player, member)
	if player ~= Player.ServerId() and member ~= Player.ServerId() and Player.IsCrewMember(player) then
		table.insert(Player.CrewMembers, member)

		FlashMinimapDisplay()
		PlaySoundFrontend(-1, 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET', true)
		Gui.DisplayNotification(GetPlayerName(member)..' a rejoins votre Crew.')
	end
end)


RegisterNetEvent('lsv:invitationDeclined')
AddEventHandler('lsv:invitationDeclined', function(player)
	PlaySoundFrontend(-1, 'MP_IDLE_TIMER', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
	Gui.DisplayPersonalNotification(Gui.GetPlayerName(player)..' a refusé votre invitation de Crew.')
end)


RegisterNetEvent('lsv:alreadyInCrew')
AddEventHandler('lsv:alreadyInCrew', function(player)
	PlaySoundFrontend(-1, 'MP_IDLE_TIMER', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
	Gui.DisplayNotification(Gui.GetPlayerName(player)..' est déjà dans votre Crew.')
end)


AddEventHandler('lsv:playerDisconnected', function(_, player)
	table.try_remove(Player.CrewMembers, player)
end)