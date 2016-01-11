function SpawnCrates(game)
  SpawnCenterCrates(game)
  SpawnSideCrates(game)
  ParadropRandomCrates(game)
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
    table.insert(
      game.SpawnedCrates,
      Actor.Create(Utils.Random(game.CrateTypes), true, {
        Owner = neutral,
        Location = loc
      }
    ))
  end
end

function SpawnSideCrates(game)
  for i=1,8 do
    table.insert(
      game.SpawnedCrates,
      Actor.Create(Utils.Random(game.CrateTypes), true, {
        Owner = neutral,
        Location = Utils.Random(game.SideCrateLocations).Location
      })
    )
  end
end

function ParadropRandomCrates(game)
  local lz
  local start
  local transport
  local actor

  for i=1,3 do
    lz = Map.RandomCell()
    start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude('badr'))
    transport = Actor.Create('badr', true, {
      CenterPosition = start,
      Owner = neutral,
      Facing = (Map.CenterOfCell(lz) - start).Facing
    })

    actor = Actor.Create('unitcrate', false, { Owner = neutral })
    table.insert(game.SpawnedCrates, actor)
    transport.LoadPassenger(actor)
    transport.Paradrop(lz)
  end
end
