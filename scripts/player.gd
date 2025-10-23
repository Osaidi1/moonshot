class_name player
extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collision: CollisionShape3D = $Collision
@onready var animation: AnimationPlayer = $Animation
@onready var crouch_check: RayCast3D = $CrouchCheck

const PLAYER = preload("res://collisions/player.tres")
const CROUCTH = preload("res://collisions/croucth.tres")

@export var SPEED: float = 2.75
@export var CROUCH_SPEED: float = 1.25
@export var HEALTH: int = 100
@export var SENSITIVITY: float = 0.0025
@export var HEAD_BOBS: float = 0.48
@export var BOB_DISTANCE: float = 0.1

var t_bob: float = 0.0
var is_crouching: bool = false
var speed: int = 0

func _ready():
	#Mouse Invisible
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	collision.shape = PLAYER
	speed = SPEED
	head.position.y = 0.228
	crouch_check.enabled = false

func _unhandled_input(event: InputEvent):
	#Mouse Camera Follow
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(60))
	
	#Crouch
	if event.is_action_pressed("crouch"):
		if !is_crouching:
			crouch()
		elif is_crouching and !crouch_check.is_colliding():
			collision.shape = PLAYER
			animation.play("crouch off")
			is_crouching = false
			crouch_check.enabled = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Speed set
	if is_crouching:
		speed = CROUCH_SPEED
	elif !is_crouching:
		speed = SPEED
	
	#Move
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y) * 8).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		elif !direction:
			velocity.x = velocity.x - (velocity.x * speed * delta ) * 8
			velocity.z = velocity.z - (velocity.z * speed * delta ) * 8
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 75 )
		velocity.z = lerp(velocity.x, direction.z * speed, delta * 75 )
	
	#Head Bob
	t_bob += delta * speed * velocity.length() * float(is_on_floor())
	camera.transform.origin = head_bob(t_bob)
	
	#Move and Slide
	move_and_slide()

func head_bob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * HEAD_BOBS) * BOB_DISTANCE
	pos.x = cos(time * HEAD_BOBS / 3) * BOB_DISTANCE
	return pos

func crouch():
	is_crouching = true
	collision.shape = CROUCTH
	animation.play("crouch on")
	crouch_check.enabled = true

func change_health(change):
	HEALTH -= change
	HEALTH = clamp(HEALTH - change, 0, 100)
