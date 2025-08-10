extends Control

@onready var hitableTexture  : TextureRect = $HitableTexture
@onready var unhitableTexture: TextureRect = $UnhitableTexture

func set_hitable(valueGiven: bool) -> void:
	hitableTexture.visible   = valueGiven
	unhitableTexture.visible = !valueGiven
