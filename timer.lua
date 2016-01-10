function CheckTimeout(game, players, waves, delay)
  game.TimeoutChecksLeft = game.TimeoutChecksLeft - 1

  Media.DisplayMessage('Checking timeout', 'DEBUG')

  if game.TimeoutChecksLeft == 0 then
    Media.DisplayMessage('There you go, I warned you! Round has ended without a winner. Hope you are guys happy now.', 'Game')
    game.ResetTimeout(game)
    EndRound(game, players, waves)
  elseif game.TimeoutChecksLeft < game.TotalTimeoutChecks then
    Media.DisplayMessage(
      "Stop camping! Otherwise I'll end this round without a winner in " .. delay*game.TimeoutChecksLeft .. ' seconds.',
      'Game'

    )
  end

  Trigger.AfterDelay(DateTime.Seconds(delay), function()
      Media.DisplayMessage('DELAYED', 'DEBUG')
      if game.ShouldCheckTimeout then
        Media.DisplayMessage('ALL GOOD REDEFINING', 'DEBUG')
        CheckTimeout(game, players, waves, delay)
      end
  end)
end
