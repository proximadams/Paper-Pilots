extends CharacterBody3D

const GRAVITY               : float = -200.0
const MAX_PROPELLOR_SPEED   : float = 20.0
const MAX_PROPULSION_SPEED  : float = 10000.0
const MOVE_ACCELERATION     : float = 400.0
const PROPELLOR_ACCELERATION: float = 50.0
const SHOOT_DECCELERATION   : float = 1000.0
const TILT_DOWN_SPEED       : float = 100.0
const WING_DEGREES          : float = 45.0

var explosionRes = preload('res://scenes/explosion.tscn')

@export var enemyPlayer: CharacterBody3D

@export var gunShots    : Node3D
@export var gunShotsAnim: AnimationPlayer

@export var leftMoveableWing : Node3D
@export var rightMoveableWing: Node3D

@export var materialSafe  : Material
@export var materialUnsafe: Material

@export var propellor: MeshInstance3D
@export var rectangles: Node3D

@export var playerID: int

var enemyHitableCount: int   = 0
var fallSpeed        : float = 0.0# negative is fall direction
var isHitable        : bool  = true
var propulsionSpeed  : float = 200.0
var propellorSpeed   : float = 0.0

@onready var allBodyVisuals: Array[MeshInstance3D] = _get_all_body_visuals()

# TODO: edge of screen tells you where enemy is
# TODO: slightly random hit location on plane

func _process(delta: float) -> void:
	_handle_input_wing_angles()
	_handle_spin_propellor(delta)
	_handle_gun_fire()
	_handle_rotation(delta)
	_handle_gravity()
	_handle_movement(delta)
	_aim_gun_shot()

func _aim_gun_shot() -> void:
	if enemyPlayer.isHitable:
		gunShots.look_at(enemyPlayer.global_position)
		gunShots.scale = Vector3(-1.0, -1.0, -1.0)
	else:
		gunShots.look_at(global_position)
		gunShots.scale = Vector3(1.0, 1.0, 1.0)

func _get_recursive_children(node) -> Array[Node]:
	var nodeArr: Array[Node] = []

	for currChild in node.get_children():
		if currChild.get_child_count() > 0:
			nodeArr.append(currChild)
			nodeArr.append_array(_get_recursive_children(currChild))
		else:
			nodeArr.append(currChild)

	return nodeArr

func _get_all_body_visuals() -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	var allRectanglesRecursiveChildren: Array[Node] = _get_recursive_children(rectangles)
	for currNode in allRectanglesRecursiveChildren:
		if currNode is MeshInstance3D:
			result.append(currNode)
	return result

func _get_acceleration_decceleration_mult() -> float:
	var result = 1.0
	if Input.is_action_pressed('shoot_p%d' % playerID):
		result = -1.0
	if result < 0.0:
		result *= SHOOT_DECCELERATION
	else:
		result *= MOVE_ACCELERATION
	return result

func _handle_gun_fire() -> void:
	if Input.is_action_just_pressed('shoot_p%d' % playerID):
		gunShotsAnim.play('shooting')
	elif Input.is_action_just_released('shoot_p%d' % playerID):
		gunShotsAnim.play('not_shooting')

func _handle_gravity() -> void:
	fallSpeed = GRAVITY * abs(global_basis.z.normalized().y) + abs(global_basis.x.normalized().y)

func _handle_movement(delta: float) -> void:
	var accdeccMult = _get_acceleration_decceleration_mult()
	propulsionSpeed = max(0.0, propulsionSpeed + (accdeccMult * delta))
	propulsionSpeed -= (global_basis.z.normalized().y - 0.5) * delta * 70.0
	propulsionSpeed = min(MAX_PROPULSION_SPEED, max(0.0, propulsionSpeed))

	velocity = Vector3(propulsionSpeed, propulsionSpeed, propulsionSpeed)
	velocity *= delta * global_basis.z.normalized()
	velocity.y += delta * fallSpeed
	move_and_slide()
	transform = transform.orthonormalized()

func _handle_rotation(delta: float) -> void:
	var speedMultX = 1.5 + (0.003 * (sqrt(propulsionSpeed * abs(fallSpeed))))
	var speedMultY = 1.2 + (0.0008 * (sqrt(propulsionSpeed * abs(fallSpeed))))
	var inputDirection = get_input_direction()
	if 0.0 < propulsionSpeed or rad_to_deg(rotation.x) < 80.0 or 100.0 < rad_to_deg(rotation.x):
		rotate_object_local(Vector3.RIGHT, delta * inputDirection.y * speedMultY)
	rotate_object_local(Vector3.FORWARD, delta * inputDirection.x * speedMultX)
	if rad_to_deg(rotation.x) < 80.0 or 100.0 < rad_to_deg(rotation.x):
		if propulsionSpeed == 0.0:
			propulsionSpeed = 0.001
		rotation.x += delta * min(2.0, max(0.0, max(0.0, TILT_DOWN_SPEED/propulsionSpeed) - 0.1))

func _handle_spin_propellor(delta: float) -> void:
	var accdeccMult = _get_acceleration_decceleration_mult()
	propellorSpeed = max(0.0, min(MAX_PROPELLOR_SPEED, propellorSpeed + (accdeccMult * delta * PROPELLOR_ACCELERATION)))
	propellor.rotation.z += delta * propellorSpeed

func _handle_input_wing_angles() -> void:
	var inputDirection = get_input_direction()
	leftMoveableWing.rotation.x  = deg_to_rad(inputDirection.x - inputDirection.y) * WING_DEGREES
	rightMoveableWing.rotation.x = deg_to_rad(-inputDirection.x - inputDirection.y) * WING_DEGREES

func get_input_direction() -> Vector2:
	var result = Vector2()
	result.x = (Input.get_action_strength('move_left_p%d' % playerID) - Input.get_action_strength('move_right_p%d' % playerID))
	result.y = (Input.get_action_strength('move_up_p%d' % playerID) - Input.get_action_strength('move_down_p%d' % playerID))
	return result

func _on_gun_shot_area_3d_area_entered(area: Area3D) -> void:
	if area.name == 'WingArea3D':
		enemyHitableCount += 1
		enemyPlayer.set_is_hittable(enemyHitableCount != 0)

func _on_gun_shot_area_3d_area_exited(area: Area3D) -> void:
	if area.name == 'WingArea3D':
		enemyHitableCount -= 1
		enemyPlayer.set_is_hittable(enemyHitableCount != 0)

func _on_gun_shot_area_3d_body_entered(body: Node3D) -> void:
	if body.name.begins_with('Player'):
		enemyHitableCount += 1
		enemyPlayer.set_is_hittable(enemyHitableCount != 0)

func _on_gun_shot_area_3d_body_exited(body: Node3D) -> void:
	if body.name.begins_with('Player'):
		enemyHitableCount -= 1
		enemyPlayer.set_is_hittable(enemyHitableCount != 0)

func set_is_hittable(valueGiven: bool) -> void:
	var newMaterial = materialSafe
	isHitable = valueGiven
	if isHitable:
		newMaterial = materialUnsafe
	for currMesh in allBodyVisuals:
		currMesh.set_surface_override_material(0, newMaterial)

func _on_gun_shot() -> void:
	if enemyPlayer.isHitable:
		var explosionInst: Node3D = explosionRes.instantiate()
		get_parent().add_child(explosionInst)
		explosionInst.global_position = enemyPlayer.global_position
