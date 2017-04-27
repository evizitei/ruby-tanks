require_relative './base_bot'

class Bella2Bot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    action = :nothing
    if facing_enemy?
      action = :shoot
    else
      action = move_towards_battery
      if battery_is_in_danger?
        action = :nothing
      end
    end

    if in_danger_from_right?
      action = :up
      if against_top_wall?
        action = :down
      end
    elsif in_danger_from_left?
      action = :down
      if against_bottom_wall?
        action = :up
      end
    elsif in_danger_from_up?
      action = :right
      if against_right_wall?
        action = :left
      end
    elsif in_danger_from_down?
      action = :left
      if against_left_wall?
        action = :right
      end
    end

    return action
  end

  def name
    "Bella2Bot"
  end

end
