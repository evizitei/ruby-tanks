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
    return action
  end

  def name
    "Bella2Bot"
  end

end
