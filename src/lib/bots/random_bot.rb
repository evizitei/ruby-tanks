require 'securerandom'

class RandomBot
  ACTIONS=[:left, :up, :down, :right, :shoot]

  attr_reader :image, :key

  def initialize(input_image)
    @image = input_image
    @key = SecureRandom.uuid
  end

  def choose_action(game_state)
    ACTIONS.sample
  end

end
