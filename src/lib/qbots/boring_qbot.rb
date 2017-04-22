require_relative '../bots/base_bot'

# Trained in 1:1 matches against qbot
class BoringQbot < BaseBot
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
    @exploration_rate = 0.5
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

  def load_saved_weights
    if @from_the_top
      initialize_q_states
    else
      {:in_lead=>{:in_sights=>{:up=>[330.60166048649336, 376.60208113998107, 153.69664010051252, 120.06860895864983, 83.21205875575096, 698.8022280523961], :down=>[289.67408914224796, 158.8642641357763, 342.58391751967287, 134.78078247050044, 195.76600008192202, 617.5892033313391], :left=>[321.2229606081871, 133.27976292534436, 123.4761074984913, 283.82626618347166, 174.30002261615192, 500.1702927298287], :right=>[227.42893285452416, 130.47303829140046, 187.92112452427736, 181.9659597862383, 215.31850629588223, 484.96506210825555]}, :not_in_sights=>{:up=>[101.2109946959358, 122.49945833150187, 105.56060516794263, 82.56660628738723, 60.142838890946834, 79.15377448664162], :down=>[60.483694895532835, 82.6419646287427, 229.32977731976112, 72.58391317958426, 69.76337698328393, 244.2247809705943], :left=>[112.57301331882644, 86.02763587090394, 70.43432964669336, 233.62333084141463, 123.18679983406156, 53.77457301324837], :right=>[131.73264794774417, 116.8468694685976, 102.94158179407675, 130.3008653023923, 173.12047355496958, 104.09844230201647]}}, :behind=>{:in_sights=>{:up=>[241.38190880771256, 335.0513860823769, 74.97988258410543, 128.21104065356886, 77.51411291503734, 266.7927067745159], :down=>[173.63296529192544, 101.33114388128139, 191.9337730169516, 121.27123889014428, 103.90912323490073, 270.9129599411338], :left=>[78.80438944213043, 73.4679302900169, 40.19532381310903, 60.90555923594132, 46.577772871636704, 207.24135051404332], :right=>[132.31921628315376, 69.9862720259351, 47.63116021978202, 120.09428144628524, 148.64194308833794, 211.87831963235413]}, :not_in_sights=>{:up=>[3.6439819253610795, 20.096122205712, 2.2244266298953947, 2.433996080173547, 2.0663579809159134, -6.427608694493459], :down=>[30.686511093521318, 31.900778576919173, 37.520351746070965, 19.525194626042715, 28.36359111410613, 18.362686397257484], :left=>[21.670362513024237, 28.7244812297081, 8.046730130644988, 33.76299034714473, 21.58301602254486, 21.03786404210478], :right=>[41.3862727880592, 41.605142601419324, 37.07675994143817, 113.06227484971147, 121.4335258845998, 34.19433437686203]}}}
    end
  end

end
