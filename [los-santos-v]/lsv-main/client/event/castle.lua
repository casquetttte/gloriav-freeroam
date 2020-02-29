local logger = Logger.New('Castle')

local titles = { 'WINNER', '2ND PLACE', '3RD PLACE' }
local instructionsText = 'Tenez la zone du château par vous-même pour devenir le roi et gagner une récompense.'
local playerColors = { Color.BLIP_YELLOW, Color.BLIP_GREY, Color.BLIP_BROWN }
local playerPositions = { '1st: ', '2nd: ', '3rd: ' }

local castleData = nil


local function getPlayerPoints()
	local player = table.find_if(castleData.players, function(player)
		return player.id == Player.ServerId()
	end)
	if not player then return nil end
	return player.points
end


RegisterNetEvent('lsv:startCastle')
AddEventHandler('lsv:startCastle', function(data, passedTime)
	if castleData then return end

	-- Preparations
	local place = Settings.castle.places[data.placeIndex]

	castleData = { }

	castleData.place = place
	castleData.startTime = GetGameTimer()
	if passedTime then castleData.startTime = castleData.startTime - passedTime end
	castleData.players = data.players

	-- GUI
	Citizen.CreateThread(function()
		if Player.IsInFreeroam() and not passedTime then Gui.StartEvent('King of the Castle', instructionsText) end

		castleData.zoneBlip = Map.CreateRadiusBlip(place.x, place.y, place.z, Settings.castle.radius, Color.BLIP_PURPLE)
		castleData.blip = Map.CreateEventBlip(Blip.CASTLE, place.x, place.y, place.z, nil, Color.BLIP_PURPLE)
		Map.SetBlipFlashes(castleData.blip)

		while true do
			Citizen.Wait(0)

			if not castleData then return end

			SetBlipAlpha(castleData.blip, MissionManager.Mission and 0 or 255)
			SetBlipAlpha(castleData.zoneBlip, MissionManager.Mission and 0 or 128)

			if Player.IsInFreeroam() then
				Gui.DisplayObjectiveText(Player.DistanceTo(castleData.place, true) <= Settings.castle.radius and
					'Defendez la ~p~zone du château~w~.' or 'Entrez dans la ~p~zone du château~w~ pour devenir le Roi du château.')

				Gui.DrawTimerBar('ÉVÈNEMENT TERMINÉ', math.max(0, Settings.castle.duration - GetGameTimer() + castleData.startTime), 1)
				Gui.DrawBar('VOTRE SCORE', getPlayerPoints() or 0, 2)

				local barPosition = 3
				for i = barPosition, 1, -1 do
					if castleData.players[i] then
						Gui.DrawBar(playerPositions[i]..GetPlayerName(GetPlayerFromServerId(castleData.players[i].id)), castleData.players[i].points,
							barPosition, Color.GetHudFromBlipColor(playerColors[i]), true)
						barPosition = barPosition + 1
					end
				end
			end
		end
	end)

	-- Logic
	Citizen.CreateThread(function()
		local lastPointTime = nil

		while true do
			Citizen.Wait(0)

			if not castleData then return end

			if Player.IsActive() then
				if Player.DistanceTo(castleData.place, true) <= Settings.castle.radius then
					if not lastPointTime then lastPointTime = Timer.New()
					elseif lastPointTime:Elapsed() >= 1000 then
						TriggerServerEvent('lsv:castleAddPoint')
						lastPointTime:Restart()
					end
				end
			end
		end
	end)
end)


RegisterNetEvent('lsv:updateCastlePlayers')
AddEventHandler('lsv:updateCastlePlayers', function(players)
	if castleData then castleData.players = players end
end)


RegisterNetEvent('lsv:finishCastle')
AddEventHandler('lsv:finishCastle', function(winners)
	if castleData then
		RemoveBlip(castleData.blip)
		RemoveBlip(castleData.zoneBlip)
	end

	if not winners then
		castleData = nil
		return
	end

	local playerPoints = getPlayerPoints()
	castleData = nil

	local isPlayerWinner = false
	for i = 1, math.min(3, #winners) do
		if winners[i] == Player.ServerId() then
			isPlayerWinner = i
			break
		end
	end

	local messageText = isPlayerWinner and 'Vous avez gagné avec un score de '..playerPoints or Gui.GetPlayerName(winners[1], '~p~')..' est devenu le Roi du château.'

	if Player.IsInFreeroam() and playerPoints then
		if isPlayerWinner then PlaySoundFrontend(-1, 'Mission_Pass_Notify', 'DLC_HEISTS_GENERAL_FRONTEND_SOUNDS', true)
		else PlaySoundFrontend(-1, 'ScreenFlash', 'MissionFailedSounds', true) end

		local scaleform = Scaleform:Request('MIDSIZED_MESSAGE')
		scaleform:Call('SHOW_SHARD_MIDSIZED_MESSAGE', isPlayerWinner and titles[isPlayerWinner] or 'VOUS AVEZ PERDU', messageText, 21)
		scaleform:RenderFullscreenTimed(10000)
		scaleform:Delete()
	else
		Gui.DisplayNotification(messageText)
	end
end)
