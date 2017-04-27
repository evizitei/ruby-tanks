require_relative './base_bot'

class NoodleBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    return move_away_from_closest_enemy
  end

  def name
    "NoodleBot"
  end

end
