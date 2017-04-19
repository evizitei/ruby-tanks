require_relative './base_bot'

# deterministically spins and shoots, no strategy
class BattleBot < BaseBot

  def initialize(input_images)
    super(input_images)
    @last_direction = :up
    @last_action = :shoot
  end

  def choose_action(game_state, bot_info, shots, battery_position)
    if @last_action != :shoot
      @last_action = :shoot
      return :shoot
    end

    case @last_direction
    when :up
      @last_direction = @last_action = :right
      return :right
    when :right
      @last_direction = @last_action = :down
      return :down
    when :down
      @last_direction = @last_action = :left
      return :left
    when :left
      @last_direction = @last_action = :up
      return :up
    end
  end

  def name
    "BattleBot"
  end

end
