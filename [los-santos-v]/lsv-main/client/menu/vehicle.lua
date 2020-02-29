local vehicleColors = {
	['Classic'] = {
		{ name = 'Noir', id = 0 },
		{ name = 'Noir Carbon', id = 147 },
		{ name = 'Graphite', id = 1 },
		{ name = 'Noir Anthracite', id = 11 },
		{ name = 'Acier noir', id = 2 },
		{ name = 'Acier sombre', id = 3 },
		{ name = 'Argent', id = 4 },
		{ name = 'Argent bleuté', id = 5 },
		{ name = 'Acier laminé', id = 6 },
		{ name = 'Argent sombre', id = 7 },
		{ name = 'Argent pierre', id = 8 },
		{ name = 'Argent nuit', id = 9 },
		{ name = 'Fonte d\'argent', id = 10 },
		{ name = 'Rouge', id = 27 },
		{ name = 'Rouge torino', id = 28 },
		{ name = 'Rouge formula', id = 29 },
		{ name = 'Rouge lave', id = 150 },
		{ name = 'Rouge flambant', id = 30 },
		{ name = 'Rouge gras', id = 31 },
		{ name = 'Rouge grenat', id = 32 },
		{ name = 'Rouge soleil', id = 33 },
		{ name = 'Rouge cabernet', id = 34 },
		{ name = 'Rouge vin', id = 143 },
		{ name = 'Rouge bonbon', id = 35 },
		{ name = 'Rose vif', id = 135 },
		{ name = 'Rose pfister', id = 137 },
		{ name = 'Rose saumon', id = 136 },
		{ name = 'Orange soleil', id = 36 },
		{ name = 'Orange', id = 38 },
		{ name = 'Orange vif', id = 138 },
		{ name = 'Or', id = 99 },
		{ name = 'Bronze', id = 90 },
		{ name = 'Jaune', id = 88 },
		{ name = 'Jaune racing', id = 89 },
		{ name = 'Jaune rosé', id = 91 },
		{ name = 'Vert sombre', id = 49 },
		{ name = 'Vert racing', id = 50 },
		{ name = 'Vert océan', id = 51 },
		{ name = 'Vert olive', id = 52 },
		{ name = 'Vert vif', id = 53 },
		{ name = 'Vert essence', id = 54 },
		{ name = 'Vert lime', id = 92 },
		{ name = 'Bleu nuit', id = 141 },
		{ name = 'Bleu galaxie', id = 61 },
		{ name = 'Bleu foncé', id = 62 },
		{ name = 'Bleu saxon', id = 63 },
		{ name = 'Bleu', id = 64 },
		{ name = 'Bleu marine', id = 65 },
		{ name = 'Bleu océan', id = 66 },
		{ name = 'Bleu diamant', id = 67 },
		{ name = 'Bleu surf', id = 68 },
		{ name = 'Bleu nautique', id = 69 },
		{ name = 'Bleu racing', id = 73 },
		{ name = 'Bleu ultra', id = 70 },
		{ name = 'Bleu clair', id = 74 },
		{ name = 'Marron chocolat', id = 96 },
		{ name = 'Marron bison', id = 101 },
		{ name = 'Marron', id = 95 },
		{ name = 'Marron Feltzer', id = 94 },
		{ name = 'Brun érable', id = 97 },
		{ name = 'Brun hêtre', id = 103 },
		{ name = 'Brun terre', id = 104 },
		{ name = 'Marron cuir', id = 98 },
		{ name = 'Brun mousse', id = 100 },
		{ name = 'Brun bois', id = 102 },
		{ name = 'Brun paille', id = 99 },
		{ name = 'Brun sable', id = 105 },
		{ name = 'Brun blanchi', id = 106 },
		{ name = 'Violet schafter', id = 71 },
		{ name = 'Violet spinnaker', id = 72 },
		{ name = 'Violet nuit', id = 142 },
		{ name = 'Violet brillant', id = 145 },
		{ name = 'Crème', id = 107 },
		{ name = 'Blanc glacier', id = 111 },
		{ name = 'Blanc givré', id = 112 },
	},

	['Matte'] = {
		{ name = 'Noir', id = 12 },
		{ name = 'Gris', id = 13 },
		{ name = 'Gris clair', id = 14 },
		{ name = 'Blanc', id = 131 },
		{ name = 'Bleu', id = 83 },
		{ name = 'Bleu foncé', id = 82 },
		{ name = 'Bleu nuit', id = 84 },
		{ name = 'Violet nuit', id = 149 },
		{ name = 'Violet', id = 148 },
		{ name = 'Rouge', id = 39 },
		{ name = 'Rouge foncé', id = 40 },
		{ name = 'Orange', id = 41 },
		{ name = 'Jaune', id = 42 },
		{ name = 'Vert lime', id = 55 },
		{ name = 'Vert', id = 128 },
		{ name = 'Vert forêt', id = 151 },
		{ name = 'Vert feuille', id = 155 },
		{ name = 'Brun', id = 152 },
		{ name = 'Marron sombre', id = 153 },
		{ name = 'Crème foncé', id = 154 },
	},

	['Metal'] = {
		{ name = 'Acier brossé', id = 117 },
		{ name = 'Acier noir brossé', id = 118 },
		{ name = 'Aluminium brossé', id = 119 },
		{ name = 'Or pur', id = 158 },
		{ name = 'Or brossé', id = 159 },
	},
}


local vehicleAccessItems = { 'No-one', 'Crew', 'Everyone' }
local vehicleAccessCurrentIndex = 1
local vehiclePosition = { }
local vehicleColor = { primary = 0, secondary = 0 }

local lastVehicle = nil


local function updateDoorsLock()
	SetVehicleDoorsLockedForAllPlayers(Player.VehicleHandle, vehicleAccessCurrentIndex ~= 3)
	if vehicleAccessCurrentIndex == 2 then
		table.iforeach(Player.CrewMembers, function(member)
			SetVehicleDoorsLockedForPlayer(Player.VehicleHandle, GetPlayerFromServerId(member), false)
		end)
	end

	SetVehicleDoorsLockedForPlayer(Player.VehicleHandle, PlayerId(), false)
end

local function updateColor()
	SetVehicleColours(Player.VehicleHandle, vehicleColor.primary, vehicleColor.secondary)
end

local function updateVehicle()
	updateDoorsLock()
	updateColor()
end

local function tryFindVehicleLocation()
	local playerPosition = Player.Position()
	local success, position, heading = GetClosestVehicleNodeWithHeading(playerPosition.x, playerPosition.y, playerPosition.z)
	if not success or Player.DistanceTo(position) > Settings.personalVehicle.maxDistance then
		Gui.DisplayPersonalNotification('Impossible de livrer un véhicule personnel à votre emplacement.')
		return false
	end

	vehiclePosition.position = position
	vehiclePosition.heading = heading

	return true
end

local function getVehiclePrice(vehicle)
	if vehicle.prestige and Player.Prestige < vehicle.prestige then return 'Prestige '..vehicle.prestige end
	if vehicle.rank and Player.Rank < vehicle.rank then return 'Rank '..vehicle.rank end
	return '$'..vehicle.cash
end


local function requestVehicle(model)
	Streaming.RequestModel(model)
	Player.VehicleHandle = CreateVehicle(GetHashKey(model), vehiclePosition.position.x, vehiclePosition.position.y, vehiclePosition.position.z, vehiclePosition.heading, true, false)
	updateVehicle()
	SetVehicleNumberPlateText(Player.VehicleHandle, GetPlayerName(PlayerId()))
	SetVehicleModKit(Player.VehicleHandle, 0) -- Make SetVehicleMod actually works
	SetVehicleMod(Player.VehicleHandle, 16, 1) -- Armor 40%
	SetVehicleTyresCanBurst(Player.VehicleHandle, false)
	SetVehicleOnGroundProperly(Player.VehicleHandle)

	local vehicleBlip = AddBlipForEntity(Player.VehicleHandle)
	SetBlipSprite(vehicleBlip, Blip.CAR)
	SetBlipHighDetail(vehicleBlip, true)
	SetBlipColour(vehicleBlip, Color.BLIP_BLUE)
	Map.SetBlipText(vehicleBlip, 'Véhicule personnel')
	Map.SetBlipFlashes(vehicleBlip)

	Citizen.CreateThread(function()
		local vehicleHandle = Player.VehicleHandle
		local vehicleBlip = vehicleBlip

		while true do
			Citizen.Wait(250)

			if not DoesEntityExist(vehicleHandle) or not IsVehicleDriveable(vehicleHandle) then
				Gui.DisplayPersonalNotification('Votre véhicule personnel a été détruit.')
				RemoveBlip(vehicleBlip)
				if Player.VehicleHandle == vehicleHandle then
					Player.VehicleHandle = nil
				end
				return
			else
				local isPlayerInVehicle = IsPedInVehicle(PlayerPedId(), vehicleHandle)
				SetBlipAlpha(vehicleBlip, isPlayerInVehicle and 0 or 255)
			end
		end
	end)
end


AddEventHandler('lsv:init', function()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)

			if IsControlJustReleased(0, 311) then Gui.OpenMenu('vehicle') end
		end
	end)

	local selectedVehicleCategory = nil
	local selectedVehicleColor = nil
	local selectedVehicleColorCategory = nil

	local vehicles = { }
	table.foreach(Settings.personalVehicle.vehicles, function(categoryVehicles, vehicleCategory)
		vehicles[vehicleCategory] = { }
		table.foreach(categoryVehicles, function(vehicleData, id)
			vehicleData.id = id
			table.insert(vehicles[vehicleCategory], vehicleData)
		end)
		table.sort(vehicles[vehicleCategory], function(lhs, rhs)
			if lhs.rank ~= rhs.rank then return lhs.rank < rhs.rank end
			if lhs.cash ~= rhs.cash then return lhs.cash < rhs.cash end
			return lhs.name < rhs.name
		end)
	end)

	WarMenu.CreateMenu('vehicle', '')
	WarMenu.SetMenuMaxOptionCountOnScreen('vehicle', Settings.maxMenuOptionCount)
	WarMenu.SetSubTitle('vehicle', 'Menu de véhicule personnel')
	WarMenu.SetTitleColor('vehicle', 255, 255, 255)
	WarMenu.SetTitleBackgroundColor('vehicle', 255, 255, 255)
	WarMenu.SetTitleBackgroundSprite('vehicle', 'shopui_title_carmod', 'shopui_title_carmod')

	WarMenu.CreateSubMenu('vehicle_categories', 'vehicle', 'Sélectionnez la catégorie de véhicule')
	WarMenu.CreateSubMenu('vehicle_vehicles', 'vehicle_categories')
	WarMenu.SetMenuButtonPressedSound('vehicle_vehicles', 'WEAPON_PURCHASE', 'HUD_AMMO_SHOP_SOUNDSET')

	WarMenu.CreateSubMenu('vehicle_colorCategory', 'vehicle', 'Couleurs du véhicule')
	WarMenu.CreateSubMenu('vehicle_color', 'vehicle_colorCategory', '')
	WarMenu.CreateSubMenu('vehicle_colorType', 'vehicle_color', '')

	while true do
		if WarMenu.IsMenuOpened('vehicle') then
			if Player.VehicleHandle then
				if WarMenu.Button('Relouer') then
					if Player.ExplodePersonalVehicle() then
						if tryFindVehicleLocation() then
							WarMenu.CloseMenu()
							TriggerServerEvent('lsv:rentVehicle', lastVehicle.id, lastVehicle.category)
							Prompt.ShowAsync()
						end
					end
				elseif WarMenu.Button('Exploser') then
					WarMenu.CloseMenu()
					Player.ExplodePersonalVehicle()
				else
					if WarMenu.ComboBox('Accès véhicule', vehicleAccessItems, vehicleAccessCurrentIndex, vehicleAccessCurrentIndex, function(currentIndex)
						if currentIndex ~= vehicleAccessCurrentIndex then
							vehicleAccessCurrentIndex = currentIndex
							updateDoorsLock()
						end
					end) then
					elseif WarMenu.MenuButton('Couleur', 'vehicle_colorCategory') then end
				end
			else
				if WarMenu.MenuButton('Louer', 'vehicle_categories') then
				elseif lastVehicle and WarMenu.Button(lastVehicle.name, getVehiclePrice(lastVehicle)) then
					if tryFindVehicleLocation() then
						WarMenu.CloseMenu()
						TriggerServerEvent('lsv:rentVehicle', lastVehicle.id, lastVehicle.category)
						Prompt.ShowAsync()
					end
				end
			end

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('vehicle_colorCategory') then
			table.foreach(vehicleColors, function(_, colorCategory)
				if WarMenu.MenuButton(colorCategory, 'vehicle_color') then
					selectedVehicleColorCategory = colorCategory
					WarMenu.SetSubTitle('vehicle_color', colorCategory..' Couleurs')
				end
			end)

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('vehicle_color') then
			table.iforeach(vehicleColors[selectedVehicleColorCategory], function(colorData)
				if WarMenu.MenuButton(colorData.name, 'vehicle_colorType') then
					selectedVehicleColor = colorData.id
					WarMenu.SetSubTitle('vehicle_colorType', colorData.name..' '..selectedVehicleColorCategory..' Couleur')
				end
			end)

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('vehicle_colorType') then
			if WarMenu.Button('Primary') then
				vehicleColor.primary = selectedVehicleColor
				updateColor()
				WarMenu.OpenMenu('vehicle_color')
			elseif WarMenu.Button('Secondary') then
				vehicleColor.secondary = selectedVehicleColor
				updateColor()
				WarMenu.OpenMenu('vehicle_color')
			end

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('vehicle_categories') then
			table.foreach(vehicles, function(_, vehicleCategory)
				if WarMenu.MenuButton(vehicleCategory, 'vehicle_vehicles') then
					WarMenu.SetSubTitle('vehicle_vehicles', vehicleCategory)
					selectedVehicleCategory = vehicleCategory
				end
			end)

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('vehicle_vehicles') then
			table.foreach(vehicles[selectedVehicleCategory], function(vehicle, _)
				if WarMenu.Button(vehicle.name, getVehiclePrice(vehicle)) then
					if vehicle.prestige and vehicle.prestige > Player.Prestige then
						Gui.DisplayPersonalNotification('Votre Prestige est trop bas.')
					elseif vehicle.rank and vehicle.rank > Player.Rank then
						Gui.DisplayPersonalNotification('Votre Rank est trop bas.')
					elseif tryFindVehicleLocation() then
						lastVehicle = vehicle
						lastVehicle.category = selectedVehicleCategory
						WarMenu.CloseMenu()
						TriggerServerEvent('lsv:rentVehicle', vehicle.id, selectedVehicleCategory)
						Prompt.ShowAsync()
					end
				end
			end)

			WarMenu.Display()
		end

		Citizen.Wait(0)
	end
end)


RegisterNetEvent('lsv:vehicleRented')
AddEventHandler('lsv:vehicleRented', function(model, name)
	if not model then
		Gui.DisplayPersonalNotification('Vous n\'avez pas assez de cash.')
		Prompt.Hide()
		return
	end

	requestVehicle(model)
	Gui.DisplayPersonalNotification('Vous avez loué '..name..'.')
	Prompt.Hide()
end)
