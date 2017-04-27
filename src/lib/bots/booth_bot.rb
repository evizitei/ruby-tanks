require_relative './base_bot'

class BoothBot < BaseBot

  def initialize(input_images)
    super(input_images)
    @current_direction = :right
    @current_shoot_count = 0
  end

  def choose_action(game_state, bot_info, shots, battery_position)
    if enemy_in_sights?(game_state, bot_info)
      if @current_shoot_count > 10 # If we're just shooting we're probably stuck.
        @current_shoot_count = 0
        return [:down, :up].sample
      else
        @current_shoot_count += 1
        return :shoot
      end
    end

    if enemy_above?(@my_position, game_state)
      return :up
    elsif enemy_below?(@my_position, game_state)
      return :down
    end

    if direction_blocked?(game_state, @my_position, @current_direction)
      @current_direction = @current_direction == :right ? :left : :right
    end
    return @current_direction
  end

  def name
    "BoothBot"
  end

end
