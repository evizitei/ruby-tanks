require_relative './base_bot'

class Team1Bot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    return :shoot
  end

  def name
    "UserBot"
  end

end
