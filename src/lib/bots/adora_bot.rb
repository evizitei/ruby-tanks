require_relative './base_bot'

class AdoraBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    if in_danger_from_sides?(game_state, shots)
      return :up
    end
    return move_towards_battery
  end

  def name
    "AdoraBot"
  end

end
