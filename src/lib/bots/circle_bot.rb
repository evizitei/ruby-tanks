require_relative './base_bot'

# Drives in a circle (Evasive Action!)
class CircleBot < BaseBot

  def initialize(input_images)
    super(input_images)
    @circle_duration = 3
    @current_steps = 0
    @last_direction = :up
  end

  def choose_action(game_state, bot_info, shots, battery_position)
    case @last_direction
    when :up
      return choose_direction(:up, :right)
    when :right
      return choose_direction(:right, :down)
    when :down
      return choose_direction(:down, :left)
    when :left
      return choose_direction(:left, :up)
    end
  end

  def choose_direction(current, next_dir)
    if @current_steps >= @circle_duration
      @current_steps = 0
      @last_direction = next_dir
      return next_dir
    else
      @current_steps += 1
      @last_direction = current
      return current
    end
  end

  def name
    "CircleBot"
  end

end
