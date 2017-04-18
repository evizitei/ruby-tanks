require 'gosu'
require_relative './lib/fence'



class Tanks < Gosu::Window
  GAME_WIDTH = 960
  GAME_HEIGHT = 720

  def initialize
    super GAME_WIDTH, GAME_HEIGHT
    self.caption = "Udaci-Tanks!"
    @background_image = Gosu::Image.new("assets/background_scaled.jpg", tileable: true)
    @fence = Fence.new(Gosu::Image.new("assets/wall.png", tileable: true))
  end

  def update
  end

  def draw
    @background_image.draw(0,0,0)
    @fence.draw
  end
end

Tanks.new.show
