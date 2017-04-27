require_relative './base_bot'

# puts distance between itself and other bots
class ScaredyBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    move_away_from_closest_enemy
  end

  def name
    "ScaredyBot"
  end

end
