require_relative './base_bot'

# does nothing every time
class BellaBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    action = :nothing
    my_position = get_my_position(game_state)
    if on_same_row_as_enemy?(game_state, bot_info)
      if facing_enemy?(game_state, bot_info)
        action = :shoot
      else
        action = turn_towards_enemy(game_state, bot_info)
      end
    else
      action = move_towards_same_row_as_closest_enemy(game_state, bot_info)
      if is_stuck?(action, my_position)
        action = [:left, :right].sample
      end
    end
    @last_position = my_position
    @last_action = action
    return action
  end

  def name
    "BellaBot"
  end

  protected

  def is_stuck?(action, my_position)
    if action != :shoot && action == @last_action
      return (my_position[:row] == @last_position[:row] && my_position[:col] == @last_position[:col])
    end
    return false
  end


end
