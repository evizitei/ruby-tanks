require_relative './qbot'

# Trained in 1:1 matches against qbot
class BoringQbot < Qbot
  WEIGHTS_FILE_NAME = "weights/boring_qbot_weights.json"

  def new_epoch!
    @last_energies = nil
    file = File.new(WEIGHTS_FILE_NAME, "w")
    file.write(@q_matrix.to_json)
    file.close
  end

  def name
    "BoringQbot"
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

  def load_saved_weights
    if @from_the_top
      initialize_q_states
    else
      begin
        json = IO.read(WEIGHTS_FILE_NAME)
        weights = symbolize_keys(JSON.parse(json))
        puts("LOADED #{weights.inspect}")
        return weights
      rescue Errno::ENOENT
        return initialize_q_states
      end
    end
  end

end
