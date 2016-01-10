-- Shitty function, which doesn't reliably clear actors. I have to call it twice.
function ClearMap(game, players)
  Utils.Do(players, function(player)
    Utils.Do(player.RoundArmy, function(actor)
      if not actor.IsDead then
        actor.Owner = neutral
        actor.Stop()
        actor.Destroy()
        Trigger.OnIdle(actor, function(a) a.Destroy() end)
      end
    end)
  end)

  Utils.Do(game.SpawnedCrates, function(crate)
    if not crate.IsDead then
      crate.Destroy()
    end
  end)

  Utils.Do(Map.ActorsInBox(Map.TopLeft,Map.BottomRight,MustBeDestroyed), function(actor)
    if IsHusk(actor) then
      actor.Destroy()
    end
  end)
end

function SpawnUnits(player, wave)
  local initTable
  local units = {}

  for i, squad in ipairs(wave) do
    for j, unit in ipairs(squad) do
      initTable = {
        Owner = player.Player,
        Location = player.Waypoints[i].Location
      }

      local actor = Actor.Create(unit, true, initTable)
      actor.Scatter()
      table.insert(player.RoundArmy, actor)
    end
  end

  return units
end

function SetTriggers(game, player, players, waves)
  Utils.Do(player.RoundArmy, function(actor)
    Trigger.OnDamaged(actor, function(a, attacker)
      game.ResetTimeout(game)
    end)

    Trigger.OnKilled(actor, function()
      player.RoundDeathCounter = player.RoundDeathCounter + 1

      if player.RoundDeathCounter == TableSize(player.RoundArmy) then
        game.RoundWinners[player] = nil
        Media.DisplayMessage(player.Player.Name .. ' is no more.', 'Game')
      end

      if TableSize(game.RoundWinners) == 1 then
        local winner = next(game.RoundWinners)
        Media.DisplayMessage(winner.Player.Name .. ' won the round!', 'Game')
        winner.Points = winner.Points + 1
        EndRound(game, players, waves)
      end
    end)
  end)
end

function BeginGame(game, players)
  local waves = InitWaves()

  game.TotalRounds = TableSize(waves)
  game.CurrentRound = 1

  BeginRound(game, players, waves)
end

function BeginRound(game, players, waves)
  Media.DisplayMessage(
    'Starting round ' .. game.CurrentRound .. ' out of ' .. game.TotalRounds .. '!',
    'Game'
  )

  ClearMap(game, players)
  Utils.Do(players, function(player)
    player.RoundDeathCounter = 0
    player.RoundArmy = {}
  end)

  local evenRound = game.CurrentRound % 2 == 0
  Utils.Do(players, function(player)
    if game.CurrentRound == TableSize(waves) then
      Media.PlaySpeechNotification(player.Player, 'ReinforcementsArrived')
    elseif evenRound then
      Media.PlaySpeechNotification(player.Player, 'AlliedReinforcementsArrived')
    else
      Media.PlaySpeechNotification(player.Player, 'SovietReinforcementsArrived')
    end
  end)

  local player

  for i=1,4 do
    player = players[i]

    if player then
      game.RoundWinners[player] = player
      SpawnUnits(player, waves[game.CurrentRound])
      SetTriggers(game, player, players, waves)
    end
  end

  SpawnCrates(game)
  CheckTimeout(game, players, waves, 5)
end

function EndRound(game, players, waves)
  ClearMap(game, players)

  ShowScoreboard(players)

  game.ShouldCheckTimeout = false
  game.CurrentRound = game.CurrentRound + 1

  if game.CurrentRound > game.TotalRounds then
    EndGame(players)
    return
  end

  Trigger.AfterDelay(DateTime.Seconds(10), function()
    game.ShouldCheckTimeout = true
    BeginRound(game, players, waves)
  end)
end

function EndGame(players)
  local winner = ReportFinalScore(players)

  Trigger.AfterDelay(DateTime.Seconds(4), function()
    Utils.Do(players, function(player)
      if player == winner then
        winner.Player.MarkCompletedObjective(winner.Player.AddPrimaryObjective('win'))
      else
        player.Player.MarkFailedObjective(player.Player.AddPrimaryObjective('lose'))
      end
    end)
  end)
end

function InitGame(players)
  local centerCrateLocations = {
    CCrateWaypoint1, CCrateWaypoint2, CCrateWaypoint3, CCrateWaypoint4,
    CCrateWaypoint5, CCrateWaypoint6
  }

  local sideCrateLocations = {
    SCrateWaypoint1, SCrateWaypoint2, SCrateWaypoint3, SCrateWaypoint4,
    SCrateWaypoint5, SCrateWaypoint6, SCrateWaypoint7, SCrateWaypoint8,
    SCrateWaypoint9, SCrateWaypoint10, SCrateWaypoint11, SCrateWaypoint12
  }

  local totalTimeoutChecks = 25

  return {
    RoundWinners = {},
    CurrentRound = 0,
    TotalRounds = 0,
    TimeoutChecksLeft = totalTimeoutChecks,
    TotalTimeoutChecks = totalTimeoutChecks,
    ShouldCheckTimeout = true,
    CenterCrateLocations = centerCrateLocations,
    SideCrateLocations = sideCrateLocations,
    CrateTypes = { 'rankcrate', 'moneycrate', 'healcrate' },
    SpawnedCrates = {},
    ResetTimeout = function(game)
      game.TimeoutChecksLeft = totalTimeoutChecks
    end
  }
end

function InitPlayers()
  local waypoints = {
    -- Player 1 (TopLeft)
    { AWaypoint1, AWaypoint2, AWaypoint3, AWaypoint4, AWaypoint5, AWaypoint6 },
     -- Player 2 (TopRight)
    { BWaypoint1, BWaypoint2, BWaypoint3, BWaypoint4, BWaypoint5, BWaypoint6 },
    -- Player 3 (BottomRight)
    { CWaypoint1, CWaypoint2, CWaypoint3, CWaypoint4, CWaypoint5, CWaypoint6 },
    -- Player 4 (BottomLeft)
    { DWaypoint1, DWaypoint2, DWaypoint3, DWaypoint4, DWaypoint5, DWaypoint6 }
  }

  -- Neutral player owns crates and such
  neutral = Player.GetPlayer('Neutral')
  creeps = Player.GetPlayer('Creeps')

  local players = {}

  for i=1,4 do
    local player = Player.GetPlayer('Multi' .. i-1)

    if player then
      players[i] = {
        Player = player,
        Waypoints = waypoints[i],
        Points = 0,
        RoundArmy = {},
        RoundDeathCounter = 0
      }
    end
  end

  return players
end
