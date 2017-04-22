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

  def load_saved_weights
    if @from_the_top
      initialize_q_states
    else
      {:in_lead=>{:in_sights=>{:up=>[455.50418159775086, 433.290013847527, 220.4333803984805, 116.27555306551072, 184.8165797306972, 761.5446434352459], :down=>[383.7773087685823, 198.61332152528664, 403.7598287618338, 141.5532410829213, 207.40812844332166, 710.481420204364], :left=>[364.0194218804541, 130.96157096513244, 202.99043435573557, 329.5512837114288, 310.7724918210629, 706.1142919877597], :right=>[259.1207162231888, 243.08533294842624, 155.7108927124106, 177.00350421753004, 243.97504117586655, 562.3369308916642]}, :not_in_sights=>{:up=>[132.04466238375795, 241.67042545723749, 93.3360341589509, 208.98349679358927, 101.67989067885739, 141.82178645452817], :down=>[101.194226589232, 49.58581038954303, 274.8662177687701, 91.50725741954825, 127.01430460680425, 68.16279244281594], :left=>[120.61917719078527, 100.94504822783071, 108.97851649127752, 241.87910590698405, 81.13409371722298, 126.08211701376837], :right=>[94.38383344108559, 107.55068249843391, 101.34162044930147, 103.17395339880125, 131.00294075494844, 76.25620421407474]}}, :behind=>{:in_sights=>{:up=>[323.3678185173423, 248.23695415236918, 165.95096063364892, 126.25149819361593, 118.54387678790326, 480.27586988728365], :down=>[297.93611863606907, 166.88969473895978, 261.0079242406904, 49.0929508577685, 65.84816768371397, 385.3477935712434], :left=>[57.19521018252522, 57.9874878606924, 132.56278554465086, 85.66154937005649, 42.338732560190614, 268.73603469655654], :right=>[37.635048727944564, 32.69024280552647, 87.19756053440379, 36.704752189139846, 41.02768423805075, 34.15203069358713]}, :not_in_sights=>{:up=>[34.443456178036584, 239.2661910006363, 33.780113340664364, 0.32566267772663693, 35.645294733838895, 21.278752936181633], :down=>[-7.004796261128478, 16.336164212035076, 191.80418062502352, -7.147274491902744, -7.091426194903591, -12.680973637925621], :left=>[4.476668750732994, 2.722388574444149, 3.3448764440711023, 123.11023195133176, 13.752691010376918, 2.902829174181349], :right=>[22.64517387615913, 25.26216936212076, 21.79620033845157, 18.538807635800374, 67.1362356006327, 25.6200629325254]}}}
    end
  end

end
