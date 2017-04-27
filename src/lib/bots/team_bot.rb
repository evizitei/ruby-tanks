require_relative './base_bot'

class TeamBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    return :nothing
  end

  def name
    "TeamBot"
  end

end
