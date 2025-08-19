extends Control

@onready var animationPlayer = $AnimationPlayer
@onready var healthControl   = $CentreAnchor/Health
@onready var missileControl  = $CentreAnchor/Missile
@onready var shieldControl   = $CentreAnchor/Shield
@onready var speedControl    = $CentreAnchor/Speed

func play_health() -> void:
	healthControl.visible  = true
	missileControl.visible = false
	shieldControl.visible  = false
	speedControl.visible   = false
	animationPlayer.play('use_item')

func play_missile() -> void:
	healthControl.visible  = false
	missileControl.visible = true
	shieldControl.visible  = false
	speedControl.visible   = false
	animationPlayer.play('use_item')

func play_shield() -> void:
	healthControl.visible  = false
	missileControl.visible = false
	shieldControl.visible  = true
	speedControl.visible   = false
	animationPlayer.play('use_item')

func play_speed() -> void:
	healthControl.visible  = false
	missileControl.visible = false
	shieldControl.visible  = false
	speedControl.visible   = true
	animationPlayer.play('use_item')
