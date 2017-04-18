require 'gosu'

class Tanks < Gosu::Window
  def initialize
    super 960, 720
    self.caption = "Udaci-Tanks!"
    @background_image = Gosu::Image.new("assets/background_scaled.jpg", tileable: true)
  end

  def update
  end

  def draw
    @background_image.draw(0,0,0)
  end
end

Tanks.new.show
