extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

@export var SPEED: float = 4.5
@export var SENSITIVITY: float = 0.0025
@export var HEAD_BOBS: float = 0.48
@export var BOB_DISTANCE: float = 0.1

var t_bob: float = 0.0

func _ready():
	#Mouse Invisible
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent):
	#Mouse Camera Follow
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Move
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 75 )
		velocity.z = lerp(velocity.x, direction.z * SPEED, delta * 75 )
	
	#Head Bob
	t_bob += delta * SPEED * velocity.length() * float(is_on_floor())
	camera.transform.origin = head_bob(t_bob)
	
	
	#Move and Slide
	move_and_slide()

func head_bob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * HEAD_BOBS) * BOB_DISTANCE
	pos.x = cos(time * HEAD_BOBS / 3) * BOB_DISTANCE
	return pos
