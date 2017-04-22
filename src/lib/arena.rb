require 'set'
require_relative './shot'

class Arena
  TANK_Z = 2
  TANK_SCALE = 1.5
  TANK_CENTER = 0.5
  X_START = 104
  Y_START = 142
  TANK_START_ENERGY = 1000
  BATTERY_DECAY = 1
  BATTERY_SPAWN_FRAMES = 3
  MOVE_COST = 2
  SHOOT_COST = 10
  HIT_COST = 150
  BATTERY_BOOST = 80

  def initialize(bots, tile_size, rows=6, columns=11)
    @bots = bots
    @tile_size = tile_size
    @rows = rows
    @columns = columns
    @shot_image = Gosu::Image.new("assets/laser.png")
    @battery_image = Gosu::Image.new("assets/battery.png")
    @scoreboard_font = Gosu::Font.new(20)
    @announcement_font = Gosu::Font.new(60)
    @epochs_left = 0

    reset_game!
  end

  def setup_learning!(epochs)
    @epochs_left = epochs
    @bots.each(&:enable_learning!)
  end

  def render
    if @winner
      @announcement_font.draw("#{@winner} wins!", 250, 300, 5)
    else

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
    end

    draw_battery
    draw_scoreboard
  end

  def tick
    if @winner
      if @epochs_left > 0
        puts("WINNER::{#{@winner}} (epochs #{@epochs_left})")
        @bots.each(&:new_epoch!)
        reset_game!
        @epochs_left -= 1
      elsif Gosu.button_down?(Gosu::KB_RETURN)
        reset_game!
      end
    else
      @new_state = generate_blank_state
      active_count = 0
      shot_data = @shots.map{|k,hash| {row: hash[:row], col: hash[:col], rotation: hash[:rotation]} }
      battery_data = { row: @battery_pos[:row], col: @battery_pos[:col]}

      @bots.each do |bot|
        hash = @keyed_bots[bot.key]
        active_count += 1 unless hash[:tagged]
        board_state = @state.map{|col| col.dup }
        bot_info = @keyed_bots.map{|k, h| [k, {energy: h[:energy], rotation: h[:rotation], tagged: h[:tagged]}] }.to_h
        hash[:decision] = bot.choose_bot_action(board_state, bot_info, shot_data.dup, battery_data.dup)
      end

      if active_count <= 1
        winner_bot = nil
        @keyed_bots.each do |k,hash|
          if !hash[:tagged]
            winner_bot = hash[:bot]
          end
        end
        if winner_bot
          @winner = winner_bot.name
        else
          @winner = "IT'S A TIE"
        end
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
              when :nothing
                @new_state[row_i][col_i] = key
                bot_hash[:energy] -= BATTERY_DECAY
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
          process_bot_shot(bot_hash, shot_hash[:shot].key)
        else
          @shots[shot_hash[:shot].key] = shot_hash
        end
      end
      @pending_shots = []

      cancel_overlapping_shots

      # process battery grabs
      battery_key = @state[@battery_pos[:row]][@battery_pos[:col]]
      if battery_in_arena? && battery_key != nil
        bot_hash = @keyed_bots[battery_key]
        bot_hash[:energy] += BATTERY_BOOST
        bot_hash[:energy] = TANK_START_ENERGY if bot_hash[:energy] > TANK_START_ENERGY

        @battery_countdown = BATTERY_SPAWN_FRAMES
        set_battery_position(clear: true)
      elsif @battery_countdown >= 0
        # reposition new battery after delay
        if @battery_countdown == 0
          set_battery_position
        end
        @battery_countdown -= 1
      end

      # Update Tagged state
      @keyed_bots.each do |key, bot_hash|
        bot_hash[:tagged] = (bot_hash[:energy] <= 0)
      end
    end
  end

  private

  def process_bot_shot(bot_hash, shot_key)
    bot_hash[:energy] -= HIT_COST
    bot_hash[:energy] = 0 if bot_hash[:energy] < 0
    @shots.delete(shot_key)
  end

  def reset_game!
    @keyed_bots = @bots.map{|b| [b.key, { bot: b, energy: TANK_START_ENERGY }] }.to_h
    @state = calculate_initial_positions
    @shots = {}
    @pending_shots = []
    @winner = nil
    @battery_countdown = -1
    set_battery_position
  end

  def cancel_overlapping_shots
    to_cancel =  Set.new

    @shots.each do |key, hash|
      row = hash[:row]
      col = hash[:col]
      @shots.each do |other_key, other_hash|
        if other_key != key
          if other_hash[:row] == row && other_hash[:col] == col
            to_cancel.add(key)
            to_cancel.add(other_key)
          end
        end
      end
    end

    to_cancel.each{|key| @shots.delete(key) }
  end

  def set_battery_position(clear: false)
    if clear
      @battery_pos = { row: -1, col: -1 }
    else
      prng = Random.new
      @battery_pos = { row: prng.rand(@rows), col: prng.rand(@columns) }
    end
  end

  def draw_battery
    if battery_in_arena?
      x = 86 + (@tile_size * @battery_pos[:col])
      y = 124 + (@tile_size * @battery_pos[:row])
      @battery_image.draw(x,y,3,0.5,0.5)
    end
  end

  def battery_in_arena?
    return (@battery_pos[:col] >= 0 && @battery_pos[:row] >= 0)
  end

  LABEL_WIDTH = 160
  def draw_scoreboard
    y = 680
    x = X_START

    @keyed_bots.each do |k, hash|
      label = "#{hash[:bot].name}: #{hash[:energy]}"
      @scoreboard_font.draw(label, x, y, 3, 1, 1, hash[:bot].color_code)
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
      target_key = @state[target_row][target_col]
      if nil != target_key # tank hit
        bot_hash = @keyed_bots[target_key]
        process_bot_shot(bot_hash, shot_hash[:shot].key)
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
    hash[:energy] -= SHOOT_COST
  end

  def try_left(hash, row_i, col_i)
    if col_i > 0 && nil == @state[row_i][col_i - 1] && nil == @new_state[row_i][col_i - 1]
      @new_state[row_i][col_i - 1] = hash[:bot].key
    else
      @new_state[row_i][col_i] = hash[:bot].key
    end
    hash[:rotation] = 180
    hash[:energy] -= MOVE_COST
  end

  def try_right(hash, row_i, col_i)
    if col_i < (@columns - 1) && nil == @state[row_i][col_i + 1] && nil == @new_state[row_i][col_i + 1]
      @new_state[row_i][col_i + 1] = hash[:bot].key
    else
      @new_state[row_i][col_i] = hash[:bot].key
    end
    hash[:rotation] = 0
    hash[:energy] -= MOVE_COST
  end

  def try_up(hash, row_i, col_i)
    if row_i > 0 && nil == @state[row_i - 1][col_i] && nil == @new_state[row_i - 1][col_i]
      @new_state[row_i - 1][col_i] = hash[:bot].key
    else
      @new_state[row_i][col_i] = hash[:bot].key
    end
    hash[:rotation] = 270
    hash[:energy] -= MOVE_COST
  end

  def try_down(hash, row_i, col_i)
    if row_i < (@rows - 1) && nil == @state[row_i + 1][col_i] && nil == @new_state[row_i + 1][col_i]
      @new_state[row_i + 1][col_i] = hash[:bot].key
    else
      @new_state[row_i][col_i] = hash[:bot].key
    end
    hash[:rotation] = 90
    hash[:energy] -= MOVE_COST
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
