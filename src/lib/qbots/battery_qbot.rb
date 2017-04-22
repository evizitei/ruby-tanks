require_relative './qbot'

# Trained in 1:1 matches against BatteryBot
class BatteryQbot < Qbot

  def name
    "BatteryQbot"
  end

  def weights_for_state(game_state, bot_info)
    # in the lead? [yes, no]
    # closer_to_bot? [yes, no]
    # best_direction_to_bot [up, down, left, right, nothing]
    # best_direction_to_battery [up, down, left, right, nothing]
    # bot in sights? [yes, no]
    # action weights [none, up, down, left, right, shoot]
    key0 = in_the_lead? ? :in_lead : :behind
    key1 = battery_closer_than_any_enemies? ? :closer_to_battery : :closer_to_bot
    key2 = move_towards_closest_enemy(game_state, bot_info)
    key3 = move_towards_battery
    key4 = enemy_in_sights?(game_state, bot_info) ? :in_sights : :not_in_sights
    return @q_matrix[key0][key1][key2][key3][key4]
  end

  def initialize_q_states
    return {
      in_lead: {
        closer_to_battery: initialized_position_q_states,
        closer_to_bot: initialized_position_q_states
      },
      behind: {
        closer_to_battery: initialized_position_q_states,
        closer_to_bot: initialized_position_q_states
      }
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
      in_sights: zerod_action_weights,
      not_in_sights: zerod_action_weights
    }
  end


  def load_saved_weights
    return initialize_q_states
    if @from_the_top
      initialize_q_states
    else
      initialize_q_states
    end
  end

end
