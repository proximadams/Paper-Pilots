extends CharacterBody3D

const MAX_PROPELLOR_SPEED   : float = 20.0
const MOVE_ACCELERATION     : float = 100.0
const PROPELLOR_ACCELERATION: float = 50.0
const SHOOT_DECCELERATION   : float = 300.0
const WING_DEGREES          : float = 45.0

@export var leftMoveableWing : Node3D
@export var rightMoveableWing: Node3D

@export var propellor: MeshInstance3D

var moveSpeed      : float = 0.0
var propellorSpeed : float = 0.0

func _process(delta: float) -> void:
	handle_input_wing_angles()
	handle_spin_propellor(delta)
	handle_rotation(delta)
	handle_movement(delta)

func _get_acceleration_decceleration_mult() -> float:
	var result = 1.0
	if Input.is_action_pressed('shoot'):
		result = -1.0
	return result

func handle_movement(delta: float) -> void:
	var accdeccMult = _get_acceleration_decceleration_mult()
	moveSpeed = max(0.0, moveSpeed + (accdeccMult * delta * MOVE_ACCELERATION))

	velocity = Vector3(moveSpeed, moveSpeed, moveSpeed)
	velocity *= delta * global_basis.z.normalized()
	move_and_slide()

func handle_rotation(delta: float) -> void:
	var inputDirection = get_input_direction()
	rotate_object_local(Vector3.RIGHT, delta * inputDirection.y)
	rotate_object_local(Vector3.FORWARD, delta * inputDirection.x)

func handle_spin_propellor(delta: float) -> void:
	var accdeccMult = _get_acceleration_decceleration_mult()
	propellorSpeed = max(0.0, min(MAX_PROPELLOR_SPEED, propellorSpeed + (accdeccMult * delta * PROPELLOR_ACCELERATION)))
	propellor.rotation.z += delta * propellorSpeed

func handle_input_wing_angles() -> void:
	var inputDirection = get_input_direction()
	leftMoveableWing.rotation.x  = deg_to_rad(inputDirection.x - inputDirection.y) * WING_DEGREES
	rightMoveableWing.rotation.x = deg_to_rad(-inputDirection.x - inputDirection.y) * WING_DEGREES

func get_input_direction() -> Vector2:
	var result = Vector2()
	result.x = (Input.get_action_strength('move_left') - Input.get_action_strength('move_right'))
	result.y = (Input.get_action_strength('move_up') - Input.get_action_strength('move_down'))
	return result
