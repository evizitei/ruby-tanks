require_relative './base_bot'

class CatsBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    if in_danger_from_sides?(@current_game_state, @current_shots)
      if against_bottom_wall?
        return :up
      else
        return :down
      end
    end

    if in_danger_from_column?(@current_game_state, @current_shots)
      if against_right_wall?
        return :left
      else
        return :right
      end
    end
    return move_towards_battery
  end

  def name
    "CatsBot"
  end

end
