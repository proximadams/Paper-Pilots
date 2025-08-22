extends Node

const SAVE_FILE_PATH = 'user://settings.json'

var numDevicesConnected := 0
var rng
var settingsData = {
	'musicOn': true,
	'sfxVolume': 100
}

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	_load_settings()
	var _res = Input.connect('joy_connection_changed', _on_joy_connection_changed)

func _load_settings():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	var settingsFile := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var jsonString := settingsFile.get_line()
	var json := JSON.new()
	
	var parseResult = json.parse(jsonString)
	if not parseResult == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", jsonString, " at line ", json.get_error_line())
		return
	settingsData = json.data
	pass

func save_settings():
	var settingsFile = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	var jsonString = JSON.stringify(settingsData)

	settingsFile.store_line(jsonString)

func convert_volume_setting_to_db() -> float:
	var result = (4.0 * pow(settingsData.sfxVolume, 0.5)) -40.0
	if result == -40.0:
		result = -80.0
	return result

func _on_joy_connection_changed(_device: int, connected: bool) -> void:
	if connected:
		numDevicesConnected += 1
	else:
		numDevicesConnected -= 1

	if numDevicesConnected < 0:
		# should never be called but just to be safe...
		numDevicesConnected = 0
