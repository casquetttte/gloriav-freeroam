Player = { }

Player.Loaded = false

Player.Frozen = false
Player.Kills = 0
Player.Skin = nil
Player.Moderator = nil

Player.Killstreak = 0
Player.Deathstreak = 0

Player.VehicleHandle = nil
Player.Vehicle = nil

Player.PatreonTier = nil

Player.Cash = 0
Player.Experience = 0
Player.Rank = 1
Player.Prestige = 0

Player.CrewMembers = { }

local serverId = nil

local function setSkillStats(stats)
	StatSetInt(GetHashKey('MP0_STRENGTH'), stats.strength, true)
	StatSetInt(GetHashKey('MP0_SHOOTING_ABILITY'), stats.shooting, true)
	StatSetInt(GetHashKey('MP0_FLYING_ABILITY'), stats.flying, true)
	StatSetInt(GetHashKey('MP0_WHEELIE_ABILITY'), stats.driving, true)
	StatSetInt(GetHashKey('MP0_LUNG_CAPACITY'), stats.lung, true)
	StatSetInt(GetHashKey('MP0_STEALTH_ABILITY'), stats.stealth, true)
	StatSetInt(GetHashKey('MP0_STAMINA'), stats.stamina, true)
end


function Player.Init(playerData)
	Player.Cash = playerData.Cash

	serverId = GetPlayerServerId(PlayerId())

	Player.Kills = playerData.Kills
	Player.PatreonTier = playerData.PatreonTier
	Player.Moderator = playerData.Moderator

	Player.Experience = playerData.Experience
	Player.Rank = playerData.Rank
	Player.Prestige = playerData.Prestige

	setSkillStats(playerData.SkillStats)

	SetPlayerMaxArmour(PlayerId(), Settings.maxArmour)

	Skin.ChangePlayerSkin(playerData.SkinModel, true)

	Player.GiveWeapons(playerData.Weapons)
end


function Player.IsActive()
	return not IsPlayerDead(PlayerId()) and not Player.Frozen and not IsPlayerSwitchInProgress() and not GetIsLoadingScreenActive()
end


function Player.IsOnMission()
	return Player.IsActive() and MissionManager.Mission
end


function Player.IsInFreeroam()
	return Player.IsActive() and not MissionManager.Mission and not World.ChallengingPlayer
end


function Player.ServerId()
	return serverId
end


function Player.IsCrewMember(id)
	return table.ifind(Player.CrewMembers, id)
end


function Player.GetPlayerWeapons()
	local player = PlayerPedId()
	local ammoTypes = { }
	local result = { }

	table.foreach(Weapon, function(weapon, id)
		local weaponHash = GetHashKey(id)
		if HasPedGotWeapon(player, weaponHash, false) then
			local playerWeapon = { }

			playerWeapon.id = id

			local ammoType = GetPedAmmoTypeFromWeapon(player, weaponHash)
			if ammoTypes[ammoType] == nil then
				ammoTypes[ammoType] = true
				playerWeapon.ammo = GetAmmoInPedWeapon(player, weaponHash)
			else
				playerWeapon.ammo = 0
			end

			if weaponHash == GetSelectedPedWeapon(player) then
				playerWeapon.selected = true
			end

			playerWeapon.components = { }
			table.foreach(weapon.components, function(component)
				if HasPedGotWeaponComponent(player, weaponHash, component.hash) then
					table.insert(playerWeapon.components, component.hash)
				end
			end)

			playerWeapon.tintIndex = GetPedWeaponTintIndex(player, weaponHash)

			table.insert(result, playerWeapon)
		end
	end)

	return result
end


function Player.GiveWeapons(weapons)
	local player = PlayerPedId()

	table.foreach(weapons, function(weapon)
		local weaponHash = GetHashKey(weapon.id)

		GiveWeaponToPed(player, weaponHash, weapon.ammo, false, weapon.selected or false)

		table.foreach(weapon.components, function(component)
			GiveWeaponComponentToPed(player, GetHashKey(weapon.id), component)
		end)

		SetPedWeaponTintIndex(player, weaponHash, weapon.tintIndex)
	end)
end


function Player.SaveWeapons()
	TriggerServerEvent('lsv:savePlayerWeapons', Player.GetPlayerWeapons())
end


function Player.Save()
	Player.SaveWeapons()

	TriggerServerEvent('lsv:playerSaved')
end

function Player.Position(alive)
	return GetEntityCoords(PlayerPedId(), alive)
end


function Player.DistanceTo(position, useZ)
	local playerPosition = Player.Position()
	return Vdist(playerPosition.x, playerPosition.y, playerPosition.z, position.x, position.y, position.z, useZ)
end


function Player.Teleport(position)
	local playerPed = PlayerPedId()

	ClearPedTasksImmediately(playerPed)
	SetEntityCoords(playerPed, position.x, position.y, position.z - 1.0)

	RequestCollisionAtCoord(position.x, position.y, position.z)
	while not HasCollisionLoadedAroundEntity(playerPed) do
		Citizen.Wait(0)
		RequestCollisionAtCoord(position.x, position.y, position.z)
	end

	PlaceObjectOnGroundProperly(playerPed)
end


function Player.SetFreeze(freeze)
	SetEntityAlpha(PlayerPedId(), freeze and 128 or 255)
	SetPlayerControl(PlayerId(), not freeze, false)
	FreezeEntityPosition(PlayerPedId(), freeze)
	SetEntityCollision(PlayerPedId(), not freeze)
	SetPlayerInvincible(PlayerId(), freeze)

	Player.Frozen = freeze
end


function Player.Kill()
	SetEntityHealth(PlayerPedId(), 0)
end


function Player.ExplodePersonalVehicle()
	if not Player.VehicleHandle then return false end

	local explodeTimer = Timer.New()

	NetworkRequestControlOfEntity(Player.VehicleHandle)
	while not NetworkHasControlOfEntity(Player.VehicleHandle) do
		Citizen.Wait(0)
		if explodeTimer:Elapsed() >= 1000 then
			Gui.DisplayPersonalNotification('Impossible d\'obtenir le contrôle du véhicule personnel.')
			return false
		end
	end

	NetworkExplodeVehicle(Player.VehicleHandle, true, false, false)
	SetEntityAsNoLongerNeeded(Player.VehicleHandle)

	return true
end


RegisterNetEvent('lsv:cashUpdated')
AddEventHandler('lsv:cashUpdated', function(cashDiff)
	Player.Cash = Player.Cash + cashDiff
end)


RegisterNetEvent('lsv:experienceUpdated')
AddEventHandler('lsv:experienceUpdated', function(exp)
	Player.Experience = Player.Experience + exp
	TriggerEvent('lsv:showExperience', exp)
end)


RegisterNetEvent('lsv:playerRankedUp')
AddEventHandler('lsv:playerRankedUp', function(rank, skillStats)
	Player.Rank = rank
	setSkillStats(skillStats)
	TriggerEvent('lsv:rankUp')
end)


RegisterNetEvent('lsv:savePlayer')
AddEventHandler('lsv:savePlayer', function()
	Player.Save()
end)
