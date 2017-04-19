require_relative './base_bot'

class BatteryBot < BaseBot

  def choose_action(game_state, shots, battery_position)
    return move_towards_battery(game_state, battery_position)
  end

  def name
    "BatteryBot"
  end

end
