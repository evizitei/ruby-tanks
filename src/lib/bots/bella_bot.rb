require_relative './base_bot'

# does nothing every time
class BellaBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    action = :nothing
    if !@on_battery_run
      if in_danger?(game_state, shots)
        @on_battery_run = true
        @target_battery = battery_position
      end
    else
      if is_same_position?(battery_position, @target_battery)
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
        if is_stuck?(action)
          action = [:left, :right].sample
        end
      end
    end
    return action
  end

  def name
    "BellaBot"
  end

end
