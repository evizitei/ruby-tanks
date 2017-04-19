require_relative './base_bot'

# Priorizes shooting at tanks, moves if no tank to shoot
class HunterBot < BaseBot

  def choose_action(game_state, bot_info, shots, battery_position)
    return :shoot if enemy_in_sights?(game_state, bot_info)
    enemy_pos = in_line_with_enemy?(game_state, bot_info)
    if enemy_pos
      return move_towards_position(game_state, enemy_pos)
    else
      return move_towards_closest_enemy(game_state, bot_info)
    end
  end

  def name
    "HunterBot"
  end

  protected
  def move_towards_position(game_state, position)
    pos = get_my_position(game_state)
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
    return :nothing if action == nil
    return action
  end

  def move_towards_closest_enemy(game_state, bot_info)
    enemy_position = get_position_of_closest_enemy(game_state)
    move_towards_position(game_state, enemy_position)
  end

  def get_position_of_closest_enemy(game_state)
    pos = get_my_position(game_state)
    enemy_positions = get_enemy_positions(game_state)
    min_pos = {row: -1, col: -1}
    min_distance = 1000
    enemy_positions.each do |enemy_pos|
      row_diff = (enemy_pos[:row] - pos[:row])
      col_diff = (enemy_pos[:col] - pos[:col])
      distance = Math.sqrt((row_diff^2) + (col_diff^2))
      if distance < min_distance
        min_distance = distance
        min_pos = enemy_pos
      end
    end
    return min_pos
  end

  def in_line_with_enemy?(game_state, bot_info)
    pos = get_my_position(game_state)
    enemy_positions = get_enemy_positions(game_state)
    enemy_positions.each do |enemy_pos|
      return enemy_pos if (pos[:row] == enemy_pos[:row] || pos[:col] == enemy_pos[:col])
    end
    return false
  end

  def enemy_in_sights?(game_state, bot_info)
    pos = get_my_position(game_state)
    rot = get_my_rotation(bot_info)
    enemy_positions = get_enemy_positions(game_state)
    enemy_positions.each do |enemy_pos|
      if pos[:row] == enemy_pos[:row]
        if pos[:col] < enemy_pos[:col]
          return true if rot == 0
        elsif pos[:col] > enemy_pos[:col]
          return true if rot == 180
        end
      elsif pos[:col] == enemy_pos[:col]
        if pos[:row] < enemy_pos[:row]
          return true if rot == 90
        elsif pos[:row] > enemy_pos[:row]
          return true if rot == 270
        end
      end
    end
    return false
  end

  def get_enemy_positions(game_state)
    enemies = []
    state.each_with_index do |row, row_i|
      row.each_with_index do |k, col_i|
        enemies << {row: row_i, col: col_i } if k != self.key
      end
    end
    return enemies
  end
end
