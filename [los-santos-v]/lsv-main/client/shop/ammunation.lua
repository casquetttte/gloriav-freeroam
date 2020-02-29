AmmuNation = { }


local ammunations = {
	{ blip = nil, ['x'] = 251.37934875488, ['y'] = -48.90043258667, ['z'] = 69.941062927246 },
	{ blip = nil, ['x'] = 843.44445800781, ['y'] = -1032.1590576172, ['z'] = 28.194854736328 },
	{ blip = nil, ['x'] = 810.82800292969, ['y'] = -2156.3671875, ['z'] = 29.619010925293 },
	{ blip = nil, ['x'] = 20.719049453735, ['y'] = -1108.0506591797, ['z'] = 29.797027587891 },
	{ blip = nil, ['x'] = -662.86431884766, ['y'] = -936.32116699219, ['z'] = 21.829231262207 },
	{ blip = nil, ['x'] = -1306.2987060547, ['y'] = -393.93954467773, ['z'] = 36.695774078369 },
	{ blip = nil, ['x'] = -3171.1555175781, ['y'] = 1086.576171875, ['z'] = 20.838750839233 },
	{ blip = nil, ['x'] = -1117.4243164063, ['y'] = 2697.328125, ['z'] = 18.554145812988 },
	{ blip = nil, ['x'] = -329.94900512695, ['y'] = 6082.3178710938, ['z'] = 31.454774856567 },
	{ blip = nil, ['x'] = 2568.3815917969, ['y'] = 295.02661132813, ['z'] = 108.73487854004 },
	{ blip = nil, ['x'] = 1693.8348388672, ['y'] = 3759.2829589844, ['z'] = 34.705318450928 },
}


local function specialWeaponAmmoPrice(weapon, ammo, maxAmmo)
	if ammo == maxAmmo then return 'Max' end
	return '$'..Settings.ammuNationSpecialAmmo[weapon].price
end

local function fullSpecialWeaponAmmoPrice(weapon, ammoClipCount)
	if ammoClipCount == 0 then return 'Max' end
	return '$'..tostring(ammoClipCount * Settings.ammuNationSpecialAmmo[weapon].price)
end


local selectedWeapon = nil
local selectedAmmoType = nil


function AmmuNation.GetPlaces()
	return ammunations
end


AddEventHandler('lsv:init', function()
	table.foreach(ammunations, function(ammunation)
		ammunation.blip = Map.CreatePlaceBlip(Blip.AMMU_NATION, ammunation.x, ammunation.y, ammunation.z)
	end)

	WarMenu.CreateMenu('ammunation_special', '')
	WarMenu.SetSubTitle('ammunation_special', 'Munitions')
	WarMenu.SetTitleBackgroundColor('ammunation_special', Color.GetHudFromBlipColor(Color.BLIP_WHITE).r, Color.GetHudFromBlipColor(Color.BLIP_WHITE).g, Color.GetHudFromBlipColor(Color.BLIP_WHITE).b, Color.GetHudFromBlipColor(Color.BLIP_WHITE).a)
	WarMenu.SetTitleBackgroundSprite('ammunation_special', 'shopui_title_gunclub', 'shopui_title_gunclub')

	WarMenu.CreateSubMenu('ammunation_specialammo', 'ammunation_special', '')
	WarMenu.SetMenuButtonPressedSound('ammunation_specialammo', 'WEAPON_PURCHASE', 'HUD_AMMO_SHOP_SOUNDSET')

	while true do
		Citizen.Wait(0)

		if WarMenu.IsMenuOpened('ammunation_special') then
			table.foreach(Settings.ammuNationSpecialAmmo, function(data, weapon)
				local weaponHash = GetHashKey(weapon)
				if HasPedGotWeapon(PlayerPedId(), weaponHash, false) then
					if WarMenu.MenuButton(Weapon[weapon].name..' '..data.type, 'ammunation_specialammo') then
						selectedWeapon = weapon
						selectedAmmoType = data.type
						WarMenu.SetSubTitle('ammunation_specialammo', Weapon[weapon].name..' '..data.type)
					end
				end
			end)

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('ammunation_specialammo')	then
			local weaponHash = GetHashKey(selectedWeapon)
			local _, maxAmmo = GetMaxAmmo(PlayerPedId(), weaponHash)
			local weaponAmmoType = GetPedAmmoTypeFromWeapon(PlayerPedId(), weaponHash)
			local playerAmmo = GetPedAmmoByType(PlayerPedId(), weaponAmmoType)

			local ammoClipCount = 0
			if playerAmmo ~= maxAmmo then
				ammoClipCount = math.max(1, math.floor((maxAmmo - playerAmmo) / Settings.ammuNationSpecialAmmo[selectedWeapon].ammo))
			end

			if WarMenu.Button('Munitions max', fullSpecialWeaponAmmoPrice(selectedWeapon, ammoClipCount)) then
				if playerAmmo == maxAmmo then
					Gui.DisplayPersonalNotification('Vos munitions sont déjà au max.')
				else
					TriggerServerEvent('lsv:refillSpecialAmmo', selectedWeapon, ammoClipCount)
					Prompt.ShowAsync()
				end
			elseif WarMenu.Button(selectedAmmoType..' x'..Settings.ammuNationSpecialAmmo[selectedWeapon].ammo, specialWeaponAmmoPrice(selectedWeapon, playerAmmo, maxAmmo)) then
				if playerAmmo == maxAmmo then
					Gui.DisplayPersonalNotification('Vos munitions sont déjà au max.')
				else
					TriggerServerEvent('lsv:refillSpecialAmmo', selectedWeapon)
					Prompt.ShowAsync()
				end
			end

			WarMenu.Display()
		end
	end
end)


AddEventHandler('lsv:init', function()
	local ammunationOpenedMenuIndex = nil
	local ammunationColor = Color.GetHudFromBlipColor(Color.BLIP_RED)

	while true do
		Citizen.Wait(0)

		if not IsPlayerDead(PlayerId()) then
			table.foreach(ammunations, function(ammunation, ammunationIndex)
				Gui.DrawPlaceMarker(ammunation.x, ammunation.y, ammunation.z - 1, Settings.placeMarkerRadius, ammunationColor.r, ammunationColor.g, ammunationColor.b, Settings.placeMarkerOpacity)

				if Player.DistanceTo(ammunation, true) < Settings.placeMarkerRadius then
					if not WarMenu.IsAnyMenuOpened() then
						Gui.DisplayHelpText('Appuyez sur ~INPUT_PICKUP~ pour parcourir les munitions.')

						if IsControlJustReleased(0, 38) then
							ammunationOpenedMenuIndex = ammunationIndex
							openedFromInteractionMenu = false
							Gui.OpenMenu('ammunation_special')
						end
					end
				elseif WarMenu.IsMenuOpened('ammunation_special') and ammunationIndex == ammunationOpenedMenuIndex then
					WarMenu.CloseMenu()
					Player.SaveWeapons()
					Prompt.Hide()
				end
			end)
		end
	end
end)


RegisterNetEvent('lsv:specialAmmoRefilled')
AddEventHandler('lsv:specialAmmoRefilled', function(weapon, amount, fullAmmo)
	if amount then
		if not fullAmmo then
			AddAmmoToPed(PlayerPedId(), GetHashKey(weapon), amount)
		else
			local weaponHash = GetHashKey(weapon)
			local _, maxAmmo = GetMaxAmmo(PlayerPedId(), weaponHash)
			SetPedAmmo(PlayerPedId(), weaponHash, maxAmmo)
		end
	else
		Gui.DisplayPersonalNotification('Vous n\'avez pas assez de cash.')
	end

	Prompt.Hide()
end)
