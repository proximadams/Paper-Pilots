extends CharacterBody3D

const GRAVITY               : float = -200.0
const MAX_PROPELLOR_SPEED   : float = 20.0
const MAX_PROPULSION_SPEED  : float = 10000.0
const MOVE_ACCELERATION     : float = 400.0
const PROPELLOR_ACCELERATION: float = 50.0
const SHOOT_DECCELERATION   : float = 1000.0
const TILT_DOWN_SPEED       : float = 100.0
const WING_DEGREES          : float = 45.0

@export var gunShotsAnim: AnimationPlayer

@export var leftMoveableWing : Node3D
@export var rightMoveableWing: Node3D

@export var propellor: MeshInstance3D

var fallSpeed      : float = 0.0# negative is fall direction
var propulsionSpeed: float = 200.0
var propellorSpeed : float = 0.0

func _process(delta: float) -> void:
	handle_input_wing_angles()
	handle_spin_propellor(delta)
	handle_gun_fire()
	handle_rotation(delta)
	handle_gravity()
	handle_movement(delta)

func _get_acceleration_decceleration_mult() -> float:
	var result = 1.0
	if Input.is_action_pressed('shoot'):
		result = -1.0
	if result < 0.0:
		result *= SHOOT_DECCELERATION
	else:
		result *= MOVE_ACCELERATION
	return result

func handle_gun_fire() -> void:
	if Input.is_action_just_pressed('shoot'):
		gunShotsAnim.play('shooting')
	elif Input.is_action_just_released('shoot'):
		gunShotsAnim.play('not_shooting')

func handle_gravity() -> void:
	fallSpeed = GRAVITY * abs(global_basis.z.normalized().y) + abs(global_basis.x.normalized().y)

func handle_movement(delta: float) -> void:
	var accdeccMult = _get_acceleration_decceleration_mult()
	propulsionSpeed = max(0.0, propulsionSpeed + (accdeccMult * delta))
	propulsionSpeed -= (global_basis.z.normalized().y - 0.5) * delta * 70.0
	propulsionSpeed = min(MAX_PROPULSION_SPEED, max(0.0, propulsionSpeed))

	velocity = Vector3(propulsionSpeed, propulsionSpeed, propulsionSpeed)
	velocity *= delta * global_basis.z.normalized()
	velocity.y += delta * fallSpeed
	move_and_slide()
	transform = transform.orthonormalized()

func handle_rotation(delta: float) -> void:
	var speedMultX = 0.5 + (0.003 * (sqrt(propulsionSpeed * abs(fallSpeed))))
	var speedMultY = 0.4 + (0.0008 * (sqrt(propulsionSpeed * abs(fallSpeed))))
	var inputDirection = get_input_direction()
	if 0.0 < propulsionSpeed or rad_to_deg(rotation.x) < 80.0 or 100.0 < rad_to_deg(rotation.x):
		rotate_object_local(Vector3.RIGHT, delta * inputDirection.y * speedMultY)
	rotate_object_local(Vector3.FORWARD, delta * inputDirection.x * speedMultX)
	if rad_to_deg(rotation.x) < 80.0 or 100.0 < rad_to_deg(rotation.x):
		if propulsionSpeed == 0.0:
			propulsionSpeed = 0.001
		rotation.x += delta * max(0.0, max(0.0, TILT_DOWN_SPEED/propulsionSpeed) - 0.1)

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
