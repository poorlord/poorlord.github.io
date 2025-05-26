pico-8 cartridge // http://www.pico-8.com
__lua__

-- Content from init.lua
function _init()
  -- Globals & Tunables
  num_dogs=3
  pack_dx=12
  handler_x,ground_y=20,96
  scroll_speed=0.5
  stripe_w=8

  pull_chance=0.02
  escape_speed=0.4
  tension_rate=0.5
  tension_max=90
  calm_drain=0.3

  warn_dur=45
  warn_h=8
  interval_min=240
  interval_max=600
  tug_strength=12

  -- Player state (mostly static, using handler_x and ground_y)
  -- No separate player table for now, can be added if needed

  -- Dog states
  dogs = {}
  for i=1,num_dogs do
    dogs[i] = {
      x = handler_x + (i-1) * pack_dx, -- Initial x relative to handler
      y = ground_y,                   -- Initial y
      tension = 0,                    -- Initial tension
      state = "calm",                 -- Initial state
      -- Random initial timer for "calm" state interval
      state_timer = flr(rnd(interval_max - interval_min + 1)) + interval_min,
      sprite = 20 + (i-1)*2,          -- Sprite based on index
      visual_y_offset = 0,            -- For visual effects like hopping
      active = true                   -- Dog is initially active
    }
  end

  -- Score
  score = 0

  -- Game timer
  game_timer = 0 -- Using a custom timer, time() might be for wall clock

  -- Selected dog
  selected_dog_idx = 1

  -- Game over state
  game_over = false

  -- Parallax scrolling offsets
  sky_offset = 0
  sidewalk_offset = 0

  -- Start background music (pattern 0, looping)
  music(0)
end

-- Content from update.lua
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

-- Content from draw.lua
-- draw.lua

-- Helper function to draw the parallaxing sky
local function draw_sky()
  local sky_tile_w = 32 -- Each building sprite is 16px wide, but they are tiled every 32px
  local num_tiles_to_cover_screen = flr(128 / sky_tile_w) + 1 -- Number of 32px slots
  local pattern_width = (num_tiles_to_cover_screen + 1) * sky_tile_w -- Add one more tile for smoother wrapping

  for i = 0, num_tiles_to_cover_screen do
    local base_x_in_pattern = i * sky_tile_w
    local current_x_on_screen = base_x_in_pattern - flr(sky_offset)
    
    -- Modulo arithmetic to wrap buildings around
    current_x_on_screen = (current_x_on_screen % pattern_width + pattern_width) % pattern_width
    
    -- If a building is partially off-screen to the left due to the initial modulo result,
    -- ensure it's drawn correctly by potentially drawing it further to the right if it wrapped "too early".
    -- This is typically handled if pattern_width is larger than screen_width + tile_width.
    -- The current pattern_width calculation should be sufficient.

    -- Sprite 64 is 16x16px (2x2 tiles of 8x8).
    -- It's drawn at ground_y - 32 (so its bottom aligns with ground_y - 16, assuming sprite anchor is top-left)
    -- The spec says "y=ground_y-32 to touch the sidewalk". If sidewalk is at ground_y, and building is 16px tall, this means its top is at ground_y-32.
    -- Let's assume sprite 64 is 16px tall.
    spr(64, current_x_on_screen, ground_y - 32, 2, 2) -- Using 2,2 for 16x16px sprite
  end
end

-- Helper function to draw the ground and sidewalk
local function draw_ground()
  -- Sidewalk base color (dark grey)
  rectfill(0, ground_y, 127, 127, 5)

  local stripe_color = 6 -- Light grey stripes (color index 6)
  
  -- Draw scrolling horizontal stripes on the sidewalk
  -- The sidewalk area is from y = ground_y to y = 127.
  -- stripe_w is the distance between stripes.
  for y_screen = ground_y, 127 do
    -- Calculate the "effective" y position in the stripe pattern relative to the start of the sidewalk.
    -- Add sidewalk_offset to make the pattern scroll.
    -- As sidewalk_offset increases, lines appear to move downwards.
    local y_relative_to_sidewalk_top = y_screen - ground_y
    local y_in_pattern = y_relative_to_sidewalk_top + flr(sidewalk_offset)
    
    if y_in_pattern % stripe_w == 0 then
      line(0, y_screen, 127, y_screen, stripe_color)
    end
  end
end

-- Helper function to draw the player
local function draw_player()
  -- Player sprite is 32x64px. Sprite 0 is top-left 8x8 tile.
  -- It's 4 tiles wide (4*8=32px) and 8 tiles high (8*8=64px).
  -- Anchor is top-left. handler_x-16 centers it. ground_y-24 places feet near ground.
  spr(0, handler_x - 16, ground_y - 24, 4, 8)
end

-- Helper function to draw dogs and their leashes
local function draw_dogs_and_leashes()
  if dogs == nil then return end -- Guard against dogs not being initialized

  for i = 1, num_dogs do
    local d = dogs[i]
    if d and d.active then -- Only draw if dog exists and is active
      local current_dog_y_base = d.y - (d.visual_y_offset or 0)

      -- Draw dog sprite (16x16px, so 2x2 tiles)
      -- d.x is the dog's absolute screen x-coordinate.
      -- current_dog_y_base is the effective y for the dog's feet.
      -- Sprite anchor is top-left, so offset by half width/height for centering.
      -- Original was d.y - 8; now it's current_dog_y_base - 8.
      spr(d.sprite, d.x - 8, current_dog_y_base - 8, 2, 2)

      -- Determine leash color based on tension and selection
      local leash_col = 7 -- Default light grey

      if d.tension >= tension_max * 0.99 then -- Check for max tension first (most critical)
        leash_col = 8 -- Red
      elseif d.tension > tension_max * 0.66 then
        leash_col = 10 -- Orange
      elseif d.tension > tension_max * 0.33 then
        leash_col = 9 -- Yellow
      elseif i == selected_dog_idx then
        leash_col = 12 -- Blue (for selected dog, if not under high tension)
      end
      
      -- Player's hand approx (handler_x, ground_y-16)
      -- Dog's neck approx (d.x, current_dog_y_base - 4, slightly above center of sprite)
      line(handler_x, ground_y - 16, d.x, current_dog_y_base - 4, leash_col)
    end
  end
end

-- Helper function to draw UI elements
local function draw_ui()
  -- Display score
  print("score: " .. (score or 0), 2, 2, 7) -- White text, default score to 0 if nil

  -- Display Game Over message if applicable
  if game_over then
    local msg = "leash snapped! retry"
    -- Pico-8 default font chars are approx 4px wide (3px char + 1px space)
    local text_width = #msg * 4 
    print(msg, 64 - text_width / 2, 60, 8) -- Red text, centered
  end
end

-- Main _draw function, called every frame
function _draw()
  cls(0) -- Clear screen with black (color 0)
  
  -- Draw layers in order from back to front
  draw_sky()
  draw_ground()
  draw_player()
  draw_dogs_and_leashes()
  draw_ui()
end
