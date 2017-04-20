require_relative './base_bot'

# Tries to defeat battery grabbers by lining up with the battery
# and shooting until the battery moves
class CamperBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    return :shoot if battery_in_sights?(game_state, bot_info, battery_position)
    if in_line_with_battery?(game_state, battery_position)
      return move_towards_battery
    else
      return move_towards_battery_line(game_state, battery_position)
    end
  end

  def name
    "CamperBot"
  end
end
