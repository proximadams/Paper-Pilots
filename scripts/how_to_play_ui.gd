extends Control

@onready var screenArr: Array[Control] = _get_screen_children()

var screenIndex = 0

func _get_screen_children() -> Array[Control]:
	var result: Array[Control] = []
	for currChild in get_children():
		if currChild is Control and not currChild is Button:
			result.append(currChild)
	return result

func on_next_button_pressed() -> void:
	screenArr[screenIndex].visible = false
	screenIndex += 1
	if screenIndex < screenArr.size():
		screenArr[screenIndex].visible = true
	else:
		get_tree().change_scene_to_file('res://scenes/level.tscn')
