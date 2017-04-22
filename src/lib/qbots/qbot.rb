require_relative '../bots/base_bot'

# base for other qbots
class Qbot < BaseBot
  I_TO_ACTIONS = [:nothing, :up, :down, :left, :right, :shoot]

  def initialize(input_images)
    super(input_images)
    @training = false
    @exploration_rate = 0.0
    @exploration_decay = 0.0
    @learning_rate = 0
    @discount_rate = 0
    @q_matrix = load_saved_weights
  end

  def new_epoch!
    # no-op for non-learners
    @last_energies = nil
    puts("EXPLORATION RATE: #{@exploration_rate}")
    puts(@q_matrix.inspect)
  end

  def enable_learning!
    @training = true
    @exploration_rate = 0.25
    @exploration_decay = 0.000001
    @learning_rate = 0.3
    @discount_rate = 0.6
  end

  def choose_action(game_state, bot_info, shots, battery_position)
    new_weights = weights_for_state(game_state, bot_info)
    if @last_energies
      reward = calculate_reward(bot_info, @last_energies)
      update_q_matrix(reward, @weights_to_update, new_weights)
    end
    @weights_to_update = new_weights
    if Random.rand < @exploration_rate
      @exploration_rate -= @exploration_decay
      return possible_actions.sample
    else
      best_actions = []
      current_weight = -100000
      new_weights.each_with_index do |weight, index|
        if weight > current_weight
          best_actions = [I_TO_ACTIONS[index]]
          current_weight = weight
        elsif weight == current_weight
          best_actions << I_TO_ACTIONS[index]
        end
      end
      return best_actions.sample
    end
  end

  def update_q_matrix(reward, weights_to_update, new_weights)
    max_new_value = new_weights.max
    action_index = I_TO_ACTIONS.index(@last_action)
    current_value = weights_to_update[action_index]
    learned_value = reward + (max_new_value * @discount_rate)
    new_q_value = current_value + ((learned_value - current_value) * @learning_rate)
    weights_to_update[action_index] = new_q_value
  end

  KILL_BONUS = 1000
  LEAD_BONUS = 5
  def calculate_reward(current_bots, prev_energies)
    reward = 0
    my_energy = current_bots[@key][:energy]
    current_bots.each do |key, hash|
      new_energy = hash[:energy]
      prev_energy = prev_energies[key]
      energy_delta = prev_energy - new_energy
      if new_energy <= 0 && prev_energy > 0
        energy_delta = KILL_BONUS
      end
      if key == @key
        energy_delta = (energy_delta * -1)
      else
        if my_energy > new_energy
          energy_delta += LEAD_BONUS
        else
          energy_delta -= LEAD_BONUS
        end
      end
      reward += energy_delta
    end
    return reward
  end

  def zerod_action_weights
    Array.new(6, 0)
  end

  def name
    raise "Implement in subclass"
  end

  def weights_for_state(game_state, bot_info)
    raise "Implement in subclass"
  end

  def initialize_q_states
    raise "Implement in subclass"
  end

  def load_saved_weights
    raise "Implement in subclass"
  end

end
