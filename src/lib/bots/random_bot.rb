require_relative './base_bot'

# picks a random action every time
class RandomBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    possible_actions.sample
  end

  def name
    "RandomBot"
  end

end
