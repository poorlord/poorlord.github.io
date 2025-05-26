-- update.lua

-- Dog state machine functions

-- Called when a dog 'd' (with index 'dog_idx') is in the "calm" state.
function update_dog_calm(d, dog_idx)
  -- Gradually decrease tension
  d.tension = max(0, d.tension - calm_drain)

  -- Count down the timer for this state
  d.state_timer = (d.state_timer or 0) - 1

  if d.state_timer <= 0 then
    -- Time to check for a potential transition to "warning"
    if rnd(1) < pull_chance then
      d.state = "warning"
      d.state_timer = warn_dur
      d.visual_y_offset = 0 -- Ensure it's reset
      sfx(0) -- Bark sound once on entering warning state
    else
      -- Remain calm, reset timer for another calm interval
      d.state_timer = flr(rnd(interval_max - interval_min + 1)) + interval_min
    end
  end
end

-- Called when a dog 'd' (with index 'dog_idx') is in the "warning" state.
function update_dog_warning(d, dog_idx)
  -- Implement hopping visual effect
  -- Hops every 15 frames: up for 7.5 frames, down for 7.5 frames.
  -- (warn_dur - d.state_timer) is elapsed time in warning state.
  local time_in_warning = warn_dur - d.state_timer
  if (time_in_warning % 15) < 7.5 then
    d.visual_y_offset = warn_h
  else
    d.visual_y_offset = 0
  end
  -- Note: The problem description suggested `((d.state_timer % 15) < 7.5)`.
  -- Using `time_in_warning` makes the hop start consistently when entering the state.

  -- Count down the timer for this state
  d.state_timer = (d.state_timer or 0) - 1

  if d.state_timer <= 0 then
    -- Warning period over, transition to "pulling"
    d.state = "pulling"
    d.tension = 0 -- Tension starts building fresh in "pulling" state
    d.state_timer = 0 -- Pulling state doesn't use a timer in this design
    d.visual_y_offset = 0 -- Reset hop effect
  end
end

-- Called when a dog 'd' (with index 'dog_idx') is in the "pulling" state.
function update_dog_pulling(d, dog_idx)
  -- Dog moves away from the player
  d.x = d.x + escape_speed

  -- Tension increases
  d.tension = d.tension + tension_rate

  -- Check for escape
  if d.tension >= tension_max then
    d.tension = tension_max -- Clamp at max
    d.state = "escaped"
    -- sfx(5) -- Optional: specific sound for leash snap, if available/desired
               -- Main game over sound sfx(4) is handled in _update's global check
  end
end

-- Called when a dog 'd' (with index 'dog_idx') is in the "escaped" state.
function update_dog_escaped(d, dog_idx)
  -- Mark the dog as inactive (will affect drawing and potentially other logic)
  d.active = false 
  d.visual_y_offset = 0 -- Ensure any visual effects are reset

  -- The main _update loop will detect d.active == false or d.state == "escaped"
  -- and set game_over = true. sfx(4) is played there.
end


-- Main _update function, called every frame
function _update()
  -- 1. Handle Game Over
  if game_over then
    if btnp(0) or btnp(1) then -- Z or X to restart
      if _init then _init() end -- Call global _init to reset game
      return -- Skip rest of update
    end
    return -- If game_over and no restart, halt updates
  end

  -- 2. Increment Timers
  game_timer = (game_timer or 0) + 1

  -- 3. Background Scrolling
  -- Offsets increase indefinitely; drawing functions use modulo to tile
  sky_offset = (sky_offset or 0) + scroll_speed / 2
  sidewalk_offset = (sidewalk_offset or 0) + scroll_speed

  -- 4. Player Input
  local x_button_pressed = btnp(1) -- Store X button press for this frame

  if btnp(0) then -- Z key for cycling selected dog
    selected_dog_idx = (selected_dog_idx or 1) + 1
    if selected_dog_idx > num_dogs then
      selected_dog_idx = 1
    end
    sfx(3) -- Dog-select click sound
  end

  -- 5. Update Dog States
  if dogs then
    for i = 1, num_dogs do
      local d = dogs[i]
      if d then
        if d.state == "calm" then
          update_dog_calm(d, i)
        elseif d.state == "warning" then
          update_dog_warning(d, i)
        elseif d.state == "pulling" then
          update_dog_pulling(d, i)
        elseif d.state == "escaped" then
          update_dog_escaped(d, i)
        end
      end
    end
  end

  -- 6. Tug Mechanics
  if x_button_pressed then
    local dog_idx_to_tug = selected_dog_idx
    if dogs and dogs[dog_idx_to_tug] then
      local d = dogs[dog_idx_to_tug]
      if d.state == "pulling" then
        sfx(1) -- Tug press sound

        local default_pos_x = handler_x + (dog_idx_to_tug - 1) * pack_dx
        
        -- Reduce tension first
        d.tension = max(0, d.tension - tug_strength)

        -- Check if this tug brings the dog back to or behind its default position
        if (d.x - tug_strength) <= default_pos_x then
          -- Successful yank
          d.x = default_pos_x
          d.state = "calm"
          d.tension = 0 -- Reset tension fully on successful yank
          d.state_timer = flr(rnd(interval_max - interval_min + 1)) + interval_min
          sfx(2) -- Successful yank sound
          score = (score or 0) + 10
        else
          -- Just pulled, but not a full yank yet
          d.x = d.x - tug_strength
        end
      end
    end
  end

  -- 7. Scoring
  -- Add 1 point every 5 frames (assuming 30 FPS for 1 point per 1/6 second)
  if game_timer % 5 == 0 then
    score = (score or 0) + 1
  end

  -- 8. Game Progression
  -- Every 30 seconds (30 FPS * 30 seconds = 900 frames)
  if game_timer > 0 and game_timer % 900 == 0 then
    pull_chance = (pull_chance or 0.02) + 0.005
    escape_speed = (escape_speed or 0.4) + 0.05
    -- Potentially cap these values if desired
    -- pull_chance = min(pull_chance, max_pull_chance_cap)
    -- escape_speed = min(escape_speed, max_escape_speed_cap)
  end

  -- 9. Global Game Over Check
  -- This check is done after dog states are updated and tugs are processed.
  if dogs then
    for i = 1, num_dogs do
      if dogs[i] and dogs[i].state == "escaped" then
        game_over = true
        sfx(4) -- Game over sound effect (assuming sfx 4 is for this)
        break -- Exit loop once one dog has escaped
      end
    end
  end

end
