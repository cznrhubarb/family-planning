extends Node2D

const SPEED: float = 350.0
var direction: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	position += direction * SPEED * delta


func fly(start: Vector2, end: Vector2) -> void:
	position = start
	direction = (end - start).normalized()
	if start.x < end.x:
		$Sprite.flip_h = true