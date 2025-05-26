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
