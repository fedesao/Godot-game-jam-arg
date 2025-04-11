extends Node2D
@onready var player = $AudioStreamPlayer
func _ready():
	player.play()
	pass
