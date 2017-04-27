require_relative './base_bot'

class FreddyBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    if in_danger?(@current_game_state, @current_shots)
      if in_danger_from_sides?(@current_game_state, @current_shots)
        return :up
      elsif in_danger_from_column?(@current_game_state, @current_shots)
        return :right
      end
    end
    return move_towards_battery
  end

  def name
    "FreddyBot"
  end

end
