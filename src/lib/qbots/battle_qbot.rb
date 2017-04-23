require 'json'
require_relative './qbot'

# Trained in 1:1 matches against BattleBot
class BattleQbot < Qbot
  WEIGHTS_FILE_NAME = "weights/battle_qbot_weights.json"

  def new_epoch!
    # no-op for non-learners
    @last_energies = nil
    file = File.new(WEIGHTS_FILE_NAME, "w")
    file.write(@q_matrix.to_json)
    file.close
  end

  def name
    "BattleQbot"
  end

  def weights_for_state(game_state, bot_info)
    # closer_to_bot? [yes, no]
    # best_direction_to_bot [up, down, left, right, nothing]
    # best_direction_to_battery [up, down, left, right, nothing]
    # bot in sights? [yes, no]
    # in_danger_from_sides [yes,no]
    # in_danger_from_column [yes,no]
    # action weights [none, up, down, left, right, shoot]
    key0 = battery_closer_than_any_enemies? ? :closer_to_battery : :closer_to_bot
    key1 = move_towards_closest_enemy(game_state, bot_info)
    key2 = move_towards_battery
    key3 = enemy_in_sights?(game_state, bot_info) ? :in_sights : :not_in_sights
    key4 = in_danger_from_sides?(game_state, @current_shots) ? :row_danger : :row_safe
    key5 = in_danger_from_column?(game_state, @current_shots) ? :col_danger : :col_safe
    return @q_matrix[key0][key1][key2][key3][key4][key5]
  end

  def initialize_q_states
    return {
      closer_to_battery: initialized_position_q_states,
      closer_to_bot: initialized_position_q_states
    }
  end

  def initialized_position_q_states
    {
      up: initialized_directions_to_sights_hash,
      down: initialized_directions_to_sights_hash,
      left: initialized_directions_to_sights_hash,
      right: initialized_directions_to_sights_hash,
      nothing: initialized_directions_to_sights_hash,
    }
  end

  def initialized_directions_to_sights_hash
    {
      up: initialized_sights_hash,
      down: initialized_sights_hash,
      left: initialized_sights_hash,
      right: initialized_sights_hash,
      nothing: initialized_sights_hash
    }
  end

  def initialized_sights_hash
    {
      in_sights: initialized_in_danger_hash,
      not_in_sights: initialized_in_danger_hash
    }
  end

  def initialized_in_danger_hash
    {
      row_danger: {
        col_danger: zerod_action_weights,
        col_safe: zerod_action_weights
      },
      row_safe: {
        col_danger: zerod_action_weights,
        col_safe: zerod_action_weights
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
