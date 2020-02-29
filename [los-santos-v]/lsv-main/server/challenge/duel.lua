local logger = Logger.New('Duel')


RegisterNetEvent('lsv:requestDuel')
AddEventHandler('lsv:requestDuel', function(opponent)
	local player = source

	if ChallengeManager.IsChallengeUnavailable(player, opponent) then return end

	logger:Info('Demandé { '..player..', '..opponent..' }')

	TriggerClientEvent('lsv:duelRequested', opponent, player)
end)


RegisterNetEvent('lsv:duelAccepted')
AddEventHandler('lsv:duelAccepted', function(opponent)
	local player = source

	if ChallengeManager.IsChallengeUnavailable(opponent, player) then return end

	ChallengeManager.Start(player, opponent)

	ChallengeManager.SetData(player, 'score', 0)
	ChallengeManager.SetData(player, 'opponentScore', 0)

	ChallengeManager.SetData(opponent, 'score', 0)
	ChallengeManager.SetData(opponent, 'opponentScore', 0)

	logger:Info('Commencé { '..player..', '..opponent..' }')

	TriggerClientEvent('lsv:duelUpdated', player, ChallengeManager.GetData(player))
	TriggerClientEvent('lsv:duelUpdated', opponent, ChallengeManager.GetData(opponent))
end)


AddEventHandler('baseevents:onPlayerKilled', function(killer)
	local victim = source

	if killer == -1 or not ChallengeManager.IsPlayerInChallenge(killer) or ChallengeManager.GetPlayerOpponent(killer) ~= victim then return end

	ChallengeManager.ModifyData(killer, 'score', 1)

	if ChallengeManager.GetData(killer, 'score') == Settings.duel.targetScore then
		local cash = -Settings.duel.reward.cash
		local victimCash = Scoreboard.GetPlayerCash(victim)
		if victimCash - Settings.duel.reward.cash < 0 then cash = -victimCash end

		Db.UpdateCash(victim, cash)
		Db.UpdateCash(killer, Settings.duel.reward.cash)
		Db.UpdateExperience(killer, Settings.duel.reward.exp)

		ChallengeManager.Finish(killer)

		logger:Info('Terminé { '..killer..', '..victim..' }')

		TriggerClientEvent('lsv:duelEnded', -1, killer, victim)
		return
	end

	ChallengeManager.ModifyData(victim, 'opponentScore', 1)

	TriggerClientEvent('lsv:duelUpdated', killer, ChallengeManager.GetData(killer))
	TriggerClientEvent('lsv:duelUpdated', victim, ChallengeManager.GetData(victim))
end)


AddEventHandler('lsv:playerDropped', function(player)
	if not ChallengeManager.IsPlayerInChallenge(player) then return end

	local opponent = ChallengeManager.GetPlayerOpponent(player)
	ChallengeManager.Finish(player)

	logger:Info('Terminé { '..player..', '..opponent..' }')
	TriggerClientEvent('lsv:duelEnded', opponent)
end)