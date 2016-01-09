local map_vsn = 1

------------------------------------------------------------
-- Support functions that make Lua suck less
------------------------------------------------------------

function TableSize(T)
  local count = 0

  for _ in pairs(T) do
    count = count + 1
  end

  return count
end

FilterTable = function(t, filterIter)
  local out = {}

  for k, v in pairs(t) do
    if filterIter(v, k, t) then out[k] = v end
  end

  return out
end

------------------------------------------------------------
-- Game functions
------------------------------------------------------------

function ShowScoreboard(players)
  local scores = ''
  Utils.Do(players, function(player)
    scores = scores .. player.Player.Name .. ' - ' .. player.Points .. '. '
  end)

  Media.DisplayMessage(scores, 'Scoreboard')
end

function IsHusk(actor)
  return EndsWith(string.lower(actor.Type), '.husk')
end

function EndsWith(str, tail)
  return #str >= #tail and string.sub(str, 1 + #str - #tail) == tail
end

function ClearMap()
  local unitsToDestroy =
    Map.ActorsInBox(Map.TopLeft,Map.BottomRight, function(actor)
      return IsHusk(actor) or actor.Owner ~= neutral or
        actor.Type == 'rankcrate' or actor.Type == 'moneycrate' or
        actor.Type == 'healcrate'
    end)

  Utils.Do(unitsToDestroy, function(actor)
    if not actor.IsDead then
      -- Keep player from spamming move commands.
      actor.Owner = neutral
      actor.Stop()
      actor.Destroy()
      if actor.HasProperty('ScriptTriggers') then
        Trigger.OnIdle(actor, function(a) a.Destroy() end)
      end
    end
  end)
end

function EndRound(game, players, waves)
  ClearMap()
  ShowScoreboard(players)
  Utils.Do(players, function(player)
    player.RoundDeathCounter = 0
    player.RoundArmy = {}
  end)

  game.CurrentRound = game.CurrentRound + 1

  if game.CurrentRound > game.TotalRounds then
    EndGame(players)
    return
  end

  Trigger.AfterDelay(DateTime.Seconds(5), function()
    BeginRound(game, players, waves)
  end)
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
    Trigger.OnKilled(actor, function()
      player.RoundDeathCounter = player.RoundDeathCounter + 1

      -- Media.DisplayMessage(player.Player.Name .. '..' .. player.RoundDeathCounter .. '/' .. TableSize(player.RoundArmy), 'DEBUG')

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

function BeginRound(game, players, waves)
  Media.DisplayMessage(
    'Starting round ' .. game.CurrentRound .. ' out of ' .. game.TotalRounds .. '!',
    'Game'
  )
  Utils.Do(players, function(player)
    Media.PlaySpeechNotification(player.Player, 'ReinforcementsArrived')
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
end

function SpawnCrates(game)
  SpawnCenterCrates(game)
  SpawnSideCrates(game)
end

function SpawnCenterCrates(game)
  local location1
  local location2
  local location3

  while location1 == location2 or location1 == location3 or location2 == location3 do
    location1 = Utils.Random(game.CenterCrateLocations).Location
    location2 = Utils.Random(game.CenterCrateLocations).Location
    location3 = Utils.Random(game.CenterCrateLocations).Location
  end

  local locations = { location1, location2, location3 }

  for i, loc in ipairs(locations) do
    Actor.Create(Utils.Random(game.CrateTypes), true, {
      Owner = neutral,
      Location = loc
    })
  end
end

function SpawnSideCrates(game)
  for i=1,8 do
    Actor.Create(Utils.Random(game.CrateTypes), true, {
      Owner = neutral,
      Location = Utils.Random(game.SideCrateLocations).Location
    })
  end
end

function BeginGame(game, players)
  local waves = InitWaves()

  game.TotalRounds = TableSize(waves)
  game.CurrentRound = 1

  BeginRound(game, players, waves)
end

------------------------------------------------------------
-- Game initialisation functions
------------------------------------------------------------

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

  return {
    RoundWinners = {},
    CurrentRound = 0,
    TotalRounds = 0,
    CenterCrateLocations = centerCrateLocations,
    SideCrateLocations = sideCrateLocations,
    CrateTypes = { 'rankcrate', 'moneycrate', 'healcrate' }
  }
end

function InitWaves()
  return {
    -- Round 1 (Warm up, simple units)
    {
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' }
    },
    -- Round 2 (Early Allies infantry)
    {
      { 'medi', 'e1', 'e1', 'e1', 'e1' },
      { 'medi', 'e1', 'e1', 'e1', 'e1' },
      { 'e1',   'e1', 'e1', 'e1', 'e1' },
      { 'medi', 'e1', 'e1', 'e1', 'e1' },
      { 'medi', 'e1', 'e1', 'e1', 'e1' },
      { 'medi', 'e1', 'e1', 'e1', 'e1' }
    },
    -- Round 3 (Early Soviet infantry)
    {
      { 'dog', 'e1', 'e1', 'e1', 'e2' },
      { 'dog', 'e1', 'e1', 'e1', 'e2' },
      { 'e1',  'e1', 'e1', 'e1', 'e2' },
      { 'dog', 'e1', 'e1', 'e1', 'e2' },
      { 'dog', 'e1', 'e1', 'e1', 'e2' },
      { 'dog', 'e1', 'e1', 'e1', 'e2' }
    },
    -- Round 4 (Light Allies army)
    {
      { '1tnk', 'e1', 'e1', 'e1', 'e3' },
      { 'jeep', 'e3' },
      { '1tnk', 'e1', 'e1', 'e1', 'e3' },
      { '1tnk', 'e1', 'e1', 'e1', 'e3' },
      { 'jeep', 'e3' },
      { '1tnk', 'e1', 'e1', 'e1', 'e3' }
    },
    -- Round 5 (Light Soviet army)
    {
      { 'ftrk', 'e4', 'e4', 'e3', 'e3' },
      { 'apc',  'e2', 'e2', 'e3', 'e3' },
      { 'e1',   'e1', 'e1', 'e1', 'e1' },
      { 'apc',  'e2', 'e2', 'e3', 'e3' },
      { 'ftrk', 'e4', 'e4', 'e3', 'e3' },
      { 'e1',   'e1', 'e1', 'e1', 'e1' }
    },
    -- Round 6 (Mid-game Allies tank army)
    {
      { '2tnk', '2tnk', 'e3', 'mech', 'e3' },
      { '2tnk', '2tnk', 'e1', 'e3',   'e1' },
      { '1tnk', '1tnk', 'e1', 'mech', 'e1' },
      { '1tnk', '1tnk', 'e1', 'mech', 'e1' },
      { '2tnk', '2tnk', 'e1', 'mech', 'e1' },
      { '2tnk', '2tnk', 'e3', 'e3',   'e3' }
    },
    -- Round 7 (Mid-game Soviet tank army)
    {
      { '3tnk', '3tnk', '3tnk', 'e3', 'e3' },
      { '3tnk', '3tnk', '3tnk', 'e3', 'e3' },
      { '3tnk', 'e1',   'e1',   'e1', 'e1' },
      { '3tnk', 'e1',   'e1',   'e1', 'e1' },
      { '3tnk', '3tnk', '3tnk', 'e3', 'e3' },
      { '3tnk', '3tnk', '3tnk', 'e3', 'e3' },
    },
    -- Round 8 (Mid-game Allies long range army)
    {
      { '2tnk', '1tnk', 'jeep', 'e3', 'e3' },
      { '2tnk', 'arty', 'mech', 'e1', 'e1' },
      { '2tnk', '1tnk', 'jeep', 'e1', 'e1' },
      { '2tnk', 'arty', 'mech', 'e1', 'e1' },
      { '2tnk', 'e1',   'e1',   'e1', 'e1' },
      { '2tnk', 'e3',   'e3',   'e3', 'e3' }
    },
    -- Round 9 (Mid-game Soviet long range army)
    {
      { '3tnk', 'v2rl', 'e3',   'e3', 'e3' },
      { '3tnk', 'v2rl', 'e4',   'e4', 'e4' },
      { '3tnk', 'v2rl', 'e2',   'e2', 'e2' },
      { '3tnk', 'v2rl', 'e1',   'e1', 'e1' },
      { '3tnk', 'apc',  'ftrk', 'e1', 'e1' },
      { '3tnk', 'apc',  'ftrk', 'e1', 'e1' }
    },
    -- Round 10 (High tech English army)
    {
      { '2tnk', 'mech', 'arty', 'e3', 'e3' },
      { '2tnk', 'mech', 'arty', 'e3', 'e3' },
      { '2tnk', 'mech', 'arty', 'e3', 'e3' },
      { '2tnk', 'mech', 'arty', 'e1', 'e1' },
      { '2tnk', 'jeep', 'stnk', 'e1', 'e1' },
      { '2tnk', 'jeep', 'stnk', 'e1', 'e1' }
    },
    -- Round 11 (High tech Russian army)
    {
      { '3tnk', 'ttnk', 'v2rl', 'shok', 'e1' },
      { '3tnk', 'ttnk', 'v2rl', 'shok', 'e1' },
      { '4tnk', 'ttnk', 'v2rl', 'shok', 'e1' },
      { '4tnk', 'ttnk', 'shok', 'shok', 'e1' },
      { '3tnk', 'ttnk', 'shok', 'shok', 'e1' },
      { '3tnk', 'ttnk', 'shok', 'e1',   'e1' }
    },
    -- Round 12 (High tech German army)
    {
      { 'ctnk', 'mech', 'arty', 'jeep', 'e1' },
      { 'ctnk', 'mech', '2tnk', 'e3',   'e1' },
      { 'ctnk', 'mech', '2tnk', 'e3',   'e1' },
      { 'ctnk', 'mech', '2tnk', 'e3',   'e1' },
      { 'ctnk', 'mech', '2tnk', 'e3',   'e1' },
      { 'ctnk', 'mech', 'arty', 'e3',   'e1' }
    },
    -- Round 13 (High tech Ukrainian army)
    {
      { 'dtrk', '3tnk', 'v2rl', 'e3', 'e1' },
      { '4tnk', '3tnk', 'v2rl', 'e3', 'e1' },
      { '4tnk', '3tnk', 'v2rl', 'e3', 'e1' },
      { '4tnk', '3tnk', 'v2rl', 'e3', 'e1' },
      { '4tnk', '3tnk', 'v2rl', 'e3', 'e1' },
      { '4tnk', '3tnk', 'e4',   'e4', 'e4' }
    },
    -- Round 14 (High tech French army)
    {
      { '2tnk', 'arty', 'mgg',  'e3', 'e3' },
      { '2tnk', 'arty', 'mgg',  'e3', 'e1' },
      { '2tnk', 'arty', 'mgg',  'e1', 'e1' },
      { '2tnk', 'arty', 'mgg',  'e1', 'e1' },
      { '2tnk', 'arty', 'jeep', 'e3', 'e1' },
      { '2tnk', 'arty', 'jeep', 'e3', 'e3' }
    },
    -- Round 15 (Mixed army, no infantry)
    {
      { 'dtrk', 'arty', 'arty', 'mgg', 'mgg' },
      { '4tnk', '4tnk', 'v2rl', 'v2rl', 'jeep' },
      { 'jeep', 'ftrk', 'ftrk', '2tnk', '2tnk' },
      { '3tnk', '3tnk', '3tnk', '3tnk', '3tnk' },
      { 'arty', 'arty', 'apc', 'apc', '1tnk'   },
      { '1tnk', '1tnk', 'mnly.at', 'mnly.at', 'mnly.at' }
    }
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

function WorldLoaded()
  local game = InitGame()
  local players = InitPlayers()

  Media.DisplayMessage('Welcome to Micro Control v' .. map_vsn .. '!', 'Briefing')
  Media.DisplayMessage('Your objective is to outmicro other players given a group of units.', 'Briefing')
  Media.DisplayMessage('Each player has the same set of units as you.', 'Briefing')
  Media.DisplayMessage('Good luck & have fun!', 'Briefing')

  Trigger.AfterDelay(DateTime.Seconds(5), function()
    BeginGame(game, players)
  end)
end
