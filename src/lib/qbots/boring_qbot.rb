require_relative '../bots/base_bot'

# Trained in 1:1 matches against qbot
class BoringQbot < BaseBot
  I_TO_ACTIONS = [:nothing, :up, :down, :left, :right, :shoot]

  def initialize(input_images)
    super(input_images)
    @exploration_rate = 0.9
    @exploration_decay = 0.000001
    @learning_rate = 0.3
    @discount_rate = 0.6
    @q_matrix = initialize_q_states
  end

  def new_epoch!
    # no-op for non-learners
    @last_energies = nil
    puts("EXPLORATION RATE: #{@exploration_rate}")
    puts(@q_matrix.inspect)
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

  def name
    "BoringQbot"
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
        energy_delta = 0 if energy_delta > 0 # don't want batteries to confound strategy
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

  def weights_for_state(game_state, bot_info)
    # bot in sights? [yes, no]
    # enemy_shortest_non_zero_direction_delta [up, down, left, right]
    # action weights [none, up, down, left, right, shoot]
    key0 = in_the_lead? ? :in_lead : :behind
    key1 = enemy_in_sights?(game_state, bot_info) ? :in_sights : :not_in_sights
    enemy_position = get_position_of_closest_enemy
    key2 = shortest_non_zero_diff(@my_position, enemy_position)
    return @q_matrix[key0][key1][key2]
  end

  def initialize_q_states
    return {
      in_lead: {
        in_sights: {
          up: zerod_action_weights,
          down: zerod_action_weights,
          left: zerod_action_weights,
          right: zerod_action_weights
        },
        not_in_sights: {
          up: zerod_action_weights,
          down: zerod_action_weights,
          left: zerod_action_weights,
          right: zerod_action_weights
        }
      },
      behind: {
        in_sights: {
          up: zerod_action_weights,
          down: zerod_action_weights,
          left: zerod_action_weights,
          right: zerod_action_weights
        },
        not_in_sights: {
          up: zerod_action_weights,
          down: zerod_action_weights,
          left: zerod_action_weights,
          right: zerod_action_weights
        }
      }
    }
  end

  def zerod_action_weights
    Array.new(6, 0)
  end

  def shortest_non_zero_diff(my_pos, enemy_pos)
    if my_pos[:row] == enemy_pos[:row]
      return (my_pos[:col] > enemy_pos[:col]) ? :left : :right
    elsif my_pos[:col] == enemy_pos[:col]
      return (my_pos[:row] > enemy_pos[:row]) ? :up : :down
    else
      row_diff = my_pos[:row] - enemy_pos[:row]
      col_diff = my_pos[:col] - enemy_pos[:col]
      if row_diff.abs < col_diff.abs
        return (row_diff < 0) ? :down : :up
      else
        return (col_diff < 0) ? :right : :left
      end
    end
  end

  def in_the_lead?
    leading = true
    @current_bots.each do |k, hash|
      if k != self.key && hash[:energy] > @my_energy
        leading = false
      end
    end
    return leading
  end

end
