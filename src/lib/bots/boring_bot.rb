require_relative './base_bot'

class BoringBot < BaseBot

  def choose_action(game_state, shots, battery_position)
    return :nothing
  end

  def name
    "BoringBot"
  end

end
