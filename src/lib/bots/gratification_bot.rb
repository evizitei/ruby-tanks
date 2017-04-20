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

end
