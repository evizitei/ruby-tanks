require_relative './base_bot'

# moves to one side and tries to cover the field with laser fire from the wall
class TripwireBot < BaseBot

  def initialize(input_images)
    super(input_images)
    @current_direction = :down
  end

  def choose_action(game_state, bot_info, shots, battery_position)
    if close_to_right_wall?
      if facing_left?
        return :shoot
      else
        if against_right_wall?
          return :left
        else
          return :right
        end
      end
    else
      move_towards_right_wall
    end
  end

  def name
    "TripwireBot"
  end

end
