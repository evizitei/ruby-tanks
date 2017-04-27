require_relative './base_bot'

class GingerBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)

    if @my_energy <= 100
      return move_towards_battery
    elsif facing_enemy?
      return :shoot
    else
      return move_towards_closest_enemy(@current_game_state, @current_bots)
    end
  end

  def name
    "GingerBot"
  end

end
