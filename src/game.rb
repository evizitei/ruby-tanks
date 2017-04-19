require 'gosu'
require_relative './lib/fence'
require_relative './lib/arena'
require_relative './lib/bots/random_bot'

PURPLE_IMAGES = {
  standard: Gosu::Image.new("assets/tank_purple.png"),
  tagged: Gosu::Image.new("assets/tank_purple_tagged.png"),
}

GREEN_IMAGES = {
  standard: Gosu::Image.new("assets/tank_green.png"),
  tagged: Gosu::Image.new("assets/tank_green_tagged.png"),
}

class Tanks < Gosu::Window
  GAME_WIDTH = 960
  GAME_HEIGHT = 720
  TILE_SIZE = 78
  GAME_TICK = 1000

  def initialize
    super GAME_WIDTH, GAME_HEIGHT
    self.caption = "Udaci-Tanks!"
    @background_image = Gosu::Image.new("assets/background_scaled.jpg", tileable: true)
    @fence = Fence.new(Gosu::Image.new("assets/wall.png", tileable: true), TILE_SIZE)
    bots = [
      RandomBot.new(PURPLE_IMAGES),
      RandomBot.new(GREEN_IMAGES)
      #YourBot.new(PURPLE_IMAGES) <- your bot goes here
    ]
    @arena = Arena.new(bots, TILE_SIZE)
    @last_tick = 0
  end

  def update
    current_tick = Gosu.milliseconds
    if current_tick - @last_tick > GAME_TICK
      @arena.tick
      @last_tick = current_tick
    end
  end

  def draw
    @background_image.draw(0,0,0)
    @fence.draw
    @arena.render
  end
end

Tanks.new.show
