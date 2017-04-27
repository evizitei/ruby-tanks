require 'gosu'
require_relative './lib/fence'
require_relative './lib/arena'
require_relative './lib/bots/random_bot'
require_relative './lib/bots/circle_bot'
require_relative './lib/bots/bella_bot'
require_relative './lib/bots/bella2_bot'
require_relative './lib/bots/boring_bot'
require_relative './lib/bots/battle_bot'
require_relative './lib/bots/dodge_bot'
require_relative './lib/bots/battery_bot'
require_relative './lib/bots/user_bot'
require_relative './lib/bots/camper_bot'
require_relative './lib/bots/hunter_bot'
require_relative './lib/bots/saturate_bot'
require_relative './lib/bots/tripwire_bot'
require_relative './lib/bots/gratification_bot'
require_relative './lib/bots/scaredy_bot'
require_relative './lib/qbots/boring_qbot'
require_relative './lib/qbots/battery_qbot'
require_relative './lib/qbots/battle_qbot'
require_relative './lib/qbots/random_qbot'
require_relative './lib/qbots/hunter_qbot'
require_relative './lib/qbots/gratification_qbot'

require_relative './lib/bots/team_bot'

PURPLE_IMAGES = {
  standard: Gosu::Image.new("assets/tank_purple.png"),
  tagged: Gosu::Image.new("assets/tank_purple_tagged.png"),
  color_code: Gosu::Color::FUCHSIA
}

GREEN_IMAGES = {
  standard: Gosu::Image.new("assets/tank_green.png"),
  tagged: Gosu::Image.new("assets/tank_green_tagged.png"),
  color_code: Gosu::Color::GREEN
}

RED_IMAGES = {
  standard: Gosu::Image.new("assets/tank_red.png"),
  tagged: Gosu::Image.new("assets/tank_red_tagged.png"),
  color_code: Gosu::Color::RED
}

BLUE_IMAGES = {
  standard: Gosu::Image.new("assets/tank_blue.png"),
  tagged: Gosu::Image.new("assets/tank_blue_tagged.png"),
  color_code: Gosu::Color::AQUA
}

class Tanks < Gosu::Window
  GAME_WIDTH = 960
  GAME_HEIGHT = 720
  TILE_SIZE = 78
  GAME_TICK = 100

  # enable for q-learning
  IN_TRAINING = false
  LEARNING_EPOCHS = 20000
  LEARNING_TICK = 0
  # painting takes time, less painting takes less time, good for training
  DISPLAY_ENABLED = true

  # enable to gather statistics amongst a set of bots
  IN_STATS_MODE = false
  IN_STATS_WIDTH = GAME_WIDTH + 200
  IN_STATS_TICK = 0



  def initialize
    if IN_STATS_MODE
      super IN_STATS_WIDTH, GAME_HEIGHT
    else
      super GAME_WIDTH, GAME_HEIGHT
    end

    self.caption = "Udaci-Tanks!"
    @background_image = Gosu::Image.new("assets/background_scaled.jpg", tileable: true)
    @fence = Fence.new(Gosu::Image.new("assets/wall.png", tileable: true), TILE_SIZE)
    bots = [
      #BoringBot.new(GREEN_IMAGES),
      #BellaBot.new(GREEN_IMAGES),
      #Bella2Bot.new(PURPLE_IMAGES),
      #UserBot.new(BLUE_IMAGES),
      #RandomBot.new(RED_IMAGES),
      #DodgeBot.new(BLUE_IMAGES),
      #CircleBot.new(GREEN_IMAGES),
      #CamperBot.new(PURPLE_IMAGES),
      #BatteryBot.new(RED_IMAGES),
      #BattleBot.new(BLUE_IMAGES),
      HunterBot.new(GREEN_IMAGES),
      #TripwireBot.new(BLUE_IMAGES)
      #SaturateBot.new(PURPLE_IMAGES),
      #GratificationBot.new(GREEN_IMAGES),
      ScaredyBot.new(RED_IMAGES),
      #BoringQbot.new(BLUE_IMAGES),
      #BatteryQbot.new(GREEN_IMAGES),
      #BattleQbot.new(PURPLE_IMAGES),
      #RandomQbot.new(RED_IMAGES),
      #HunterQbot.new(BLUE_IMAGES),
      #GratificationQbot.new(GREEN_IMAGES),
      #GratificationQbot.new(RED_IMAGES),
      #TeamBot.new(BLUE_IMAGES)
    ]
    @arena = Arena.new(bots, TILE_SIZE)
    if IN_TRAINING
      @arena.setup_learning!(LEARNING_EPOCHS)
    elsif IN_STATS_MODE
      @arena.setup_stats!(bots)
    end

    @last_tick = 0
  end

  def update
    current_tick = Gosu.milliseconds
    if IN_TRAINING
      if current_tick - @last_tick > LEARNING_TICK
        @arena.tick
        @last_tick = current_tick
      end
    elsif IN_STATS_MODE
      if current_tick - @last_tick > IN_STATS_TICK
        @arena.tick
        @last_tick = current_tick
      end
    else
      if current_tick - @last_tick > GAME_TICK
        @arena.tick
        @last_tick = current_tick
      end
    end
  end

  def draw
    if DISPLAY_ENABLED
      @background_image.draw(0,0,0)
      @fence.draw
    end
    @arena.render(DISPLAY_ENABLED)
  end

end

Tanks.new.show
