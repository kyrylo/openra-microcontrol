local map_vsn = 1

function WorldLoaded()
  local game = InitGame()
  local players = InitPlayers()

  Media.DisplayMessage('Welcome to Micro Control v' .. map_vsn .. '! Map made by Kyrylo Silin', 'Briefing')
  Media.DisplayMessage('Your objective is to outmicro other players given a group of units.', 'Briefing')
  Media.DisplayMessage('Each player has the same set of units as you.', 'Briefing')
  Media.DisplayMessage('Good luck & have fun!', 'Briefing')

  Trigger.AfterDelay(DateTime.Seconds(5), function()
    BeginGame(game, players)
  end)
end
