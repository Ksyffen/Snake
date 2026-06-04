package snake

import "core:fmt"
import rl "vendor:raylib"
import "core:math"


MAX_CAMERA_OFFSET: f32 = 30
shaking: bool

SHAKE_TIME: f32 = 0.09
SHAKINGS_NUM: i32 = 3
shake_timer: f32 = 0


shake_camera :: proc(camera: ^rl.Camera2D){
	camera.offset.x = MAX_CAMERA_OFFSET * (1 - shake_timer/(SHAKE_TIME * f32(SHAKINGS_NUM))) * math.sin((2 * math.PI / SHAKE_TIME) * shake_timer)
	shake_timer += rl.GetFrameTime()
	if shake_timer >= SHAKE_TIME * f32(SHAKINGS_NUM) {
		shaking = false
		shake_timer = 0.0
		camera.offset.x = 0.0
	} 
}