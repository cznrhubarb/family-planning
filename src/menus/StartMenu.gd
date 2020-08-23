extends Node2D

const InstructionsMenu: PackedScene = preload("res://src/menus/InstructionsMenu.tscn")


func _on_InstructionsButton_pressed() -> void:
	get_parent().add_child(InstructionsMenu.instance())
	queue_free()


func _on_ColorRect_gui_input(event: InputEvent) -> void:
	if Utils.is_click_event(event):
		get_tree().paused = false
		Music.set_volume(-3)
		get_tree().get_current_scene().randomize_start()
		queue_free()
