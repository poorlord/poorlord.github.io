# Pico-8 Dog-Walking Game - Conceptual Testing Guide

This guide outlines key areas to test to ensure the Pico-8 dog-walking game implements the specified features and mechanics correctly.

## 1. Initial State & Setup

*   **Global Variables:**
    *   Launch the game.
    *   (Developer) Inspect/confirm that core global variables are initialized as per the specification (e.g., `num_dogs = 3`, `handler_x = 20`, `ground_y = 96`, `scroll_speed = 0.5`, `pack_dx = 12`, `pull_chance = 0.02`, `escape_speed = 0.4`, `tension_rate = 0.5`, `tension_max = 90`, `calm_drain = 0.3`, `warn_dur = 45`, `warn_h = 8`, `interval_min = 240`, `interval_max = 600`, `tug_strength = 12`).
*   **Player Sprite:**
    *   Verify the player sprite is drawn at its correct initial position (`handler_x - 16`, `ground_y - 24`).
*   **Dogs Initial State:**
    *   Confirm `num_dogs` (e.g., 3) dogs are present on screen.
    *   Verify dogs are in their initial pack formation (spaced `pack_dx` apart, starting from `handler_x`).
    *   Confirm all dogs start in the "calm" state.
    *   (Developer) Check that each dog's initial `tension` is 0.
    *   (Developer) Check that each dog's `state_timer` is initialized to a random value between `interval_min` and `interval_max`.
    *   (Developer) Check that `visual_y_offset` is 0 and `active` is true for all dogs.
*   **Game State:**
    *   Confirm the initial `score` is 0.
    *   Confirm `game_over` is `false`.
*   **Audio:**
    *   Confirm background music (pattern 0) starts playing automatically.

## 2. Graphics & Layout

*   **Background Elements:**
    *   Observe the sidewalk: check it's drawn correctly at `y=ground_y` with the correct color.
    *   Observe the parallax city skyline: check it's drawn at `y=ground_y-32`.
    *   Verify both sidewalk stripes and skyline scroll smoothly to the left as the game progresses.
    *   Confirm building sprites (sprite 64) are tiled every 32 pixels for the skyline.
*   **Player Sprite:**
    *   Verify the player sprite remains visually static at its designated `x` and `y` coordinates throughout gameplay (it does not move with input).
*   **Dog Sprites:**
    *   Confirm each dog has its unique sprite (e.g., dog 1 uses sprite 20, dog 2 uses sprite 22, etc.).
*   **Leashes:**
    *   Verify each dog's leash is drawn from the player's hand position (`handler_x`, `ground_y-16`) to the dog's neck position (`d.x`, `current_dog_y_base - 4`).
    *   **Tension Colors:**
        *   Observe a dog's leash. As its tension increases (see Section 4), verify the leash color changes:
            *   Default: Light Grey (color 7)
            *   Tension > 33% of `tension_max`: Yellow (color 9)
            *   Tension > 66% of `tension_max`: Orange (color 10)
            *   Tension >= `tension_max`: Red (color 8)
    *   **Selected Dog Highlight:**
        *   When a dog is selected (see Section 3), if its tension is not high enough to trigger yellow, orange, or red, verify its leash is highlighted in Blue (color 12). This blue should be overridden by tension warning colors.
*   **Dog Activity:**
    *   If a dog becomes inactive (e.g., after escaping), confirm it is no longer drawn.

## 3. Controls

*   **Cycle Selected Dog (Z key / `btnp(0)`):**
    *   Press the 'Z' key repeatedly.
    *   Verify that the `selected_dog_idx` cycles through the dogs (e.g., 1 -> 2 -> 3 -> 1 for `num_dogs = 3`).
    *   Confirm the visual selection highlight (blue leash, if applicable) updates to the newly selected dog.
    *   Confirm that `sfx(3)` plays on each press of the 'Z' key.
*   **Tug Dog (X key / `btnp(1)`):**
    *   Functionality to be tested as part of "Tug Mechanics" (Section 5).

## 4. Dog State Machine

For each dog, attempt to observe the following state transitions and behaviors:

*   **Calm State:**
    *   (Developer) If a dog has any residual tension from a previous state (e.g., after being yanked back), verify its `tension` gradually drains by `calm_drain` per frame, clamped at 0.
    *   Observe that dogs remain in "calm" state for a variable period (their `state_timer`).
    *   After this timer expires, and if a random `rnd(1)` roll is less than `pull_chance`, the dog should transition to the "Warning" state. This might require several cycles to observe due to randomness.
*   **Warning State:**
    *   When a dog transitions to "Warning":
        *   Verify `sfx(0)` (bark sound) plays once.
        *   Observe the dog sprite hopping up by `warn_h` pixels and back down. The hop cycle should be noticeable (e.g., up for ~7 frames, down for ~7 frames).
    *   This state should last for `warn_dur` frames (e.g., 1.5 seconds at 30FPS).
    *   After `warn_dur` frames, the dog should automatically transition to the "Pulling" state.
*   **Pulling State:**
    *   When a dog transitions to "Pulling":
        *   Observe the dog sprite begin to move horizontally to the right (away from the player) at `escape_speed`.
        *   (Developer) Verify its `tension` starts increasing from 0 at `tension_rate` per frame.
        *   Observe the leash color changing according to the tension thresholds (Yellow -> Orange -> Red).
    *   If the dog's `tension` reaches `tension_max` (and it hasn't been successfully yanked back):
        *   The dog should transition to the "Escaped" state.
*   **Escaped State:**
    *   When a dog transitions to "Escaped":
        *   Verify the dog sprite is no longer drawn (becomes inactive).
        *   Confirm the "leash snapped! retry" message appears on screen, centered.
        *   Confirm `sfx(4)` (game over sound) plays.
        *   Verify the game state variable `game_over` becomes `true`.

## 5. Tug Mechanics

Focus on the currently `selected_dog_idx` for these tests.

*   **Pre-condition:** The selected dog must be in the "Pulling" state.
*   **Tugging Action:**
    *   Press the 'X' key (`btnp(1)`).
    *   Verify the dog's screen `x` position decreases (moves left towards player) by `tug_strength`.
    *   (Developer) Verify the dog's `tension` decreases by `tug_strength` (clamped at 0).
    *   Verify `sfx(1)` (tug press sound) plays on each press of 'X'.
*   **Successful Yank:**
    *   Continuously press 'X' while the selected dog is "Pulling".
    *   If the dog is successfully tugged back to its default pack position (`handler_x + (dog_idx-1) * pack_dx`):
        *   Verify the dog's state changes back to "Calm".
        *   (Developer) Verify its `tension` resets to 0.
        *   Verify `sfx(2)` (successful yank sound) plays once.
        *   Verify the player's `score` increases by 10 points.
        *   (Developer) Verify the dog's `state_timer` for the "Calm" state is reset to a new random interval between `interval_min` and `interval_max`.

## 6. Scoring & Progression

*   **Passive Scoring:**
    *   While the game is not over, observe the `score`.
    *   Verify it increases by 1 point approximately every 1/6th of a second (this is every 5 frames at 30FPS, or every 10 frames at 60FPS. The implementation uses 5 frames).
*   **Difficulty Progression:**
    *   Play the game for an extended period (at least 30 seconds, then 60 seconds).
    *   (Developer) After each 30-second interval (`game_timer % 900 == 0` for 30FPS):
        *   Confirm `pull_chance` increases by 0.005.
        *   Confirm `escape_speed` increases by 0.05.
    *   Qualitatively, verify that dogs tend to start pulling more often and move faster when pulling as the game progresses.

## 7. Game Over & Restart

*   **Triggering Game Over:**
    *   Allow one dog to reach the "Escaped" state (by letting its tension max out in "Pulling" state).
    *   Confirm `game_over` becomes `true`.
*   **Game Over State Behavior:**
    *   Verify that active game updates (dog movements, state changes other than the one causing game over, scoring, player input for tugging/cycling) halt.
    *   Background scrolling (sky, sidewalk) may continue.
    *   The "leash snapped! retry" message should be displayed.
*   **Restart:**
    *   While the "leash snapped! retry" message is visible (i.e., `game_over` is true):
        *   Press the 'X' key. The game should restart from the initial state (as if `_init()` was called).
        *   Press the 'Z' key. The game should also restart.
    *   Verify all initial state conditions from Section 1 are met upon restart (score 0, dogs reset, music restarts, etc.).

This guide should help in systematically testing the core functionality of the game.
