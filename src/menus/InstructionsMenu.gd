extends Node2D


func _ready() -> void:
	get_tree().get_current_scene().find_node("BirthingLine").visible = true
	get_tree().get_current_scene().find_node("MaturityLine").visible = true
	$SinglePortrait.turn_adult()
	$MarriedPortrait.turn_adult()
	$MarriedPortrait.bell_fill = 100
	$MarriedPortrait2.turn_adult()
	$MarriedPortrait2.bell_fill = 100
	$ElderlyPortrait.turn_adult()
	$ElderlyPortrait.turn_elderly()


func _on_ColorRect_gui_input(event: InputEvent) -> void:
	if Utils.is_click_event(event):
		get_tree().paused = false
		Music.set_volume(-3)
		get_tree().get_current_scene().randomize_start()
		queue_free()


func _process(_delta: float) -> void:
	if $MarriedPortrait.heart_fill == 100:
		$MarriedPortrait.heart_fill = 0
		$MarriedPortrait2.heart_fill = 0
	

func bump_bell() -> void:
	if $SinglePortrait.bell_fill == 99:
		$SinglePortrait.bell_fill = 0
	else:
		$SinglePortrait.bell_fill += 11