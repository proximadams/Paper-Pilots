extends Control

@export var loadingScreen: Control

var started = false

@onready var musicToggle: Button  = $SubViewportContainer/SubViewport/SettingsMenu/SettingsOptions/MusicToggle
@onready var soundSlider: HSlider = $SubViewportContainer/SubViewport/SettingsMenu/SettingsOptions/SoundVolume/HSlider

func _input(_event: InputEvent) -> void:
	if not started:
		started = true
		Music.stop()
		if Global.settingsData.musicOn:
			$InitialSong.play()
		else:
			on_music_toggled(false)
			musicToggle.set_pressed_no_signal(false)
		soundSlider.value = Global.settingsData.sfxVolume

func _try_start_music():
	if Global.settingsData.musicOn and not Music.playing:
		Music.play()
	Music.volume_db = -10.0

func start_game() -> void:
	_try_start_music()
	loadingScreen.load('res://scenes/level.tscn')

func go_to_how_to_play() -> void:
	_try_start_music()
	loadingScreen.load('res://scenes/how_to_play_level.tscn')

func start_default_music() -> void:
	if Global.settingsData.musicOn:
		Music.play()

func on_music_toggled(toggledOn: bool) -> void:
	if toggledOn:
		Music.play()
		musicToggle.text = 'Music = ON'
		Global.settingsData.musicOn = true
		Global.save_settings()
	else:
		Music.stop()
		$InitialSong.stop()
		musicToggle.text = 'Music = OFF'
		Global.settingsData.musicOn = false
		Global.save_settings()

func set_sfx_volume(value: float) -> void:
	Global.settingsData.sfxVolume = value

func save_sfx_volume(valueChanged: bool) -> void:
	if valueChanged:
		Global.save_settings()

func on_quit_pressed() -> void:
	get_tree().quit()
