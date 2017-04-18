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

  private
  def x_for(column)
    X_START + (column * @tile_size)
  end

  def y_for(row)
    Y_START + (row * @tile_size)
  end

  def calculate_initial_positions
    state = Array.new(@rows){|_| Array.new(@columns, nil) }
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
end
