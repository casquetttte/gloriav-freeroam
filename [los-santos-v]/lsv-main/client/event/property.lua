local titles = { 'WINNER', '2ND PLACE', '3RD PLACE' }
local playerColors = { Color.BLIP_YELLOW, Color.BLIP_GREY, Color.BLIP_BROWN }
local playerPositions = { '1st: ', '2nd: ', '3rd: ' }
local instructionsText = 'Récupérez la mallette et tenez-la aussi longtemps que possible pour obtenir une récompense.'

local propertyData = nil


local function createBriefcase(x, y, z)
	propertyData.pickup = CreatePickupRotate(GetHashKey('PICKUP_MONEY_CASE'), x, y, z, 0.0, 0.0, 0.0, 8, 1)
	propertyData.blip = Map.CreatePickupBlip(propertyData.pickup, 'PICKUP_MONEY_CASE', Color.BLIP_GREEN)
	SetBlipAsShortRange(propertyData.blip, false)
	SetBlipScale(propertyData.blip, 1.1)
end

local function removeBriefcase()
	if propertyData.pickup then
		RemovePickup(propertyData.pickup)
		propertyData.pickup = nil

		RemoveBlip(propertyData.blip)
		propertyData.blip = nil
	end
end

local function getPlayerTime()
	local player = table.find_if(propertyData.players, function(player) return player.id == Player.ServerId() end)
	if not player then return nil end
	return string.from_ms(player.totalTime)
end


RegisterNetEvent('lsv:startHotProperty')
AddEventHandler('lsv:startHotProperty', function(data, passedTime)
	if propertyData then return end

	-- Preparations
	propertyData = { }

	propertyData.startTime = GetGameTimer()
	if passedTime then propertyData.startTime = propertyData.startTime - passedTime end
	propertyData.players = data.players

	World.HotPropertyPlayer = data.currentPlayer

	if not data.currentPlayer then
		createBriefcase(data.position[1], data.position[2], data.position[3])
		SetBlipAlpha(propertyData.blip, 0)
	end

	-- GUI
	Citizen.CreateThread(function()
		if Player.IsInFreeroam() and not passedTime then Gui.StartEvent('Hot Property', instructionsText) end

		if propertyData.blip then
			SetBlipAlpha(propertyData.blip, 255)
			Map.SetBlipFlashes(propertyData.blip)
		end

		while true do
			Citizen.Wait(0)

			if not propertyData then return end

			if Player.IsInFreeroam() then
				local eventObjectiveText = 'Récupérez la ~g~malette~w~ et gardez-la.'
				if World.HotPropertyPlayer then
					if World.HotPropertyPlayer == Player.ServerId() then
						eventObjectiveText = 'Accrochez-vous à la mallette aussi longtemps que possible.'
					else eventObjectiveText = Gui.GetPlayerName(World.HotPropertyPlayer, '~w~')..' a la ~r~malette~w~. Prend-lui des mains.' end
				end
				Gui.DisplayObjectiveText(eventObjectiveText)

				if propertyData.pickup then
					local pickupPosition = GetPickupCoords(propertyData.pickup)
					DrawMarker(20, pickupPosition.x, pickupPosition.y, pickupPosition.z + 0.25, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.85, 0.85, 0.85, 114, 204, 114, 96, true, true)
				end

				Gui.DrawTimerBar('ÉVÈNEMENT TERMINÉ', math.max(0, Settings.property.duration - GetGameTimer() + propertyData.startTime), 1)
				Gui.DrawBar('TEMPS TENU', getPlayerTime() or 0, 2)

				local barPosition = 3
				for i = barPosition, 1, -1 do
					if propertyData.players[i] then
						Gui.DrawBar(playerPositions[i]..GetPlayerName(GetPlayerFromServerId(propertyData.players[i].id)), string.from_ms(propertyData.players[i].totalTime),
							barPosition, Color.GetHudFromBlipColor(playerColors[i]), true)
						barPosition = barPosition + 1
					end
				end
			end
		end
	end)

	-- Logic
	Citizen.CreateThread(function()
		local lastTime = nil

		while true do
			Citizen.Wait(0)

			if not propertyData then return end

			if propertyData.pickup and HasPickupBeenCollected(propertyData.pickup) then
				TriggerServerEvent('lsv:hotPropertyCollected')
				removeBriefcase()
			end

			if World.HotPropertyPlayer == Player.ServerId() then
				if IsPedInAnyVehicle(PlayerPedId(), false) then
					TriggerServerEvent('lsv:hotPropertyDropped', { table.unpack(Player.Position()) })
					World.HotPropertyPlayer = nil
					Gui.DisplayHelpText('Continuez à marcher à pied pour tenir la mallette.')
				else
					if not lastTime then lastTime = Timer.New()
					elseif lastTime:Elapsed() >= 1000 then
						TriggerServerEvent('lsv:hotPropertyTimeUpdated')
						lastTime:Restart()
					end
				end
			else lastTime = nil end
		end
	end)
end)


RegisterNetEvent('lsv:updateHotPropertyPlayers')
AddEventHandler('lsv:updateHotPropertyPlayers', function(players)
	if propertyData then propertyData.players = players end
end)


RegisterNetEvent('lsv:hotPropertyCollected')
AddEventHandler('lsv:hotPropertyCollected', function(player)
	if not propertyData then return end

	removeBriefcase()

	World.HotPropertyPlayer = player
end)


RegisterNetEvent('lsv:hotPropertyDropped')
AddEventHandler('lsv:hotPropertyDropped', function(player, position)
	if not propertyData then return end
	if not position then position = { table.unpack(GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))) } end

	removeBriefcase()
	createBriefcase(position[1], position[2], position[3])

	World.HotPropertyPlayer = nil
end)


RegisterNetEvent('lsv:finishHotProperty')
AddEventHandler('lsv:finishHotProperty', function(winners)
	World.HotPropertyPlayer = nil

	if propertyData then removeBriefcase() end

	if not winners then
		propertyData = nil
		return
	end

	local playerTime = getPlayerTime()
	propertyData = nil

	local isPlayerWinner = false
	for i = 1, math.min(3, #winners) do
		if winners[i] == Player.ServerId() then
			isPlayerWinner = i
			break
		end
	end

	local messageText = Gui.GetPlayerName(winners[1], '~p~')..' a gagné.'
	if isPlayerWinner then messageText = 'Vous avez gagné avec un temps de '..playerTime end

	if Player.IsInFreeroam() and playerTime then
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
