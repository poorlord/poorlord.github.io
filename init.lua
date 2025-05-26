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
