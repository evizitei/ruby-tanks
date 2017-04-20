require_relative './base_bot'

# Does whatever is closest (battery or attack tank)
class GratificationBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    if battery_closer_than_any_enemies?
      move_towards_battery
    else
      return :shoot if enemy_in_sights?(game_state, bot_info)
      enemy_pos = in_line_with_enemy?(game_state, bot_info)
      if enemy_pos
        return move_towards_position(game_state, enemy_pos)
      else
        return move_towards_closest_enemy(game_state, bot_info)
      end
    end
  end

  def name
    "GratificationBot"
  end

  def battery_closer_than_any_enemies?
    return distance_to_battery <= distance_to_closest_enemy
  end

  def distance_to_battery
    return 100 unless battery_in_arena?
    distance_between_positions(@my_position, @current_battery_position)
  end

  def distance_to_closest_enemy
    enemy_position = get_position_of_closest_enemy
    distance_between_positions(@my_position, enemy_position)
  end

  def distance_between_positions(position1, position2)
    row_diff = (position1[:row] - position2[:row])
    col_diff = (position1[:col] - position2[:col])
    Math.sqrt((row_diff**2) + (col_diff**2)).round
  end

end
