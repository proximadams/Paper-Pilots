extends Node3D

@export var player1   : CharacterBody3D
@export var camera1   : Camera3D
@export var winLabel1 : Label
@export var loseLabel1: Label
@export var player2   : CharacterBody3D
@export var camera2   : Camera3D
@export var winLabel2 : Label
@export var loseLabel2: Label

@export var gameOverSound : AudioStreamPlayer
@export var gameOverUiAnim: AnimationPlayer

func _ready() -> void:
	player1.connect('game_over', player_died)
	player2.connect('game_over', player_died)

func player_died(playerId: int) -> void:
	gameOverSound.play()
	gameOverUiAnim.play('CountDown')
	if playerId == 1:
		player_win(camera2, winLabel2)
		player_lose(camera1, loseLabel1)
	elif playerId == 2:
		player_win(camera1, winLabel1)
		player_lose(camera2, loseLabel2)
	else:
		print('ERROR: player ID is invalid. playerId = ' + str(playerId))

func player_win(camera: Camera3D, winLabel: Label):
	camera.gameOver = true
	winLabel.show()

func player_lose(camera: Camera3D, loseLabel: Label):
	camera.gameOver = true
	loseLabel.show()

func restart() -> void:
	player1.restart()
	camera1.gameOver = false
	winLabel1.hide()
	loseLabel1.hide()
	player2.restart()
	camera2.gameOver = false
	winLabel2.hide()
	loseLabel2.hide()
