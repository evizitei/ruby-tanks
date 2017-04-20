require_relative './base_bot'

# Just chases batteries.  Wherever the battery is, move towards that.
class BatteryBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    return move_towards_battery
  end

  def name
    "BatteryBot"
  end

end
