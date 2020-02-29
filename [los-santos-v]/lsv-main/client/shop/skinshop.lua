Skinshop = { }

local skinshops = {
	{ blip = nil, ['x'] = 72.071105957031, ['y'] = -1399.3981933594, ['z'] = 29.376142501831 },
	{ blip = nil, ['x'] = 428.79281616211, ['y'] = -800.67486572266, ['z'] = 29.491132736206 },
	{ blip = nil, ['x'] = 121.04691314697, ['y'] = -225.82836914063, ['z'] = 54.55782699585 },
	{ blip = nil, ['x'] = -167.84260559082, ['y'] = -299.65042114258, ['z'] = 39.733276367188 },
	{ blip = nil, ['x'] = -704.68463134766, ['y'] = -151.84358215332, ['z'] = 37.415134429932 },
	{ blip = nil, ['x'] = -1447.6271972656, ['y'] = -242.27815246582, ['z'] = 49.820835113525 },
	{ blip = nil, ['x'] = -1187.9968261719, ['y'] = -768.77459716797, ['z'] = 17.32541847229 },
	{ blip = nil, ['x'] = -829.22619628906, ['y'] = -1073.8569335938, ['z'] = 11.328105926514 },
	{ blip = nil, ['x'] = -3175.4289550781, ['y'] = 1042.0402832031, ['z'] = 20.863210678101 },
	{ blip = nil, ['x'] = -1107.6646728516, ['y'] = 2708.447265625, ['z'] = 19.107870101929 },
	{ blip = nil, ['x'] = 617.60980224609, ['y'] = 2766.5490722656, ['z'] = 42.088138580322 },
	{ blip = nil, ['x'] = 1190.5170898438, ['y'] = 2712.6530761719, ['z'] = 38.222595214844 },
	{ blip = nil, ['x'] = 1695.5983886719, ['y'] = 4829.2368164063, ['z'] = 42.063117980957 },
	{ blip = nil, ['x'] = 11.053486824036, ['y'] = 6514.693359375, ['z'] = 31.877849578857 },
}


local function skinKills(id)
	if id == Player.Skin then return 'Used' end

	local skin = Settings.skins[id]
	if skin.rank and Player.Rank < skin.rank then return 'Rank '..skin.rank end
	if skin.kills and Player.Kills < skin.kills then return 'Tuez '..skin.kills..' joueurs' end
	if skin.prestige and Player.Prestige < skin.prestige then return 'Prestige '..skin.prestige end
	return ''
end


function Skinshop.GetPlaces()
	return skinshops
end


AddEventHandler('lsv:init', function()
	table.foreach(skinshops, function(skinshop)
		skinshop.blip = Map.CreatePlaceBlip(Blip.CLOTHING_STORE, skinshop.x, skinshop.y, skinshop.z)
	end)

	WarMenu.CreateMenu('skinshop', '')
	WarMenu.SetSubTitle('skinshop', 'Sélectionnez votre personnage')
	WarMenu.SetTitleBackgroundColor('skinshop', Color.GetHudFromBlipColor(Color.BLIP_WHITE).r, Color.GetHudFromBlipColor(Color.BLIP_WHITE).g, Color.GetHudFromBlipColor(Color.BLIP_WHITE).b, Color.GetHudFromBlipColor(Color.BLIP_WHITE).a)
	WarMenu.SetTitleBackgroundSprite('skinshop', 'shopui_title_lowendfashion', 'shopui_title_lowendfashion')
	WarMenu.SetMenuButtonPressedSound('skinshop', 'WEAPON_PURCHASE', 'HUD_AMMO_SHOP_SOUNDSET')

	local orderedSkins = { }
	table.foreach(Settings.skins, function(v, k)
		table.insert(orderedSkins, { key = k, value = v })
	end)

	table.sort(orderedSkins, function(l, r)
		local lv = l.value
		local rv = r.value
		if lv.prestige and rv.prestige then return lv.prestige < rv.prestige
		elseif not lv.prestige and rv.prestige then return true
		elseif lv.prestige and not rv.prestige then return false
		else return lv.kills < rv.kills end
	end)

	while true do
		Citizen.Wait(0)

		if WarMenu.IsMenuOpened('skinshop') then
			table.foreach(orderedSkins, function(v)
				if WarMenu.Button(v.value.name, skinKills(v.key)) and v.key ~= Player.Skin then
					if v.value.rank and v.value.rank > Player.Rank then
						Gui.DisplayPersonalNotification('Votre Rank est trop bas.')
					elseif v.value.prestige and v.value.prestige > Player.Prestige then
						Gui.DisplayPersonalNotification('Votre Prestige est trop bas.')
					elseif v.value.kills and v.value.kills > Player.Kills then
						Gui.DisplayPersonalNotification('Vous n\'avez pas tué assez de joueurs.')
					else
						TriggerServerEvent('lsv:updatePlayerSkin', v.key)
						Prompt.ShowAsync()
					end
				end
			end)

			WarMenu.Display()
		end
	end
end)


AddEventHandler('lsv:init', function()
	local skinshopOpenedMenuIndex = nil
	local skinshopColor = Color.GetHudFromBlipColor(Color.BLIP_GREEN)

	while true do
		Citizen.Wait(0)

		if not IsPlayerDead(PlayerId()) then
			table.foreach(skinshops, function(skinshop, skinshopIndex)
				Gui.DrawPlaceMarker(skinshop.x, skinshop.y, skinshop.z - 1, Settings.placeMarkerRadius, skinshopColor.r, skinshopColor.g, skinshopColor.b, Settings.placeMarkerOpacity)

				if Player.DistanceTo(skinshop, true) < Settings.placeMarkerRadius then
					if not WarMenu.IsAnyMenuOpened() then
						Gui.DisplayHelpText('Appuyez sur ~INPUT_PICKUP~ pour parcourir les personnages.')

						if IsControlJustReleased(0, 38) then
							skinshopOpenedMenuIndex = skinshopIndex
							Gui.OpenMenu('skinshop')
						end
					end
				elseif WarMenu.IsMenuOpened('skinshop') and skinshopIndex == skinshopOpenedMenuIndex then
					WarMenu.CloseMenu()
					Prompt.Hide()
				end
			end)
		end
	end
end)


RegisterNetEvent('lsv:playerSkinUpdated')
AddEventHandler('lsv:playerSkinUpdated', function(id)
	if not id then return end
	Skin.ChangePlayerSkin(id)
	Prompt.Hide()
end)
