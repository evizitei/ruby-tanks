require_relative './base_bot'

# does nothing every time
class BellaBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    action = :nothing
    my_position = get_my_position(game_state)
    if !@on_battery_run
      if (in_danger_from_sides?(game_state, shots) || in_danger_from_column?(game_state, shots))
        @on_battery_run = true
        @target_battery = battery_position
      end
    else
      if battery_position[:row] != @target_battery[:row] || battery_position[:col] != @target_battery[:col]
        @on_battery_run = false
      end
    end

    if @on_battery_run
      action = move_towards_battery(game_state, battery_position)
    else
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
