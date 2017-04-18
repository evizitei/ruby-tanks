TILE_SIZE = 78
FENCE_SCALE = 0.8
OFFSET_X = -13
OFFSET_Y = 25

class Fence
  def initialize(image, x_tiles=13, y_tiles=8)
    @image = image
    @x_units = x_tiles
    @y_units = y_tiles
  end

  def draw
    draw_top
    draw_left
    draw_right
    draw_bottom
  end

  private
  def draw_top
    x = OFFSET_X
    @x_units.times do
      draw_tile(x, OFFSET_Y)
      x += TILE_SIZE
    end
  end

  def draw_left
    y = OFFSET_Y + TILE_SIZE
    (@y_units - 1).times do
      draw_tile(OFFSET_X, y)
      y += TILE_SIZE
    end
  end

  def draw_right
    x = (OFFSET_X + (TILE_SIZE * (@x_units - 1)))
    y = OFFSET_Y + TILE_SIZE
    (@y_units - 1).times do
      draw_tile(x, y)
      y += TILE_SIZE
    end
  end

  def draw_bottom
    x = OFFSET_X + TILE_SIZE
    y = (OFFSET_Y + (TILE_SIZE * (@y_units - 1)))
    (@x_units - 2).times do
      draw_tile(x, y)
      x += TILE_SIZE
    end
  end

  def draw_tile(x,y)
    @image.draw(x, y, 1, FENCE_SCALE, FENCE_SCALE)
  end
end
