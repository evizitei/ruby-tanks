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
    @tank.draw_rot(260, 220, 2, 0, 0.5, 0.5, 1.5, 1.5)
    @tank.draw_rot(260 + TILE_SIZE, 220, 2, 90, 0.5, 0.5, 1.5, 1.5)
    @tank.draw_rot(260 + (TILE_SIZE * 2), 220, 2, 180, 0.5, 0.5, 1.5, 1.5)
    @tank.draw_rot(260 + (TILE_SIZE * 3), 220, 2, 270, 0.5, 0.5, 1.5, 1.5)
    #@tank.draw_rot(260, 224, 2, 90, 0.5, 0.5, 1.5, 1.5)
    #@tank.draw_rot(262, 224, 2, 180, 0.5, 0.5, 1.5, 1.5)
    #@tank.draw_rot(262, 224, 2, 270, 0.5, 0.5, 1.5, 1.5)

  end
end

Tanks.new.show
