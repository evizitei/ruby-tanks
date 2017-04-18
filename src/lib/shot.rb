require 'securerandom'

class Shot
  attr_reader :key, :image
  def initialize(image)
    @image = image
    @key = SecureRandom.uuid
  end
end
