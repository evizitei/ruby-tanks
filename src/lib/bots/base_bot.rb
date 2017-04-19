require 'securerandom'

class BaseBot
  ACTIONS=[:left, :up, :down, :right, :shoot, :nothing].freeze

  attr_reader :key

  def initialize(input_images)
    @images = input_images
    @key = SecureRandom.uuid
  end

  def choose_action(game_state, bot_info, shots, battery_position)
    raise "OVERRIDE IN SUBCLASS!"
  end

  def image(tagged=false)
    return @images[:tagged] if tagged
    @images[:standard]
  end

  def name
    raise "OVERRIDE IN SUBCLASS!"
  end

  def possible_actions
    ACTIONS.dup
  end

  def color_code
    @images[:color_code]
  end

  protected

  def move_towards_battery(game_state, battery_position)
    pos = get_my_position(game_state)
    return :nothing if battery_position == nil || pos == nil
    choose_from = []
    if pos[:row] < battery_position[:row]
      choose_from << :down
    elsif pos[:row] > battery_position[:row]
      choose_from << :up
    end

    if pos[:col] < battery_position[:col]
      choose_from << :right
    elsif pos[:col] > battery_position[:col]
      choose_from << :left
    end
    action = choose_from.sample
    return :nothing if action == nil
    return action
  end

  def in_danger_from_sides?(game_state, shots)
    return false unless shots.length > 0
    pos = get_my_position(game_state)
    shots.each do |hash|
      if hash[:row] == pos[:row]
        if hash[:col] < pos[:col] && hash[:rotation] == 0
          return true
        elsif hash[:col] > pos[:col] && hash[:rotation] == 180
          return true
        end
      end
    end
    return false
  end

  def in_danger_from_column?(game_state, shots)
    return false unless shots.length > 0
    pos = get_my_position(game_state)
    shots.each do |hash|
      if hash[:col] == pos[:col]
        if hash[:row] < pos[:row] && hash[:rotation] == 90
          return true
        elsif hash[:row] > pos[:row] && hash[:rotation] == 270
          return true
        end
      end
    end
    return false
  end

  def get_my_position(state)
    state.each_with_index do |row, row_i|
      row.each_with_index do |k, col_i|
        return {row: row_i, col: col_i } if k == self.key
      end
    end
    return {row: -1, col: -1}
  end

  def move_towards_battery_line(game_state, battery_position)
    pos = get_my_position(game_state)
    row_diff = (pos[:row] - battery_position[:row]).abs
    col_diff = (pos[:col] - battery_position[:col]).abs
    if row_diff <= col_diff
      return (pos[:row] < battery_position[:row]) ? :down : :up
    else
      return (pos[:col] < battery_position[:col]) ? :right : :left
    end
  end

  def in_line_with_battery?(game_state, battery_position)
    pos = get_my_position(game_state)
    return (pos[:row] == battery_position[:row] || pos[:col] == battery_position[:col])
  end

  def battery_in_sights?(game_state, bot_info, battery_position)
    pos = get_my_position(game_state)
    rot = get_my_rotation(bot_info)
    if pos[:row] == battery_position[:row]
      if pos[:col] < battery_position[:col]
        return true if rot == 0
      elsif pos[:col] > battery_position[:col]
        return true if rot == 180
      end
    elsif pos[:col] == battery_position[:col]
      if pos[:row] < battery_position[:row]
        return true if rot == 90
      elsif pos[:row] > battery_position[:row]
        return true if rot == 270
      end
    end
    return false
  end

  def get_my_rotation(bot_info)
    bot_info[self.key][:rotation]
  end

end
