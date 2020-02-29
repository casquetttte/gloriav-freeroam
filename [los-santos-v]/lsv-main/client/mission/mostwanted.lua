AddEventHandler('lsv:startMostWanted', function()
	local eventStartTime = Timer.New()

	Gui.StartMission('Most Wanted', 'Survivez le plus longtemps avec un niveau recherché.')

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)

			if not MissionManager.Mission then return end

			if Player.IsActive() then
				Gui.DrawTimerBar('TEMPS DE MISSION', Settings.mostWanted.time - eventStartTime:Elapsed(), 1)
				Gui.DrawTimerBar('TEMPS DE SURVIE', eventStartTime:Elapsed(), 2, nil, Color.GetHudFromBlipColor(Color.BLIP_WHITE))
				Gui.DisplayObjectiveText('Survivez le plus longtemps avec un niveau recherché.')
			end
		end
	end)

	while true do
		Citizen.Wait(0)

		if not MissionManager.Mission then
			TriggerEvent('lsv:mostWantedFinished', false)
			return
		end

		if eventStartTime:Elapsed() < Settings.mostWanted.time then
			World.SetWantedLevel(5)

			if IsPlayerDead(PlayerId()) then
				TriggerServerEvent('lsv:mostWantedFinished', eventStartTime:Elapsed())
				return
			end
		else
			TriggerServerEvent('lsv:mostWantedFinished', Settings.mostWanted.time)
			return
		end
	end
end)


RegisterNetEvent('lsv:mostWantedFinished')
AddEventHandler('lsv:mostWantedFinished', function(success, reason)
	MissionManager.FinishMission(success)

	World.SetWantedLevel(0)

	Gui.FinishMission('Most Wanted', success, reason)
end)
