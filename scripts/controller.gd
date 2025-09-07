# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D
class_name Player

signal get_damage

@export var can_move : bool = true
@export var has_gravity : bool = true
@export var can_jump : bool = true
@export var can_sprint : bool = true
@export var can_shoot : bool = true

@export_group("Speeds")
@export var look_speed : float = 0.002
@export var base_speed : float = 7.0
@export var jump_velocity : float = 4.5
@export var sprint_speed : float = 10.0

@export_group("Input Actions")
@export var input_left : String
@export var input_right : String
@export var input_forward : String
@export var input_back : String
@export var input_jump : String
@export var input_sprint : String
@export var input_fire1 : String
@export var input_fire2 : String

@export_group("Current Element")
@export var element1 : String = "default"
@export var element2 : String = "default"
@export var element1_strength : int = 1
@export var element2_strength : int = 1


var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0

@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var fire1_timer: Timer = $Fire1Timer
@onready var fire2_timer: Timer = $Fire2Timer
@onready var bullet_spawn: Node3D = $Head/Camera3D/BulletSpawn

const BULLET: PackedScene = preload("res://scenes/bullet.tscn")

func _ready() -> void:
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)

func spawn_bullet(element: String, strength: int):
	var bullet = BULLET.instantiate()
	bullet.element = element
	get_tree().root.add_child(bullet)
	bullet.global_transform = bullet_spawn.global_transform
	bullet.apply_impulse(-bullet_spawn.global_basis.z * strength * 10)

func _physics_process(delta: float) -> void:
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

	# Modify speed based on sprinting
	if can_sprint and Input.is_action_pressed(input_sprint):
			move_speed = sprint_speed
	else:
		move_speed = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	# Shoot
	if can_shoot:
		if Input.is_action_just_pressed(input_fire1) and fire1_timer.is_stopped():
			spawn_bullet(element1, element1_strength)
			fire1_timer.start()
		if Input.is_action_just_pressed(input_fire2) and fire1_timer.is_stopped():
			spawn_bullet(element2, element2_strength)
			fire2_timer.start()
	
	# Use velocity to actually move
	move_and_slide()

## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


func hurted():
	get_damage.emit()
