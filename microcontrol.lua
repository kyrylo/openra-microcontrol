map_vsn = 1

Msg = function(msg)
  Media.DisplayMessage(msg, 'Briefing')
end

-- ParadropRankCrates = function()
--   Utils.Do(centreLocations, function(actor)
--     local powerproxy = Actor.Create('powerproxy.paratroopers', true, { Owner = neutral })
--     powerproxy.SendParatroopers(actor, false, Facing.South)
--   end)

--   -- local paradropLocation = Utils.Random(centreLocations)
--   -- local powerproxy = Actor.Create('powerproxy.paratroopers', true, { Owner = neutral })
--   -- powerproxy.SendParatroopers(paradropLocation, false, Facing.South)

--   -- transport.Paradrop(paradropLocation)

--   -- for i, location in ipairs(centreLocations) do
--   --   Paradrop.Paradrop(location)
--   --   Actor.Create('crate', true, { Owner = neutral, Location = location } )
--   -- end
-- end

function TableSize(T)
  local count = 0

  for _ in pairs(T) do
    count = count + 1
  end

  return count
end

function InitWaves()
  return {
    -- Round 1
    {
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      {},
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      {},
      {},
      {}
    },
    -- Round 2
    {
      { 'medi' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'medi' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      {},
      { 'e1', 'e1', 'e1', 'e1', 'e1' }
    },
    -- Round 3
    {
      { 'medi', 'dog' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'medi', 'dog' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' }
    },
    -- Round 4
    {
      {},
      { 'e3', 'e3', 'e3' },
      {},
      { 'ftrk' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'ftrk' }
    }
    -- Round 5
  }
end

function ShowScoreboard(players)
  local msg = '[scoreboard] '
  Utils.Do(players, function(player)
    msg = msg .. player.Player.Name .. ' - ' .. player.Points .. '. '
  end)
  Msg(msg)
end

function BeginGame(players, waves)
  local totalRounds = TableSize(waves)
  local currentRound = 1

  BeginRound(currentRound, waves, players, totalRounds)
end

function IsHusk(actor)
  return EndsWith(string.lower(actor.Type), '.husk')
end

function EndsWith(str, tail)
  return #str >= #tail and string.sub(str, 1 + #str - #tail) == tail
end

function EndRound()
  local unitsToDestroy = Map.ActorsInBox(Map.TopLeft,Map.BottomRight, function(actor)
    return IsHusk(actor) or actor.Owner ~= neutral or actor.HasProperty('Crate')
  end)

  Utils.Do(unitsToDestroy, function(actor)
    if not actor.IsDead then
      -- Keep player from spamming move commands.
      actor.Owner=neutral
      actor.Stop()
      actor.Destroy()
      Trigger.OnIdle(actor, function(a)
        a.Destroy()
      end)
    end
  end)
end

function EndGame(players)
  local bestScore = 0
  local winner

  Utils.Do(players, function(player)
    if player.Points > bestScore then
      bestScore = player.Points
      winner = player
    end
  end)

  Msg('Player ' .. winner.Player.Name .. ' won the game!')

  Utils.Do(players, function(player)
    if player == winner then
      winner.Player.MarkCompletedObjective(winner.Player.AddPrimaryObjective('win'))
    else
      player.Player.MarkFailedObjective(player.Player.AddPrimaryObjective('lose'))
    end
  end)
end

function BeginRound(currentRound, waves, players, totalRounds)
  if currentRound > totalRounds then
    EndGame(players)
    return
  end

  Msg('Round ' .. currentRound)

  Utils.Do(players, function(player)
    Media.PlaySpeechNotification(player.Player, 'ReinforcementsArrived')
  end)

  local wave = waves[currentRound]
  local winCandidates = {}

  for i=1,4 do
    local player = players[i]

    if player then
      winCandidates[i] = i
      local armySize = 0
      local armyArrivedSize = 0


      player.RoundArmy = {}

      for j, squad in ipairs(wave) do
        armySize = armySize + TableSize(squad)

        player.RoundArmy[j] =
          Reinforcements.Reinforce(neutral, squad, { player.Spawnpoint,
                                   player.Waypoints[j].Location }, 25, function(actor)
                                     armyArrivedSize = armyArrivedSize + 1
                                     if armyArrivedSize == armySize then
                                       Utils.Do(player.RoundArmy, function(sq)
                                         Utils.Do(sq, function(a)
                                           a.Owner = player.Player
                                         end)
                                       end)
                                     end
                                   end)

        Utils.Do(player.RoundArmy[j], function(actor)
          Trigger.OnKilled(actor, function()
            armySize = armySize - 1

            if armySize == 0 then
              winCandidates[i] = nil

              if TableSize(winCandidates) == 1 then
                for _, winner in pairs(winCandidates) do
                  local winnerPlayer = players[winner]
                  Msg('Player ' .. winnerPlayer.Player.Name .. ' won the round!')
                  EndRound()
                  winnerPlayer.Points = winnerPlayer.Points + 1
                  ShowScoreboard(players)

                  Trigger.AfterDelay(DateTime.Seconds(2), function()
                    BeginRound(currentRound + 1, waves, players, totalRounds)
                  end)
                end
              end
            end
          end)
        end)
      end
    end
  end

  -- ParadropRankCrates()
end

function InitPlayers()
  local waypoints = {
    -- Player 1
    { AWaypoint1, AWaypoint2, AWaypoint3, AWaypoint4, AWaypoint5, AWaypoint6 },
     -- Player 2
    { BWaypoint1, BWaypoint2, BWaypoint3, BWaypoint4, BWaypoint5, BWaypoint6 },
    -- Player 3
    { CWaypoint1, CWaypoint2, CWaypoint3, CWaypoint4, CWaypoint5, CWaypoint6 },
    -- Player 4
    { DWaypoint1, DWaypoint2, DWaypoint3, DWaypoint4, DWaypoint5, DWaypoint6 }
  }

  local spawnpoints = {
    -- Player 1 (TopLeft)
    CPos.New(1, 1),
    -- Player 2 (TopRight)
    CPos.New(1, 64),
    -- Player 3 (BottomRight)
    CPos.New(64, 64),
    -- Player 4 (BottomLeft)
    CPos.New(64, 1)
  }

  -- Neutral player owns crates and such
  neutral = Player.GetPlayer('Neutral')

  local players = {}

  for i=1,4 do
    local player = Player.GetPlayer('Multi' .. i-1)

    if player then
      players[i] = {
        Player = player,
        Waypoints = waypoints[i],
        Spawnpoint = spawnpoints[i],
        Points = 0
      }
    end
  end

  return players
end

function WorldLoaded()
  Msg('Welcome to Micro Control v' .. map_vsn .. '!')
  Msg('Your objective is to outmicro other players given a group of units.')
  Msg('Each player has the same set of units as you.')

  local players = InitPlayers()
  local waves = InitWaves()

  Trigger.AfterDelay(DateTime.Seconds(2), function()
    BeginGame(players, waves)
  end)
end
