local targetPed = nil
local targetBlip = nil
local targetAreaBlip = nil

local helpHandler = nil


local function removeTargetBlip()
	if not targetBlip then return end
	RemoveBlip(targetBlip)
	RemoveBlip(targetAreaBlip)
	targetBlip = nil
	targetAreaBlip = nil
end


AddEventHandler('lsv:startHeadhunter', function()
	local target = table.random(Settings.headhunter.targets)

	local eventStartTime = Timer.New()
	local loseTheCopsStage = false
	local loseTheCopsStageStartTime = nil
	local isTargetBlipHided = false
	local isTargetWandering = false
	local isInMissionArea = false
	local isTargetDead = false

	Streaming.RequestModel(target.pedModel, true)
	local targetPedModelHash = GetHashKey(target.pedModel)
	targetPed = CreatePed(26, targetPedModelHash, target.location.x, target.location.y, target.location.z, GetRandomFloatInRange(0.0, 360.0), true, true)
	SetPedArmour(targetPed, 1500)
	SetEntityHealth(targetPed, 1500)
	GiveDelayedWeaponToPed(targetPed, GetHashKey(table.random(Settings.headhunter.weapons)), 25000, false)
	SetPedDropsWeaponsWhenDead(targetPed, false)
	SetPedHearingRange(targetPed, 1500.)
	SetPedSeeingRange(targetPed, 1500.)
	SetPedRelationshipGroupHash(targetPed, GetHashKey('HATES_PLAYER'))
	SetModelAsNoLongerNeeded(targetPedModelHash)

	targetBlip = AddBlipForCoord(target.location.x, target.location.y, target.location.z)
	SetBlipScale(targetBlip, 0.85)
	SetBlipColour(targetBlip, Color.BLIP_RED)
	SetBlipHighDetail(targetBlip, true)
	SetBlipColour(targetBlip, Color.BLIP_RED)
	SetBlipRouteColour(targetBlip, Color.BLIP_RED)
	SetBlipRoute(targetBlip, true)
	Map.SetBlipFlashes(targetBlip)

	targetAreaBlip = Map.CreateRadiusBlip(target.location.x, target.location.y, target.location.z, Settings.headhunter.radius, Color.BLIP_RED)

	Gui.StartMission('Headhunter', 'Trouvez et assassinez la cible.')

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)

			if not MissionManager.Mission then return end

			if isTargetDead then
				removeTargetBlip()

				if not loseTheCopsStage then
					World.SetWantedLevel(Settings.headhunter.wantedLevel)
					Gui.DisplayPersonalNotification('Vous avez assassiné une cible.')
					helpHandler = HelpQueue.PushFront('Perdez les flics plus rapidement pour obtenir une récompense supplémentaire.')
					loseTheCopsStage = true
					loseTheCopsStageStartTime = GetGameTimer()
				end
			else
				SetBlipAlpha(targetAreaBlip, isInMissionArea and 96 or 0)
				SetBlipAlpha(targetBlip, isInMissionArea and 0 or 255)
			end

			if isInMissionArea and not isTargetBlipHided then
				SetBlipRoute(targetBlip, false)
				isTargetBlipHided = true
				helpHandler = HelpQueue.PushFront('Utilisez le compteur de distance dans le coin inférieur droit pour localiser la cible.')
			end

			if Player.IsActive() then
				local missionText = isInMissionArea and 'Trouvez et assassinez la ~r~cible~w~.' or 'Accédez à la ~r~zone marquée~w~.'
				if isTargetDead then missionText = 'Semez les flics.' end
				Gui.DisplayObjectiveText(missionText)
			end
		end
	end)

	while true do
		Citizen.Wait(0)

		if not MissionManager.Mission then
			TriggerEvent('lsv:headhunterFinished', false)
			return
		end

		if eventStartTime:Elapsed() < Settings.headhunter.time then
			Gui.DrawTimerBar('TEMPS DE MISSION', Settings.headhunter.time - eventStartTime:Elapsed(), 1)

			isTargetDead = IsEntityDead(targetPed)
			isInMissionArea = Player.DistanceTo(target.location) < Settings.headhunter.radius

			if not isTargetWandering then
				if not IsEntityWaitingForWorldCollision(targetPed) and HasCollisionLoadedAroundEntity(targetPed) then
					TaskWanderStandard(targetPed, 10., 10)
					isTargetWandering = true
				end
			end

			if not isTargetDead then
				local targetPosition = GetEntityCoords(targetPed, true)
				if GetDistanceBetweenCoords(targetPosition.x, targetPosition.y, targetPosition.z, target.location.x, target.location.y, target.location.z, false) > Settings.headhunter.radius then
					TriggerEvent('lsv:headhunterFinished', false, 'La cible a quitté la zone.')
					return
				elseif isInMissionArea and Player.IsActive() then
					Gui.DrawProgressBar('DISTANCE DE LA CIBLE', 1.0 - Player.DistanceTo(targetPosition) / Settings.headhunter.radius, 2, Color.GetHudFromBlipColor(Color.BLIP_RED))
				end
			end

			if loseTheCopsStage and IsPlayerDead(PlayerId()) then
				TriggerEvent('lsv:headhunterFinished', false)
				return
			end

			if loseTheCopsStage and GetPlayerWantedLevel(PlayerId()) == 0 then
				TriggerServerEvent('lsv:headhunterFinished', eventStartTime._startTime, loseTheCopsStageStartTime, GetGameTimer())
				return
			end
		else
			TriggerEvent('lsv:headhunterFinished', false, 'Fin du temps imparti.')
			return
		end
	end
end)


RegisterNetEvent('lsv:headhunterFinished')
AddEventHandler('lsv:headhunterFinished', function(success, reason)
	if helpHandler then helpHandler:Cancel() end

	MissionManager.FinishMission(success)

	World.SetWantedLevel(0)
	if DoesEntityExist(targetPed) then RemovePedElegantly(targetPed) end

	removeTargetBlip()

	Gui.FinishMission('Headhunter', success, reason)
end)
