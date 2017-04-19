require_relative './base_bot'

# does nothing every time
class BoringBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    return :nothing
  end

  def name
    "BoringBot"
  end

end
