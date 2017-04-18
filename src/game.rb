require 'gosu'
require_relative './lib/fence'



class Tanks < Gosu::Window
  GAME_WIDTH = 960
  GAME_HEIGHT = 720
  TILE_SIZE = 78

  def initialize
    super GAME_WIDTH, GAME_HEIGHT
    self.caption = "Udaci-Tanks!"
    @background_image = Gosu::Image.new("assets/background_scaled.jpg", tileable: true)
    @fence = Fence.new(Gosu::Image.new("assets/wall.png", tileable: true), TILE_SIZE)
    @tank = Gosu::Image.new("assets/tank_purple.png")
  end

  def update
  end

  def draw
    @background_image.draw(0,0,0)
    @fence.draw
    @tank.draw(160, 200, 2, 1.5, 1.5)
    #@tank.draw(160 + TILE_SIZE, 200, 2, 1.5, 1.5)
    @tank.draw_rot(160 + TILE_SIZE, 200, 2, 90, 0.5, 0.5, 1.5, 1.5)
  end
end

Tanks.new.show
