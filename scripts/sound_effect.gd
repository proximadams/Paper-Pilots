extends AudioStreamPlayer

@export var volumeOffset := 0.0

func _ready() -> void:
	set_volume_and_respect_setting()

func set_volume_and_respect_setting():
	volume_db = Global.convert_volume_setting_to_db() + volumeOffset
