extends CharacterBody3D

var explosionSoundRes = preload('res://scenes/explosion_sound.tscn')
var shootSoundRes     = preload('res://scenes/shoot_sound.tscn')

signal game_over(playerId: int)

const INIT_PROPULSION_SPEED  := 200.0
const GRAVITY                := -2000.0
const MAX_HEALTH             := 20
const MAX_PROPELLOR_SPEED    := 20.0
const MAX_PROPULSION_SPEED   := 10000.0
const MOVE_ACCELERATION      := 400.0
const PROPELLOR_ACCELERATION := 0.01
const SHOOT_COOL_DOWN_TIME   := 0.4
const SHOOT_DECCELERATION    := 1000.0
const TILT_DOWN_SPEED        := 100.0
const WING_DEGREES           := 45.0

var explosionRes = preload('res://scenes/explosion.tscn')

@export var enemyPlayer: CharacterBody3D

@export var gunShots    : Node3D
@export var gunShotsAnim: AnimationPlayer

@export var leftMoveableWing : Node3D
@export var rightMoveableWing: Node3D

@export var materialSafe  : Material
@export var materialUnsafe: Material

@export var engineStartSound  : AudioStreamPlayer
@export var propellor         : MeshInstance3D
@export var rectangles        : Node3D
@export var trailHorizontalAdd: MeshInstance3D
@export var trailVerticalAdd  : MeshInstance3D
@export var trailHorizontalSub: MeshInstance3D
@export var trailVerticalSub  : MeshInstance3D

@export var playerID: int

var enemyHitableCount := 0
var fallSpeed         := 0.0# negative is fall direction
var health            := MAX_HEALTH
var isHitable         := true
var propulsionSpeed   := INIT_PROPULSION_SPEED
var propellorSpeed    := 0.0
var shootCoolDownTime := 0.0
var timeWithNoEngine  := 0.0

var state := FIGHTING

enum {
	FIGHTING,
	WON,
	LOST
}

@onready var allBodyVisuals: Array[MeshInstance3D] = _get_all_body_visuals()
@onready var initPosition  := global_position
@onready var initRotation  := global_rotation

func _physics_process(delta: float) -> void:
	if state == FIGHTING:
		_handle_input_wing_angles()
		_handle_spin_propellor(delta)
		_handle_gun_fire(delta)
		_handle_rotation(delta)
		_handle_gravity()
		_handle_movement(delta)
		_aim_gun_shot()
	elif state == WON:
		_handle_spin_propellor(delta)
		move_and_slide()

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
	if Input.is_action_pressed('shoot_p%d' % playerID) or 0.0 < shootCoolDownTime:
		result = -1.0
	if result < 0.0:
		result *= SHOOT_DECCELERATION + 2000.0 * timeWithNoEngine
	else:
		result *= MOVE_ACCELERATION
	return result

func _handle_gun_fire(delta: float) -> void:
	if Input.is_action_just_pressed('shoot_p%d' % playerID) and shootCoolDownTime == 0.0:
		gunShotsAnim.play('shooting')
	elif Input.is_action_just_released('shoot_p%d' % playerID):
		gunShotsAnim.play('not_shooting')
		if shootCoolDownTime == 0.0:
			shootCoolDownTime = SHOOT_COOL_DOWN_TIME
	if 0.0 < shootCoolDownTime:
		shootCoolDownTime -= delta
	if shootCoolDownTime < 0.0 and Input.is_action_pressed('shoot_p%d' % playerID):
		shootCoolDownTime = 0.0
		gunShotsAnim.play('shooting')

func _handle_gravity() -> void:
	fallSpeed = GRAVITY * abs(global_basis.z.normalized().y) + abs(global_basis.x.normalized().y) * velocity.y

func _handle_movement(delta: float) -> void:
	var accdeccMult = _get_acceleration_decceleration_mult()
	propulsionSpeed = max(0.0, propulsionSpeed + (accdeccMult * delta))
	propulsionSpeed -= (global_basis.z.normalized().y - 0.5) * delta * 70.0
	propulsionSpeed = min(MAX_PROPULSION_SPEED, max(0.0, propulsionSpeed))

	if accdeccMult < 0.0:
		timeWithNoEngine += delta
	else:
		timeWithNoEngine = 0.0

	velocity = Vector3(propulsionSpeed, propulsionSpeed, propulsionSpeed)
	velocity *= delta * global_basis.z.normalized()
	velocity.y += delta * fallSpeed
	move_and_slide()
	transform = transform.orthonormalized()

func _handle_rotation(delta: float) -> void:
	var speedMultX = 1.5 + (0.003 * (sqrt(propulsionSpeed)))
	var speedMultY = 1.2 + (0.0008 * (sqrt(propulsionSpeed)))
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
	var oldPropellorSpeed = propellorSpeed
	propellorSpeed = max(0.0, min(MAX_PROPELLOR_SPEED, propellorSpeed + (accdeccMult * delta * PROPELLOR_ACCELERATION)))
	propellor.rotation.z += delta * propellorSpeed
	if propellorSpeed != oldPropellorSpeed:
		if oldPropellorSpeed == 0.0:
			engineStartSound.play()
		else:
			engineStartSound.stop()

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
		var explosionSoundInst: AudioStreamPlayer = explosionSoundRes.instantiate()
		add_child(explosionSoundInst)
		enemyPlayer.get_hit()
	var shootSoundInst: AudioStreamPlayer = shootSoundRes.instantiate()
	add_child(shootSoundInst)

func get_hit() -> void:
	if 0 < health:
		health -= 1
	else:
		_die()
	var greyValue: float = float(health) / float(MAX_HEALTH)
	trailHorizontalAdd._startColor.r = greyValue
	trailHorizontalAdd._startColor.g = greyValue
	trailHorizontalAdd._startColor.b = greyValue
	trailVerticalAdd._startColor.r   = greyValue
	trailVerticalAdd._startColor.g   = greyValue
	trailVerticalAdd._startColor.b   = greyValue
	trailHorizontalSub._startColor.a = 1.0 - greyValue
	trailVerticalSub._startColor.a   = 1.0 - greyValue

func _die() -> void:
	rectangles.visible = false
	isHitable = false
	state = LOST
	gunShotsAnim.play('not_shooting')
	enemyPlayer.state = WON
	enemyPlayer.gunShotsAnim.play('not_shooting')
	enemyPlayer.isHitable = false
	emit_signal('game_over', playerID)

func restart() -> void:
	rectangles.visible = true
	trailHorizontalSub.visible = true
	trailVerticalSub.visible = true
	isHitable = true
	state = FIGHTING
	health = MAX_HEALTH
	velocity = Vector3()
	propulsionSpeed = INIT_PROPULSION_SPEED
	global_position = initPosition
	global_rotation = initRotation
	trailHorizontalAdd._startColor.r = 1.0
	trailHorizontalAdd._startColor.g = 1.0
	trailHorizontalAdd._startColor.b = 1.0
	trailVerticalAdd._startColor.r   = 1.0
	trailVerticalAdd._startColor.g   = 1.0
	trailVerticalAdd._startColor.b   = 1.0
	trailHorizontalSub._startColor.a = 0.0
	trailVerticalSub._startColor.a   = 0.0

	trailHorizontalAdd.restart()
	trailVerticalAdd.restart()
	trailHorizontalSub.restart()
	trailVerticalSub.restart()
