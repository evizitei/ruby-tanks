class Arena
  TANK_Z = 2
  TANK_SCALE = 1.5
  TANK_CENTER = 0.5
  X_START = 104
  Y_START = 142

  def initialize(bots, tile_size, rows=6, columns=11)
    @bots = bots
    @keyed_bots = @bots.map{|b| [b.key, { bot: b }] }.to_h
    @tile_size = tile_size
    @rows = rows
    @columns = columns
    @state = calculate_initial_positions
  end

  def render
    @state.each_with_index do |row, row_i|
      row.each_with_index do |key, col_i|
        if nil != key
          bot_hash = @keyed_bots[key]
          rotation = bot_hash[:rotation]
          bot_hash[:bot].image.draw_rot(x_for(col_i), y_for(row_i), TANK_Z, rotation, TANK_CENTER, TANK_CENTER, TANK_SCALE, TANK_SCALE)
        end
      end
    end
  end

  def tick
    @new_state = generate_blank_state
    @bots.each do |bot|
      @keyed_bots[bot.key][:decision] = bot.choose_action(@state)
    end

    @state.each_with_index do |row, row_i|
      row.each_with_index do |key, col_i|
        if nil != key
          bot_hash = @keyed_bots[key]
          case bot_hash[:decision]
          when :left
            try_left(bot_hash, row_i, col_i)
          when :right
            try_right(bot_hash, row_i, col_i)
          when :up
            try_up(bot_hash, row_i, col_i)
          when :down
            try_down(bot_hash, row_i, col_i)
          else
            puts("DON'T KNOW THIS ACTION: #{bot_hash[:decision]}")
          end
        end
      end
    end

    @state = @new_state
  end

  private

  def try_left(hash, row_i, col_i)
    if col_i > 0 && nil == @state[row_i][col_i - 1] && nil == @new_state[row_i][col_i - 1]
      @new_state[row_i][col_i - 1] = hash[:bot].key
    else
      @new_state[row_i][col_i] = hash[:bot].key
    end
    hash[:rotation] = 180
  end

  def try_right(hash, row_i, col_i)
    if col_i < (@columns - 1) && nil == @state[row_i][col_i + 1] && nil == @new_state[row_i][col_i + 1]
      @new_state[row_i][col_i + 1] = hash[:bot].key
    else
      @new_state[row_i][col_i] = hash[:bot].key
    end
    hash[:rotation] = 0
  end

  def try_up(hash, row_i, col_i)
    if row_i > 0 && nil == @state[row_i - 1][col_i] && nil == @new_state[row_i - 1][col_i]
      @new_state[row_i - 1][col_i] = hash[:bot].key
    else
      @new_state[row_i][col_i] = hash[:bot].key
    end
    hash[:rotation] = 270
  end

  def try_down(hash, row_i, col_i)
    if row_i < (@rows - 1) && nil == @state[row_i + 1][col_i] && nil == @new_state[row_i + 1][col_i]
      @new_state[row_i + 1][col_i] = hash[:bot].key
    else
      @new_state[row_i][col_i] = hash[:bot].key
    end
    hash[:rotation] = 90
  end

  def x_for(column)
    X_START + (column * @tile_size)
  end

  def y_for(row)
    Y_START + (row * @tile_size)
  end

  def calculate_initial_positions
    state = generate_blank_state
    prng = Random.new
    @bots.each do |bot|
      @keyed_bots[bot.key][:rotation] = (prng.rand(4) * 90)
      placed = false
      while !placed do
        target_row = (prng.rand(@rows))
        target_column = (prng.rand(@columns))
        if nil == state[target_row][target_column]
          state[target_row][target_column] = bot.key
          placed = true
        end
      end
    end
    return state
  end

  def generate_blank_state
    Array.new(@rows){|_| Array.new(@columns, nil) }
  end
end
