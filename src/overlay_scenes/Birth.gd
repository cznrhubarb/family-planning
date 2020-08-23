extends Node2D

const CENTER_SCREEN: int = 320
const TRAVEL_DISTANCE: int = 400


func _ready():
	var start_x: float
	var end_x: float

	if randi() % 2 > 0:
		start_x = CENTER_SCREEN - TRAVEL_DISTANCE
		end_x = CENTER_SCREEN + TRAVEL_DISTANCE
	else:
		start_x = CENTER_SCREEN + TRAVEL_DISTANCE
		end_x = CENTER_SCREEN - TRAVEL_DISTANCE

	var start: Vector2 = Vector2(start_x, 175)
	var end: Vector2 = Vector2(end_x, 175 + rand_range(-75, 75))
	$Stork.fly(start, end)
	var duration: float = (end - start).length() / $Stork.SPEED
	_free_on_destination(duration)
	

func _free_on_destination(duration: float) -> void:
	yield(get_tree().create_timer(duration), "timeout")
	queue_free()