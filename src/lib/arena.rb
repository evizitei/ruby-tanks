require_relative './shot'

class Arena
  TANK_Z = 2
  TANK_SCALE = 1.5
  TANK_CENTER = 0.5
  X_START = 104
  Y_START = 142
  TANK_START_ENERGY = 100.0

  def initialize(bots, tile_size, rows=6, columns=11)
    @bots = bots
    @keyed_bots = @bots.map{|b| [b.key, { bot: b, energy: TANK_START_ENERGY }] }.to_h
    @tile_size = tile_size
    @rows = rows
    @columns = columns
    @state = calculate_initial_positions
    @shot_image = Gosu::Image.new("assets/laser.png")
    @scoreboard_font = Gosu::Font.new(20)
    @shots = {}
    @pending_shots = []
  end

  def render
    @state.each_with_index do |row, row_i|
      row.each_with_index do |key, col_i|
        if nil != key
          bot_hash = @keyed_bots[key]
          draw_bot(bot_hash, row_i, col_i)
        end
      end
    end

    @shots.each do |key, hash|
      draw_shot(hash[:shot].image, hash[:row], hash[:col], hash[:rotation])
    end

    draw_scoreboard
  end

  def tick
    @new_state = generate_blank_state
    @bots.each do |bot|
      @keyed_bots[bot.key][:decision] = bot.choose_action(@state)
    end

    # MOVE TANKS
    @state.each_with_index do |row, row_i|
      row.each_with_index do |key, col_i|
        if nil != key
          bot_hash = @keyed_bots[key]
          if bot_hash[:tagged]
            # Nope, you're stuck now
            @new_state[row_i][col_i] = key
          else
            case bot_hash[:decision]
            when :left
              try_left(bot_hash, row_i, col_i)
            when :right
              try_right(bot_hash, row_i, col_i)
            when :up
              try_up(bot_hash, row_i, col_i)
            when :down
              try_down(bot_hash, row_i, col_i)
            when :shoot
              try_shoot(bot_hash, row_i, col_i)
            else
              puts("DON'T KNOW THIS ACTION: #{bot_hash[:decision]}")
            end
          end
        end
      end
    end

    @state = @new_state

    # MOVE EXISTING SHOTS
    @shots.each do |key, hash|
      move_shot(hash)
    end

    # PLACE NEW SHOTS
    @pending_shots.each do |shot_hash|
      target_key = @state[shot_hash[:row]][shot_hash[:col]]
      if nil != target_key # tank hit
        bot_hash = @keyed_bots[target_key]
        bot_hash[:tagged] = true
      else
        @shots[shot_hash[:shot].key] = shot_hash
      end
    end
    @pending_shots = []
  end

  private

  LABEL_WIDTH = 160
  def draw_scoreboard
    y = 680
    x = X_START

    @keyed_bots.each do |k, hash|
      label = "#{hash[:bot].name}: #{hash[:energy]}"
      @scoreboard_font.draw(label, x, y, 3)
      x += LABEL_WIDTH
    end
  end

  def draw_bot(bot_hash, row, col)
    rotation = bot_hash[:rotation]
    x = X_START + (col * @tile_size)
    y = Y_START + (row * @tile_size)
    img = bot_hash[:bot].image(bot_hash[:tagged])
    img.draw_rot(x, y, TANK_Z, rotation, TANK_CENTER, TANK_CENTER, TANK_SCALE, TANK_SCALE)
  end

  def draw_shot(image, row, col, rotation)
    x = X_START + (@tile_size * col)
    y = Y_START + (@tile_size * row)
    image.draw_rot(x,y,1, rotation, 0.5, 0.5, 0.6, 0.8)
  end

  def move_shot(shot_hash)
    target_row, target_col = process_shot_move(shot_hash)
    if target_row < 0 || target_col < 0 || target_row >= @rows || target_col >= @columns
      @shots.delete(shot_hash[:shot].key)
    else
      target_key = @state[shot_hash[:row]][shot_hash[:col]]
      if nil != target_key # tank hit
        bot_hash = @keyed_bots[target_key]
        bot_hash[:tagged] = true
        @shots.delete(shot_hash[:shot].key)
      else
        shot_hash[:row] = target_row
        shot_hash[:col] = target_col
      end
    end
  end

  def process_shot_move(shot_hash)
    case shot_hash[:rotation]
    when 0
      return shot_hash[:row], shot_hash[:col] + 1
    when 90
      return shot_hash[:row] + 1, shot_hash[:col]
    when 180
      return shot_hash[:row], shot_hash[:col] - 1
    when 270
      return shot_hash[:row] - 1, shot_hash[:col]
    end
  end

  def try_shoot(hash, row_i, col_i)
    @new_state[row_i][col_i] = hash[:bot].key
    target_row = row_i
    target_col = col_i
    case hash[:rotation]
    when 0
      target_col += 1
    when 90
      target_row += 1
    when 180
      target_col -= 1
    when 270
      target_row -= 1
    end
    add_shot(target_row, target_col, hash[:rotation])
  end

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

  def add_shot(row_i, col_i, rotation)
    return if row_i < 0 || row_i >= @rows
    return if col_i < 0 || col_i >= @columns
    new_shot = Shot.new(@shot_image)
    @pending_shots << { shot: new_shot, row: row_i, col: col_i, rotation: rotation }
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
