function CheckTimeout(game, players, waves, delay)
  game.TimeoutChecksLeft = game.TimeoutChecksLeft - 1

  if game.TimeoutChecksLeft == 0 then
    Media.DisplayMessage(
      'Round ' .. game.CurrentRound .. ' has ended without a winner.',
      'Game'
    )
    game.ResetTimeout(game)
    EndRound(game, players, waves)
  elseif game.TimeoutChecksLeft == 10 then
    Media.DisplayMessage(
      'Stop camping! Otherwise the round will end without a winner.',
      'Game'
    )
  end

  Trigger.AfterDelay(DateTime.Seconds(delay), function()
    if game.ShouldCheckTimeout then
      CheckTimeout(game, players, waves, delay)
    end
  end)
end
