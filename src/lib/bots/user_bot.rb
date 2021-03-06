require_relative './base_bot'

# responds to keyboard commands, good for experimentation
class UserBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position, kb=Gosu)
    return :shoot if kb.button_down?(Gosu::KB_SPACE)
    return :up if kb.button_down?(Gosu::KB_UP)
    return :down if kb.button_down?(Gosu::KB_DOWN)
    return :left if kb.button_down?(Gosu::KB_LEFT)
    return :right if kb.button_down?(Gosu::KB_RIGHT)
    return :nothing
  end

  def name
    "UserBot"
  end

end
