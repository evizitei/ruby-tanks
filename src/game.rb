require 'gosu'
require_relative './lib/fence'
require_relative './lib/arena'
require_relative './lib/bots/random_bot'



class Tanks < Gosu::Window
  GAME_WIDTH = 960
  GAME_HEIGHT = 720
  TILE_SIZE = 78
  GAME_TICK = 1200

  def initialize
    super GAME_WIDTH, GAME_HEIGHT
    self.caption = "Udaci-Tanks!"
    @background_image = Gosu::Image.new("assets/background_scaled.jpg", tileable: true)
    @fence = Fence.new(Gosu::Image.new("assets/wall.png", tileable: true), TILE_SIZE)
    bots = [
      RandomBot.new(Gosu::Image.new("assets/tank_purple.png")),
      RandomBot.new(Gosu::Image.new("assets/tank_green.png")),
      RandomBot.new(Gosu::Image.new("assets/tank_purple.png")),
      RandomBot.new(Gosu::Image.new("assets/tank_green.png")),
      RandomBot.new(Gosu::Image.new("assets/tank_purple.png")),
      RandomBot.new(Gosu::Image.new("assets/tank_green.png"))
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
