extends Sprite

var camera: Camera2D

func _process(_delta: float) -> void:
	
	if position.y < camera.get_camera_position().y - 320:
		position.y += 176 * 5
	pass