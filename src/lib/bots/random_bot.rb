require_relative './base_bot'

class RandomBot < BaseBot

  def choose_action(game_state, shots, battery_position)
    possible_actions.sample
  end

  def name
    "RandomBot"
  end

end
