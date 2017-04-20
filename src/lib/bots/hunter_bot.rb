require_relative './base_bot'

# Priorizes shooting at tanks, moves if no tank to shoot
class HunterBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    return :shoot if enemy_in_sights?(game_state, bot_info)
    enemy_pos = in_line_with_enemy?(game_state, bot_info)
    if enemy_pos
      return move_towards_position(game_state, enemy_pos)
    else
      return move_towards_closest_enemy(game_state, bot_info)
    end
  end

  def name
    "HunterBot"
  end

end
