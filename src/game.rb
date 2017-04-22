require 'gosu'
require_relative './lib/fence'
require_relative './lib/arena'
require_relative './lib/bots/random_bot'
require_relative './lib/bots/circle_bot'
require_relative './lib/bots/bella_bot'
require_relative './lib/bots/boring_bot'
require_relative './lib/bots/battle_bot'
require_relative './lib/bots/dodge_bot'
require_relative './lib/bots/battery_bot'
require_relative './lib/bots/user_bot'
require_relative './lib/bots/camper_bot'
require_relative './lib/bots/hunter_bot'
require_relative './lib/bots/saturate_bot'
require_relative './lib/bots/gratification_bot'
require_relative './lib/qbots/boring_qbot'
require_relative './lib/qbots/battery_qbot'

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
  GAME_TICK = 200
  # enable for q-learning
  IN_TRAINING = true
  LEARNING_EPOCHS = 1000
  LEARNING_TICK = 0

  def initialize
    super GAME_WIDTH, GAME_HEIGHT
    self.caption = "Udaci-Tanks!"
    @background_image = Gosu::Image.new("assets/background_scaled.jpg", tileable: true)
    @fence = Fence.new(Gosu::Image.new("assets/wall.png", tileable: true), TILE_SIZE)
    bots = [
      #BoringBot.new(GREEN_IMAGES),
      #BellaBot.new(PURPLE_IMAGES),
      #UserBot.new(BLUE_IMAGES),
      #RandomBot.new(GREEN_IMAGES),
      #DodgeBot.new(BLUE_IMAGES),
      #CircleBot.new(BLUE_IMAGES),
      #CamperBot.new(GREEN_IMAGES),
      BatteryBot.new(GREEN_IMAGES),
      #BattleBot.new(RED_IMAGES),
      #HunterBot.new(BLUE_IMAGES),
      #SaturateBot.new(RED_IMAGES),
      #GratificationBot.new(RED_IMAGES),
      #BoringQbot.new(PURPLE_IMAGES),
      BatteryQbot.new(RED_IMAGES),
    ]
    @arena = Arena.new(bots, TILE_SIZE)
    if IN_TRAINING
      @arena.setup_learning!(LEARNING_EPOCHS)
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
    else
      if current_tick - @last_tick > GAME_TICK
        @arena.tick
        @last_tick = current_tick
      end
    end
  end

  def draw
    @background_image.draw(0,0,0)
    @fence.draw
    @arena.render
  end

end

Tanks.new.show
