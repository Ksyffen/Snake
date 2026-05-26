package snake

import rl "vendor:raylib"

Vector2i :: [2]int

GameState :: enum {
	PLAYING,
	LOSE,
	WON,
}

WINDOW_SIZE :: rl.Vector2{1000.0, 1000.0}
#assert(WINDOW_SIZE.x > 0 && WINDOW_SIZE.y > 0)

BG_COLOR :: rl.Color{143, 188, 143, 255}
// SNAKE_HEAD_COLOR :: rl.Color{173, 255, 47, 255}
// SNAKE_BODY_COLOR :: rl.Color{124, 252, 0, 255}
GRID_COLOR :: rl.Color{100, 100, 50, 100}
// FOOD_COLOR :: rl.Color{200, 100, 40, 255}

MAP_SIZE :: Vector2i{10, 10}
CELL_SIZE :: int(16)

CANVAS_SIZE := CELL_SIZE * MAP_SIZE
ZOOM: f32 = f32(WINDOW_SIZE.x) / f32(CANVAS_SIZE.x)

FONT_SIZE :: i32(MAP_SIZE.x)

TICK_TIME: f32 = 0.17
tick_timer: f32 = TICK_TIME

SNAKE_MAX_SIZE :: int(MAP_SIZE.x * MAP_SIZE.y)
START_SNAKE_HEAD_DIRECTION :: Vector2i{1, 0}

snake_parts: [SNAKE_MAX_SIZE]Vector2i
snake_length: int
snake_head_direction: Vector2i = START_SNAKE_HEAD_DIRECTION

state := GameState.PLAYING
draw_grid: bool = false

food_pos: Vector2i
