ChallengeManager = { }

local logger = Logger.New('ChallengeManager')

local players = { }


function ChallengeManager.Start(player, opponent)
	if players[player] or players[opponent] then return end

	players[player] = { opponent = opponent }
	players[opponent] = { opponent = player }
end

function ChallengeManager.Finish(player)
	if not players[player] then return end

	local opponent = players[player]
	players[player] = nil
	players[opponent] = nil
end

function ChallengeManager.GetPlayerOpponent(player)
	return players[player].opponent
end

function ChallengeManager.IsPlayerInChallenge(player)
	return players[player]
end

function ChallengeManager.GetData(player, id)
	if not id then return players[player]
	else return players[player][id] end
end

function ChallengeManager.ModifyData(player, id, valueDiff, defaultValue)
	if not players[player] then return end
	if not players[player][id] then
		if defaultValue then players[player][id] = defaultValue end
		return
	end
	players[player][id] = players[player][id] + valueDiff
end


function ChallengeManager.SetData(player, id, value)
	if not players[player] then return end
	players[player][id] = value
end

function ChallengeManager.IsChallengeUnavailable(player, opponent)
	local message = nil

	if not Scoreboard.IsPlayerOnline(opponent) then message = 'Votre adversaire n\'est pas disponible.'

	elseif MissionManager.IsPlayerOnMission(player) then message = 'Vous faites une mission en ce moment.'
	elseif MissionManager.IsPlayerOnMission(opponent) then message = 'Votre adversaire fait une mission en ce moment.'

	elseif ChallengeManager.IsPlayerInChallenge(player) then message = 'Vous défiez en ce moment.'
	elseif ChallengeManager.IsPlayerInChallenge(opponent) then message = 'Votre adversaire défie en ce moment.' end

	if message then TriggerClientEvent('lsv:challengeRejected', player, message) end

	return message
end