RegisterNetEvent('lsv:reportSuccess')
AddEventHandler('lsv:reportSuccess', function(targetName)
	PlaySoundFrontend(-1, 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET', true)
	Gui.DisplayNotification('<C>'..targetName..'</C> ~r~a été signalé.')
end)


RegisterNetEvent('lsv:playerKicked')
AddEventHandler('lsv:playerKicked', function(playerName)
	Gui.DisplayNotification('<C>'..playerName..'</C> a été expulsé de la session par les autres joueurs.')
end)