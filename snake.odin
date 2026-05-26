package snake

import "core:fmt"
import "core:math"
import rl "vendor:raylib"


main :: proc() {
	rl.InitWindow(i32(WINDOW_SIZE.x), i32(WINDOW_SIZE.y), "snakessss")
	rl.InitAudioDevice()
	restart()

	assets_loading: {
		body_texture = rl.LoadTexture("assets/body.png")
		food_texture = rl.LoadTexture("assets/food.png")
		head_texture = rl.LoadTexture("assets/head.png")
		tail_texture = rl.LoadTexture("assets/tail.png")
		corner_texture = rl.LoadTexture("assets/corner.png")
		tile_texture = rl.LoadTexture("assets/tile.png")

		crash_sound = rl.LoadSound("assets/crash.wav")
		eat_sound = rl.LoadSound("assets/eat.wav")
	}

	for !rl.WindowShouldClose() {
		input()

		tick_timer -= rl.GetFrameTime()
		if tick_timer <= 0 && state == .PLAYING {
			tick_timer += TICK_TIME
			on_tick()
		}

		drawing: {
			rl.BeginDrawing()
			rl.ClearBackground(BG_COLOR)
			camera := rl.Camera2D {
				zoom = ZOOM,
			}
			rl.BeginMode2D(camera)

			ground: {
				for i in 0..<MAP_SIZE.x{
					for j in 0..<MAP_SIZE.y{
						pos := rl.Vector2{f32(i), f32(j)} * f32(CELL_SIZE)
						rl.DrawTexture(tile_texture, i32(pos.x), i32(pos.y),rl.WHITE)
					}
				}
				
			}
			
			grid: {
				if draw_grid {
					width := i32(CANVAS_SIZE.x)
					height := i32(CANVAS_SIZE.y)
					for i in 0 ..= MAP_SIZE.x {
						rl.DrawLine(
							i32(i * CELL_SIZE),
							0,
							i32(i * CELL_SIZE),
							height,
							GRID_COLOR,
						)
					}
					for j in 0 ..= MAP_SIZE.y {
						rl.DrawLine(
							0,
							i32(j * CELL_SIZE),
							width,
							i32(j * CELL_SIZE),
							GRID_COLOR,
						)
					}
				}
			}

			snake: {
				for i in 0 ..< snake_length {
					texture: rl.Texture2D
					texture_direction: Vector2i
					if i == 0 {
						// head
						texture_direction = snake_parts[0] - snake_parts[1]
						texture = head_texture
					} else if i == snake_length - 1 {
						//tail
						texture_direction = snake_parts[i - 1] - snake_parts[i]
						texture = tail_texture
					} else {
						// body
						texture = body_texture
						texture_direction = snake_parts[i] - snake_parts[i - 1]
						if texture_direction + snake_parts[i] !=
						   snake_parts[i + 1] {
							// corner
							texture = corner_texture
							dir_1 := snake_parts[i - 1] - snake_parts[i]
							dir_2 := snake_parts[i + 1] - snake_parts[i]
							dir := dir_1 + dir_2

							if dir.x > 0 {
								if dir.y > 0 {
									texture_direction = {0, 1}
								} else if dir.y < 0 {
									texture_direction = {1, 0}
								}
							} else if dir.x < 0 {
								if dir.y > 0 {
									texture_direction = {-1, 0}
								} else if dir.y < 0 {
									texture_direction = {0, -1}
								}
							}
						}
					}

					// rl.DrawTexture(texture, i32(snake_parts[i].x * CELL_SIZE), i32(snake_parts[i].y * CELL_SIZE), rl.WHITE)
					source := rl.Rectangle {
						0,
						0,
						f32(CELL_SIZE),
						f32(CELL_SIZE),
					}
					dest := rl.Rectangle {
						f32(snake_parts[i].x * CELL_SIZE) +
						f32(CELL_SIZE) / 2.0,
						f32(snake_parts[i].y * CELL_SIZE) +
						f32(CELL_SIZE) / 2.0,
						f32(CELL_SIZE),
						f32(CELL_SIZE),
					}
					rotation :=
						math.DEG_PER_RAD *
						math.atan2_f32(
							f32(texture_direction.y),
							f32(texture_direction.x),
						)
					rl.DrawTexturePro(
						texture,
						source,
						dest,
						{f32(CELL_SIZE / 2.0), f32(CELL_SIZE / 2.0)},
						rotation,
						rl.WHITE,
					)

					//snake_part_rect := rl.Rectangle {f32(snake_parts[i].x * CELL_SIZE) , f32(snake_parts[i].y * CELL_SIZE), f32(CELL_SIZE), f32(CELL_SIZE)}

					//if i == 0 do rl.DrawRectangleRec(snake_part_rect, SNAKE_HEAD_COLOR)
					//else do rl.DrawRectangleRec(snake_part_rect, SNAKE_BODY_COLOR)
				}
			}

			food: {
				if state != .WON {
					rl.DrawTexture(
						food_texture,
						i32(food_pos.x * CELL_SIZE),
						i32(food_pos.y * CELL_SIZE),
						rl.WHITE,
					)
				}
			}

			ui: {
				switch state {
				case .PLAYING:
					score_text := fmt.caprintf(
						"length: %d / %d",
						snake_length,
						SNAKE_MAX_SIZE,
					)
					rl.DrawText(
						score_text,
						4,
						4,
						FONT_SIZE,
						{255, 255, 255, 125},
					)
				case .LOSE:
					rl.DrawText("GAME OVER\n", 4, 4, FONT_SIZE, rl.WHITE)
					rl.DrawText(
						"PRESS ENTER TO RESTART\n",
						0,
						0 + 32,
						FONT_SIZE,
						rl.WHITE,
					)
				case .WON:
					rl.DrawText("YOU WON\n", 4, 4, FONT_SIZE, rl.WHITE)
					rl.DrawText(
						"PRESS ENTER TO START AGAIN\n",
						0,
						0 + 16,
						FONT_SIZE,
						rl.WHITE,
					)
				}
			}

			rl.EndMode2D()
			rl.EndDrawing()
		}
	}

	rl.CloseAudioDevice()
	assets_unloading: {
		rl.UnloadTexture(body_texture)
		rl.UnloadTexture(food_texture)
		rl.UnloadTexture(head_texture)
		rl.UnloadTexture(tail_texture)
		rl.UnloadTexture(corner_texture)
		rl.UnloadTexture(tile_texture)

		rl.UnloadSound(crash_sound)
		rl.UnloadSound(eat_sound)
	}
	free_all(context.temp_allocator)
}

input :: proc() {
	if rl.IsKeyDown(.ENTER) {
		restart()
		return
	}

	if state == .PLAYING {
		potential_direction: Vector2i
		if rl.IsKeyDown(.W) do potential_direction = {0, -1}
		if rl.IsKeyDown(.S) do potential_direction = {0, 1}
		if rl.IsKeyDown(.D) do potential_direction = {1, 0}
		if rl.IsKeyDown(.A) do potential_direction = {-1, 0}

		for p in snake_parts {
			if potential_direction + snake_parts[0] == p {
				return
			}
		}
		snake_head_direction = potential_direction
	}
}

restart :: proc() {
	spawn_food()

	resetings_snake: {
		snake_head_direction = START_SNAKE_HEAD_DIRECTION
		for &p in snake_parts do p = {}
		snake_parts[0] = MAP_SIZE / 2 + 1
		snake_parts[1] = snake_parts[0] - {1, 0}
		snake_parts[2] = snake_parts[1] - {1, 0}
		snake_length = 3
	}

	state = .PLAYING
}

spawn_food :: proc() {
	is_cell_blocked := proc(pos: Vector2i) -> bool {
		for p in snake_parts {
			if p == pos do return true
		}
		return false
	}

	free_cells := make([dynamic]Vector2i, context.temp_allocator)
	for i in 0 ..< MAP_SIZE.x {
		for j in 0 ..< MAP_SIZE.y {
			if !is_cell_blocked({i, j}) do append(&free_cells, Vector2i{i, j})
		}
	}

	free_cell_index := rl.GetRandomValue(0, i32(len(free_cells) - 1))
	food_pos = free_cells[free_cell_index]
}

on_tick :: proc() {
	tail_pos := snake_parts[snake_length - 1]
	potential_head_pos := snake_parts[0] + snake_head_direction
	end_game := proc() {
		rl.PlaySound(crash_sound)
		state = .LOSE
	}

	checking_is_game_over: {
		is_head_out_of_map: bool =
			potential_head_pos.x < 0 ||
			potential_head_pos.y < 0 ||
			potential_head_pos.x >= MAP_SIZE.x ||
			potential_head_pos.y >= MAP_SIZE.y
		// map limits
		if is_head_out_of_map {
			end_game()
			return
		}
		// snake itself
		for p in 0 ..< snake_length {
			if snake_parts[p] == potential_head_pos {
				end_game()
				return
			}
		}
	}

	movement: {
		// body
		for i := snake_length - 1; i >= 1; i -= 1 {
			snake_parts[i] = snake_parts[i - 1]
		}
		//head
		snake_parts[0] = potential_head_pos
	}

	food_eating: {
		if snake_parts[0] == food_pos {
			rl.PlaySound(eat_sound)
			snake_parts[snake_length] = tail_pos
			snake_length += 1
			if SNAKE_MAX_SIZE == snake_length {
				state = GameState.WON
				return
			}
			spawn_food()
		}
	}
}
