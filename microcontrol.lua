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
    { {'dtrk'}, { 'ftrk' }, {}, {}, {}, {} },
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
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'medi' },
      { 'medi' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      {}
    },
    -- Round 3
    {
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'medi', 'dog' },
      { 'medi', 'dog' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' },
      { 'e1', 'e1', 'e1', 'e1', 'e1' }
    }
  }
end

function BeginGame(players, waves)
  -- local totalPlayers = #players
  local totalRounds = TableSize(waves)
  local currentRound = 1

  -- while currentRound != totalRounds + 1 do
    BeginRound(currentRound, waves[currentRound], players)
    -- currentRound = currentRound + 1
 -- end
end

function BeginRound(currentRound, wave, players)
  Msg('Round ' .. currentRound)

  local winCandidates = {}

  for i=1,4 do
    local player = players[i]

    if player then
      winCandidates[i] = i
      local armySize = 0

      for j, squad in ipairs(wave) do
        local actorsSquad =
          Reinforcements.Reinforce(player.Player, squad, { player.Spawnpoint,
                                   player.Waypoints[j].Location })

        armySize = armySize + TableSize(squad)

        Utils.Do(actorsSquad, function(actor)
          Trigger.OnKilled(actor, function()
            armySize = armySize - 1

            if armySize == 0 then
              winCandidates[i] = nil

              if TableSize(winCandidates) == 1 then
                for _, winner in pairs(winCandidates) do
                  Msg('Player ' .. players[winner].Player.Name .. ' won the round!')
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
    Utils.Do(players, function(player)
      Media.PlaySpeechNotification(player.Player, 'MissionTimerInitialised')
    end)

    BeginGame(players, waves)
  end)
end
