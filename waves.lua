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
      { 'dtrk', 'arty', 'arty',    'mgg', 'mgg', 'mech' },
      { '4tnk', '4tnk', 'v2rl',    'v2rl', 'jeep', 'mech' },
      { 'jeep', 'ftrk', 'ftrk',    '2tnk', '2tnk', 'mech' },
      { '3tnk', '3tnk', '3tnk',    '3tnk', '3tnk', 'mech' },
      { 'arty', 'arty', 'apc',     'apc', '1tnk', 'mech'   },
      { '1tnk', '1tnk', 'mnly.at', 'mnly.at', 'mnly.at', 'mech' }
    }
  }
end
