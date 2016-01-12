local map_vsn = 3

function WorldLoaded()
  local game = InitGame()
  local players = InitPlayers()

  Media.DisplayMessage('Welcome to Micro Control v' .. map_vsn .. '!', 'Briefing')
  Media.DisplayMessage('Map made by Kyrylo Silin', 'Briefing')
  Media.DisplayMessage('Your objective is to outmicro other players given a group of units.', 'Briefing')
  Media.DisplayMessage('Each player has the same set of units as you.', 'Briefing')
  Media.DisplayMessage('Pro tip: search for crates.' , 'Briefing')
  Media.DisplayMessage('Your cash will be used to determine the winner if the scores are equal.', 'Briefing')
  Media.DisplayMessage('Good luck & have fun!', 'Briefing')

  Trigger.AfterDelay(DateTime.Seconds(5), function()
    BeginGame(game, players)
  end)
end
