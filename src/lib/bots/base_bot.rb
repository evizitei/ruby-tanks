require 'securerandom'

class BaseBot
  ACTIONS=[:left, :up, :down, :right, :shoot, :nothing].freeze

  attr_reader :key

  def initialize(input_images)
    @images = input_images
    @key = SecureRandom.uuid
  end

  def choose_bot_action(game_state, bot_info, shots, battery_position)
    @current_game_state = game_state
    @current_battery_position = battery_position
    @my_position = my_position()
    @my_rotation = get_my_rotation(bot_info)
    action = choose_action(game_state, bot_info, shots, battery_position)
    @last_position = @my_position
    @last_action = action
    @my_position = nil
    @my_rotation = nil
    @current_game_state = []
    @current_battery_position = {}
    return action
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

  def is_stuck?(action)
    if action != :shoot && action == @last_action
      return is_same_position?(@my_position, @last_position)
    end
    return false
  end

  def choose_action(game_state, bot_info, shots, battery_position)
    raise "OVERRIDE IN SUBCLASS!"
  end

  def move_towards_battery
    return :nothing unless battery_in_arena?
    move_towards_position(@current_game_state, @current_battery_position)
  end

  def in_danger?(game_state, shots)
    return (
      in_danger_from_sides?(game_state, shots) ||
      in_danger_from_column?(game_state, shots)
    )
  end

  def in_danger_from_sides?(game_state, shots)
    return false unless shots.length > 0
    pos = @my_position
    shots.each do |hash|
      if hash[:row] == pos[:row]
        if hash[:col] < pos[:col] && hash[:rotation] == 0
          return true
        elsif hash[:col] > pos[:col] && hash[:rotation] == 180
          return true
        end
      end
    end
    return true if enemy_on_left?(pos, game_state)
    return true if enemy_on_right?(pos, game_state)
    return false
  end

  def enemy_on_left?(my_pos, game_state)
    return false if my_pos[:col] == 0
    return game_state[my_pos[:row]][my_pos[:col] - 1] != nil
  end

  def enemy_on_right?(my_pos, game_state)
    return false if my_pos[:col] >= (game_state[0].length - 1)
    return game_state[my_pos[:row]][my_pos[:col] + 1] != nil
  end

  def enemy_on_top?(my_pos, game_state)
    return false if my_pos[:row] == 0
    return game_state[my_pos[:row] - 1][my_pos[:col]] != nil
  end

  def enemy_on_bottom?(my_pos, game_state)
    return false if my_pos[:row] >= (game_state.length - 1)
    return game_state[my_pos[:row] + 1][my_pos[:col]] != nil
  end

  def in_danger_from_column?(game_state, shots)
    return false unless shots.length > 0
    pos = @my_position
    shots.each do |hash|
      if hash[:col] == pos[:col]
        if hash[:row] < pos[:row] && hash[:rotation] == 90
          return true
        elsif hash[:row] > pos[:row] && hash[:rotation] == 270
          return true
        end
      end
    end
    return true if enemy_on_top?(pos, game_state)
    return true if enemy_on_bottom?(pos, game_state)
    return false
  end

  def is_same_position?(pos1, pos2)
    return (
      pos1[:row] != pos2[:row] ||
      pos1[:col] != pos2[:col]
    )
  end

  def my_position
    @current_game_state.each_with_index do |row, row_i|
      row.each_with_index do |k, col_i|
        return {row: row_i, col: col_i } if k == self.key
      end
    end
    return {row: -1, col: -1}
  end

  def battery_in_arena?
    return (@current_battery_position[:col] >= 0 && @current_battery_position[:row] >= 0)
  end

  def move_towards_battery_line(game_state, battery_position)
    if battery_in_arena?
      pos = @my_position
      row_diff = (pos[:row] - battery_position[:row]).abs
      col_diff = (pos[:col] - battery_position[:col]).abs
      if row_diff <= col_diff
        return (pos[:row] < battery_position[:row]) ? :down : :up
      else
        return (pos[:col] < battery_position[:col]) ? :right : :left
      end
    end
    return :nothing
  end

  def in_line_with_battery?(game_state, battery_position)
    return false unless battery_in_arena?
    pos = @my_position
    return (pos[:row] == battery_position[:row] || pos[:col] == battery_position[:col])
  end

  def battery_in_sights?(game_state, bot_info, battery_position)
    return false unless battery_in_arena?
    position_in_sights?(game_state, bot_info, battery_position)
  end

  def get_my_rotation(bot_info)
    bot_info[self.key][:rotation]
  end

  def move_towards_row_of_position(game_state, position)
    pos = @my_position
    return :nothing if position == nil || pos == nil
    if pos[:row] < position[:row]
      return :down
    elsif pos[:row] > position[:row]
      return :up
    end
    return :nothing
  end

  def move_towards_position(game_state, position)
    pos = @my_position
    return :nothing if position == nil || pos == nil
    choose_from = []
    if pos[:row] < position[:row]
      choose_from << :down
    elsif pos[:row] > position[:row]
      choose_from << :up
    end

    if pos[:col] < position[:col]
      choose_from << :right
    elsif pos[:col] > position[:col]
      choose_from << :left
    end
    action = choose_from.sample
    if direction_blocked?(game_state, pos, action)
      action = unblocked_directions(game_state, pos).sample
    end
    return :nothing if action == nil
    return action
  end

  def unblocked_directions(game_state, pos)
    output = []
    [:up, :down, :left, :right].each do |dir|
      output << dir if !direction_blocked?(game_state, pos, dir)
    end
    return output
  end

  def direction_blocked?(game_state, start_position, action)
    target_cell = { row: start_position[:row], col: start_position[:col] }
    case action
    when :up
      target_cell[:row] -= 1
    when :down
      target_cell[:row] += 1
    when :left
      target_cell[:col] -= 1
    when :right
      target_cell[:col] += 1
    end
    target_row = game_state[target_cell[:row]]
    return true if target_row == nil
    return true if (target_cell[:col] < 0 || target_cell[:col] > (game_state[0].length - 1))
    target_key = target_row[target_cell[:col]]
    return target_key != nil
  end

  def move_towards_same_row_as_closest_enemy(game_state, bot_info)
    enemy_position = get_position_of_closest_enemy
    move_towards_row_of_position(game_state, enemy_position)
  end

  def turn_towards_enemy(game_state, bot_info)
    enemy_position = get_position_of_closest_enemy_on_same_row(game_state)
    move_towards_position(game_state, enemy_position)
  end

  def move_towards_closest_enemy(game_state, bot_info)
    enemy_position = get_position_of_closest_enemy
    move_towards_position(game_state, enemy_position)
  end

  def get_position_of_closest_enemy_on_same_row(game_state)
    pos = @my_position
    enemy_positions = get_enemy_positions(game_state)
    min_pos = {row: -1, col: -1}
    min_distance = 1000
    enemy_positions.each do |enemy_pos|
      if enemy_pos[:row] == pos[:row]
        row_diff = (enemy_pos[:row] - pos[:row])
        col_diff = (enemy_pos[:col] - pos[:col])
        distance = Math.sqrt((row_diff**2) + (col_diff**2))
        if distance < min_distance
          min_distance = distance
          min_pos = enemy_pos
        end
      end
    end
    return min_pos
  end

  def get_position_of_closest_enemy
    pos = @my_position
    game_state = @current_game_state
    enemy_positions = get_enemy_positions(game_state)
    min_pos = {row: -1, col: -1}
    min_distance = 1000
    enemy_positions.each do |enemy_pos|
      row_diff = (enemy_pos[:row] - pos[:row])
      col_diff = (enemy_pos[:col] - pos[:col])
      distance = Math.sqrt((row_diff**2) + (col_diff**2))
      if distance < min_distance
        min_distance = distance
        min_pos = enemy_pos
      end
    end
    return min_pos
  end

  def on_same_row_as_enemy?(game_state, bot_info)
    pos = @my_position
    enemy_positions = get_enemy_positions(game_state)
    enemy_positions.each do |enemy_pos|
      return enemy_pos if (pos[:row] == enemy_pos[:row])
    end
    return false
  end

  def on_same_col_as_enemy?(game_state, bot_info)
    pos = @my_position
    enemy_positions = get_enemy_positions(game_state)
    enemy_positions.each do |enemy_pos|
      return enemy_pos if (pos[:col] == enemy_pos[:col])
    end
    return false
  end

  def in_line_with_enemy?(game_state, bot_info)
    return (
      on_same_row_as_enemy?(game_state, bot_info) ||
      on_same_col_as_enemy?(game_state, bot_info)
    )
  end

  def facing_enemy?(game_state, bot_info)
    enemy_in_sights?(game_state, bot_info)
  end

  def enemy_in_sights?(game_state, bot_info)
    enemy_positions = get_enemy_positions(game_state)
    enemy_positions.each do |enemy_pos|
      return true if position_in_sights?(game_state, bot_info, enemy_pos)
    end
    return false
  end

  def battery_closer_than_any_enemies?
    return distance_to_battery <= distance_to_closest_enemy
  end

  def distance_to_battery
    return 100 unless battery_in_arena?
    distance_between_positions(@my_position, @current_battery_position)
  end

  def distance_to_closest_enemy
    enemy_position = get_position_of_closest_enemy
    distance_between_positions(@my_position, enemy_position)
  end

  def distance_between_positions(position1, position2)
    row_diff = (position1[:row] - position2[:row])
    col_diff = (position1[:col] - position2[:col])
    Math.sqrt((row_diff**2) + (col_diff**2)).round
  end

  def position_in_sights?(game_state, bot_info, position)
    pos = @my_position
    rot = get_my_rotation(bot_info)
    if pos[:row] == position[:row]
      if pos[:col] < position[:col]
        return true if rot == 0
      elsif pos[:col] > position[:col]
        return true if rot == 180
      end
    elsif pos[:col] == position[:col]
      if pos[:row] < position[:row]
        return true if rot == 90
      elsif pos[:row] > position[:row]
        return true if rot == 270
      end
    end
    return false
  end

  def get_enemy_positions(game_state)
    enemies = []
    game_state.each_with_index do |row, row_i|
      row.each_with_index do |k, col_i|
        enemies << {row: row_i, col: col_i } if (k != nil && k != self.key)
      end
    end
    return enemies
  end

  def move_towards_left_wall
    target_position = {row: (@current_game_state.length / 2).round, col: 0}
    move_towards_position(@current_game_state, target_position)
  end

  def move_towards_right_wall
    target_position = {row: (@current_game_state.length / 2).round, col: (@current_game_state[0].length - 1)}
    move_towards_position(@current_game_state, target_position)
  end

  def just_fired?
    @last_action == :shoot
  end

  def just_moved_along_column?
    (@last_action == :up || @last_action == :down)
  end

  def against_left_wall?
    @my_position[:col] == 0
  end

  def against_right_wall?
    @my_position[:col] == (@current_game_state[0].length - 1)
  end

  def against_top_wall?
    @my_position[:row] == 0
  end

  def against_bottom_wall?
    @my_position[:row] == (@current_game_state.length - 1)
  end

  def close_to_left_wall?
    @my_position[:col] <= 1
  end

  def close_to_right_wall?
    @my_position[:col] >= (@current_game_state[0].length - 2)
  end

  def facing_right?
    @my_rotation == 0
  end

  def facing_left?
    @my_rotation == 180
  end

  def facing_up?
    @my_rotation == 270
  end

  def facing_down?
    @my_rotation == 90
  end

end
