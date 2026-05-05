extends RigidBody2D

@export var drag_radius := 40.0
@export var launch_power := 10.0
var auto_pickup := 0.0

enum BallState { IDLE, DRAG, AIM }
var state: BallState = BallState.IDLE

var aim_start_pos := Vector2.ZERO

var physics_global_position := Vector2.ZERO

@export var velocity_stretch := 0.25
@export var max_stretch := 120.0
var poly := PackedVector2Array()

func get_mask_polygon() -> PackedVector2Array:
	var mask_radius := 90.0
	if state > 0:
		mask_radius = 2000

	var center := global_position
	var velocity: Vector2 = linear_velocity
	var speed := velocity.length()

	var dir := Vector2.RIGHT
	if speed > 0.001:
		dir = velocity.normalized()

	var perp := Vector2(-dir.y, dir.x)
	var stretch = min(speed * velocity_stretch, max_stretch)
	var stretch_offset = dir * (mask_radius + stretch)

	var p1 = center - stretch_offset - perp * mask_radius
	var p2 = center + stretch_offset - perp * mask_radius
	var p3 = center + stretch_offset + perp * mask_radius
	var p4 = center - stretch_offset + perp * mask_radius

	return PackedVector2Array([p1, p2, p3, p4])

func _integrate_forces(_state):
	physics_global_position = _state.transform.origin

func _physics_process(_delta):
	var mouse_pos = get_global_mouse_position()
	var dist_to_mouse = global_position.distance_to(mouse_pos)
	
	var window = get_window()
	var pos = self.position
	if (pos.x<-100) or (pos.x>window.size.x+100) or (pos.y<-100) or (pos.y>window.size.y+100):
		self.position = Vector2(window.size.x / 2, window.size.y * 0.2)
		linear_velocity = Vector2.ZERO
		angular_velocity = 0
	
	if (auto_pickup>0):
		auto_pickup -= 0.1
		if (auto_pickup<=0):
			auto_pickup = 0
	elif (auto_pickup<0):
		if (dist_to_mouse > drag_radius):
			auto_pickup *= -1

	match state:
		BallState.IDLE:
			freeze = false
			
			if (
				(Input.is_action_just_pressed("left_click") and dist_to_mouse <= drag_radius) 
				or (Input.is_action_pressed("space_press") and dist_to_mouse <= drag_radius and auto_pickup>=0) 
				or (auto_pickup>0 and dist_to_mouse <= drag_radius*0.7)
			):
				state = BallState.DRAG
				freeze = true
				freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
				linear_velocity = Vector2.ZERO
				angular_velocity = 0.0 
				auto_pickup = 0 

		BallState.DRAG:
			freeze = true
			global_position = mouse_pos
			linear_velocity = Vector2.ZERO
			angular_velocity = 0.0

			if Input.is_action_just_pressed("left_click"):
				state = BallState.AIM
				aim_start_pos = global_position
				
			if Input.is_action_just_pressed("space_press"):
				var launch_dir = Vector2(0,90)
				freeze = false
				apply_central_impulse(launch_dir * launch_power)
				angular_velocity = randf_range(-8.0, 8.0)
				state = BallState.IDLE
				auto_pickup = -5.0

		BallState.AIM:
			freeze = true
			global_position = aim_start_pos
			linear_velocity = Vector2.ZERO
			angular_velocity = 0.0

			if Input.is_action_just_released("left_click"):
				var launch_dir = aim_start_pos - mouse_pos
				freeze = false
				apply_central_impulse(launch_dir * launch_power)
				angular_velocity = randf_range(-15.0, 15.0)
				state = BallState.IDLE

	queue_redraw()
	
	poly = get_mask_polygon()
	PolyStore.set_polygon(get_instance_id(), poly, global_position, true)

	if state != BallState.IDLE:
		return
		
func _draw():
	if state == BallState.AIM:
		var local_start = to_local(aim_start_pos)
		var local_end = to_local(get_global_mouse_position())

		draw_line(local_start, local_end, Color.BLACK, 13.0)
		draw_line(local_start, local_end, Color.WHITE, 5.0)
