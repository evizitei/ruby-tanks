require_relative './base_bot'

# Just chases batteries.  Wherever the battery is, move towards that.
class BatteryBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    return move_towards_battery(game_state, battery_position)
  end

  def name
    "BatteryBot"
  end

end
