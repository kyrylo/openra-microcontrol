function ShowScoreboard(players)
  local scores = ''
  Utils.Do(players, function(player)
    scores = scores .. player.Player.Name .. ' - ' .. player.Points .. '. '
  end)

  Media.DisplayMessage(scores, 'Scoreboard')
end

function ReportFinalScore(players)
  local winner = FindWinnerByPoints(players)
  local winCandidates = FilterTable(players, function(player)
    return player.Points == winner.Points
  end)

  if TableSize(winCandidates) == 1 then
    Media.DisplayMessage(
      winner.Player.Name .. ' earned ' .. winner.Points .. ' points and became the new Micro Control champion!',
      'Game'
    )
  else
    Media.DisplayMessage(
      'Multiple players have earned ' .. winner.Points .. ' points. The winner is decided by the amount of earned cash...',
      'Game'
    )

    winner = FindWinnerByCash(winCandidates)

    Media.DisplayMessage(
      winner.Player.Name .. ' earned ' .. winner.Player.Cash .. ' dollars and became the new Micro Control champion!',
      'Game'
    )
  end

  return winner
end

function FindWinnerByPoints(players)
  local winner
  local bestScore = 0

  Utils.Do(players, function(player)
    if player.Points > bestScore then
      bestScore = player.Points
      winner = player
    end
  end)

  return winner
end

function FindWinnerByCash(players)
  local winner
  local maxCash = 0

  Utils.Do(players, function(player)
    if player.Player.Cash > maxCash then
      maxCash = player.Player.Cash
      winner = player
    end
  end)

  return winner
end
