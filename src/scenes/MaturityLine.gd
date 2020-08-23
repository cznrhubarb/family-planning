extends Node2D

const PAN_SPEED: float = 8.0

func _process(delta):
	position.y += PAN_SPEED * delta
