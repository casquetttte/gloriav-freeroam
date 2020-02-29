local vehicle = nil
local vehicleBlip = nil
local dropOffBlip = nil
local dropOffLocationBlip = nil

local helpHandler = nil


AddEventHandler('lsv:startAssetRecovery', function()
	local variant = table.random(Settings.assetRecovery.variants)

	Streaming.RequestModel(variant.vehicle, true)
	local vehicleHash = GetHashKey(variant.vehicle)
	vehicle = CreateVehicle(vehicleHash, variant.vehicleLocation.x, variant.vehicleLocation.y, variant.vehicleLocation.z, variant.vehicleLocation.heading, false, true)
	SetVehicleModKit(vehicle, 0)
	SetVehicleMod(vehicle, 16, 4)
	SetVehicleTyresCanBurst(vehicle, false)
	SetModelAsNoLongerNeeded(vehicleHash)

	local eventStartTime = Timer.New()
	local isInVehicle = false
	local routeBlip = nil

	vehicleBlip = AddBlipForEntity(vehicle)
	SetBlipHighDetail(vehicleBlip, true)
	SetBlipSprite(vehicleBlip, Blip.CAR)
	SetBlipColour(vehicleBlip, Color.BLIP_GREEN)
	SetBlipRouteColour(vehicleBlip, Color.BLIP_GREEN)
	SetBlipAlpha(vehicleBlip, 0)
	Map.SetBlipText(vehicleBlip, 'Véhicule')
	Map.SetBlipFlashes(vehicleBlip)

	dropOffBlip = AddBlipForCoord(variant.dropOffLocation.x, variant.dropOffLocation.y, variant.dropOffLocation.z)
	SetBlipColour(dropOffBlip, Color.BLIP_YELLOW)
	SetBlipRouteColour(dropOffBlip, Color.BLIP_YELLOW)
	SetBlipHighDetail(dropOffBlip, true)
	SetBlipAlpha(dropOffBlip, 0)

	dropOffLocationBlip = Map.CreateRadiusBlip(variant.dropOffLocation.x, variant.dropOffLocation.y, variant.dropOffLocation.z, Settings.assetRecovery.dropRadius, Color.BLIP_YELLOW)
	SetBlipAlpha(dropOffLocationBlip, 0)

	Gui.StartMission('Asset Recovery', 'Voler le véhicule et le livrer au lieu de restitution.')

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)

			if not MissionManager.Mission then return end

			SetBlipAlpha(vehicleBlip, isInVehicle and 0 or 255)
			SetBlipAlpha(dropOffBlip, isInVehicle and 255 or 0)
			SetBlipAlpha(dropOffLocationBlip, isInVehicle and 128 or 0)

			if Player.IsActive() then
				Gui.DisplayObjectiveText(isInVehicle and 'Remettez le véhicule au ~y~dépôt~w~.' or 'Volez le ~g~véhicule~w~.')
				Gui.DrawTimerBar('TEMPS DE MISSION', Settings.assetRecovery.time - eventStartTime:Elapsed(), 1)
				if isInVehicle then
					local healthProgress = GetEntityHealth(vehicle) / GetEntityMaxHealth(vehicle)
					local color = Color.GetHudFromBlipColor(Color.BLIP_GREEN)
					if healthProgress < 0.33 then color = Color.GetHudFromBlipColor(Color.BLIP_RED)
					elseif healthProgress < 0.66 then color = Color.GetHudFromBlipColor(Color.BLIP_YELLOW) end
					Gui.DrawProgressBar('SANTÉ DU VÉHICULE', healthProgress, 2, color)
				end
			end
		end
	end)

	while true do
		Citizen.Wait(0)

		if not MissionManager.Mission then
			TriggerEvent('lsv:assetRecoveryFinished', false)
			return
		end

		if eventStartTime:Elapsed() < Settings.assetRecovery.time then
			if not DoesEntityExist(vehicle) or not IsVehicleDriveable(vehicle, false) then
				TriggerEvent('lsv:assetRecoveryFinished', false, 'Un véhicule a été détruit.')
				return
			end

			isInVehicle = IsPedInVehicle(PlayerPedId(), vehicle, false)

			if isInVehicle then
				if not NetworkGetEntityIsNetworked(vehicle) then
					NetworkRegisterEntityAsNetworked(vehicle)
					Gui.DisplayPersonalNotification('Vous avez volé un véhicule.')
					helpHandler = HelpQueue.PushFront('Minimisez les dégâts du véhicule pour obtenir une récompense supplémentaire.')
				end

				if routeBlip ~= dropOffBlip then
					SetBlipRoute(dropOffBlip, true)
					routeBlip = dropOffBlip
				end

				World.SetWantedLevel(3)

				if Player.DistanceTo(variant.dropOffLocation, true) < Settings.assetRecovery.dropRadius then
					TriggerServerEvent('lsv:assetRecoveryFinished', GetEntityHealth(vehicle) / GetEntityMaxHealth(vehicle))
					return
				end
			elseif routeBlip ~= vehicleBlip then
				SetBlipRoute(vehicleBlip, true)
				routeBlip = vehicleBlip
			end
		else
			TriggerEvent('lsv:assetRecoveryFinished', false, 'Fin du temps imparti.')
			return
		end
	end
end)


RegisterNetEvent('lsv:assetRecoveryFinished')
AddEventHandler('lsv:assetRecoveryFinished', function(success, reason)
	if helpHandler then helpHandler:Cancel() end

	MissionManager.FinishMission(success)

	World.SetWantedLevel(0)

	if not success and not IsPedInVehicle(PlayerPedId(), vehicle, false) then
		SetEntityAsMissionEntity(vehicle, true, true)
		DeleteVehicle(vehicle)
	end
	vehicle = nil

	RemoveBlip(vehicleBlip)
	vehicleBlip = nil

	RemoveBlip(dropOffBlip)
	dropOffBlip = nil

	RemoveBlip(dropOffLocationBlip)
	dropOffLocationBlip = nil

	Gui.FinishMission('Asset Recovery', success, reason)
end)
