extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var pivot: Node3D = $CameraController
@onready var camera_ray: RayCast3D = $CameraController/Camera3D/RayCast3D



@export var TILT_LOWER_LIMIT := deg_to_rad(-120.0)
@export var TILT_UPPER_LIMIT := deg_to_rad (120.0)
@export var CAMERA_CONTROLLER : Camera3D
@export var sensitivity = 0.5
@onready var gun_direction = $"Gun pivot"
@onready var cameraRay = $CameraController/over_the_shoulder/RayCast3D
@onready var distantTarget = $CameraController/over_the_shoulder/pointHereInstead
@onready var over_the_shoulder: Camera3D = $CameraController/over_the_shoulder
@onready var top: Camera3D = $CameraController/top
@onready var bullet_out_here = $"Gun pivot/bulletHere"
@onready var shoot_cd: Timer = $shoot_cd
@onready var explosion_effect_bullet = $"../AnimatedSprite3D"


var _mouse_input : bool = true
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3

var bullet = load("res://scenes/bullet.tscn")
var instance

var aim_adjust = true

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()	
	if event.is_action_pressed("toggle_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("toggle_camera_ray"):
		if camera_ray.visible == true:
			camera_ray.visible = false
		else:
			camera_ray.visible = true
	if event.is_action_pressed("aim_adjust"):
		if aim_adjust:
			aim_adjust = false
		else:
			aim_adjust = true
		print(aim_adjust)
	if event.is_action_pressed("change_camera"):	
		if over_the_shoulder.current:
			top.make_current()
		else:
			over_the_shoulder.make_current()
		
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event: InputEvent):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	#_mouse_input = event is InputEventAction and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	#if event is InputEventMouseMotion:
	if _mouse_input:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		pivot.rotate_x(deg_to_rad(-event.relative. y * sensitivity))
		pivot.rotation.x = clamp (pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
	
#func _update_camera (delta) :
	## Rotate camera using euler rotation
	#_mouse_rotation.x += _tilt_input * delta
	#_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	#_mouse_rotation.y += _rotation_input * delta
	#
	##CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_mouse_rotation)
	##CAMERA_CONTROLLER.rotation.z = 0.0
	#
	#_rotation_input = 0.0
	#_tilt_input = 0.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#_update_camera(delta)
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if Input.is_action_pressed("shoot"):
		if (shoot_cd.is_stopped()):
			instance = bullet.instantiate()
			instance.makeExplosion.connect(summon_explosion)
			instance.position = bullet_out_here.global_position
			instance.transform.basis = gun_direction.global_transform.basis
			get_parent().add_child(instance)
			shoot_cd.start()

	move_and_slide()
	
	# get collision
	var a = cameraRay.get_collision_point()
	
	var gunvector = gun_direction.global_position - a
	
	if cameraRay.is_colliding() and aim_adjust:
		gun_direction.look_at(a, Vector3(0,-1,0))
	else:
		gun_direction.look_at(distantTarget.global_position, Vector3(0,-1,0))
		
func summon_explosion(pos, dir):
	var bb = explosion_effect_bullet.duplicate()
	bb.global_position = pos
	bb.set_rotation(dir)
	bb.play()
	get_parent().add_child(bb)
	pass

	
	
