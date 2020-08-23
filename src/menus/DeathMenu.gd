extends Node2D

var ready_to_leave: bool = false


func make(dead: Portrait) -> void:
	Music.set_volume(-10)
	$Portrait.gender = dead.gender
	$Portrait.maturity = dead.maturity
	$Portrait.skin_color = dead.skin_color
	$Portrait.set_portrait()
	$AnimationPlayer.play("FadeIn")
	$AudioStreamPlayer.play()


func make_ready_to_leave() -> void:
	ready_to_leave = true


func _on_ColorRect_gui_input(event: InputEvent) -> void:
	if Utils.is_click_event(event) and ready_to_leave:
		$AnimationPlayer.play("FadeOut")


func leave() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
