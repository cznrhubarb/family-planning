extends Node

var globals: Dictionary = {}


func _ready():
	randomize()


func transfer_child(
	child: Node, src_parent: Node, dest_parent: Node, preserve_transform: bool = true
) -> void:
	var transform = child.global_transform
	src_parent.remove_child(child)
	dest_parent.add_child(child)
	if preserve_transform:
		child.global_transform = transform


func random_entry(array: Array):
	return array[randi() % array.size()]


# Buggy pause functionality?
# If I add a PROCESS mode node as a child and immediately pause,
# it doesn't process. But if I delay for 1/10 of a second, it works...
func pause() -> void:
	yield(get_tree().create_timer(100), "timeout")
	get_tree().paused = true


func unpause() -> void:
	get_tree().paused = false


func is_click_event(event: InputEvent, button_index: int = BUTTON_LEFT) -> bool:
	return event is InputEventMouseButton and event.button_index == button_index and event.is_pressed()
