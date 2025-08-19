extends Node

var rng

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
