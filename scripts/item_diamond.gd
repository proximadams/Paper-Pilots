extends ColorRect

var state = EMPTY

@onready var healthItem  = $HealthItem
@onready var missileItem = $MissileItem
@onready var shieldItem  = $ShieldItem
@onready var speedItem   = $SpeedItem
@onready var animationPlayer = $AnimationPlayer

enum {
	EMPTY,
	HEALTH,
	MISSILE,
	SHIELD,
	SPEED
}

func pick_random_item() -> void:
	var itemStateArr = [HEALTH, SHIELD, SPEED, MISSILE]
	state = itemStateArr[Global.rng.randi_range(0, 3)]
	animationPlayer.play('glow_outline')
	healthItem.visible  = false
	missileItem.visible = false
	shieldItem.visible  = false
	speedItem.visible   = false

	match state:
		HEALTH:
			healthItem.visible  = true
		MISSILE:
			missileItem.visible = true
		SHIELD:
			shieldItem.visible  = true
		SPEED:
			speedItem.visible   = true
