require_relative './base_bot'

class HamsterBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    if in_danger_from_sides?(@current_game_state, @current_shots)
      return [:down, :up].sample
    end

    if in_danger_from_column?(@current_game_state, @current_shots)
      return [:left, :right].sample
    end

    if facing_enemy?
      return :shoot
    end
    return move_towards_closest_enemy(@current_game_state, @current_bots)
  end

  def name
    "HamsterBot"
  end

end
