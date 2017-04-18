require 'securerandom'

class RandomBot
  attr_reader :image, :key

  def initialize(input_image)
    @image = input_image
    @key = SecureRandom.uuid
  end

end
