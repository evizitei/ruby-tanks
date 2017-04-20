require_relative './base_bot'

# moves to one side and tries to cover the field with laser fire from the wall
class SaturateBot < BaseBot

  def initialize(input_images)
    super(input_images)
    @current_direction = :down
  end

  def choose_action(game_state, bot_info, shots, battery_position)
    if close_to_left_wall?
      if facing_right?
        if just_fired?
          return :left
        else
          return :shoot
        end
      else
        if against_left_wall?
          if just_moved_along_column?
            return :right
          else
            if against_top_wall?
              @current_direction = :down
            end

            if against_bottom_wall?
              @current_direction = :up
            end
            return @current_direction
          end
        else
          return move_towards_left_wall
        end
      end
    else
      return move_towards_left_wall
    end
  end

  def name
    "SaturateBot"
  end

end
