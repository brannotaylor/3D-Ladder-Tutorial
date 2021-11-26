extends KinematicBody

var speed = 7
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 6

var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

var cam_accel = 40
var mouse_sense = 0.1
var snap

onready var head = $Head
onready var camera =$Head/Camera

func _ready():
	#Mouse mode invisible
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#Moving camera to mouse
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
			
func _process(delta):
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		camera.set_as_toplevel(false)
		camera.global_transform = head.global_transform
		
func _physics_process(delta):
	
	#Basic Movement COde
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("MoveBackward") - Input.get_action_strength("MoveForward")
	var h_input = Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
	
	#Jump
	if Input.is_action_just_pressed("jump"):
			snap = Vector3.ZERO
			gravity_vec = Vector3.UP * jump
			
	
	#Movement End Calculation
	velocity = direction * speed
	movement = velocity + gravity_vec
	var movement_val = move_and_slide_with_snap(movement, snap, Vector3.UP)
	
	#Exit Game
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
