extends CanvasLayer

var scene_queue: Array = []
var current_scene: Node

func _ready() -> void:
	var root: Viewport = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

# Transition parameters (and defaults)
#		delay (0): how long to wait before starting transition
#		suspense (0): how long to wait before coming back from transition
#		data (null): any data to pass to the next scene, using that scene's make() function

# Future parameters:
#		mask (pixel_curtain): which transition mask/effect to use
#		sfx (null): sound effect file to play on fade in (or should this be the scene's responsibility?)
#		music (null): music to change to (or should this be the scene's responsibility? Maybe here if we want to interpolate it)


func to(path: String, params: Dictionary = {}) -> void:
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP
	if params.has("delay"):
		yield(get_tree().create_timer(params.delay), "timeout")
	$AnimationPlayer.play("fade_out")
	yield($AnimationPlayer, "animation_finished")

	call_deferred("_deferred_scene_change", path, params)


func _deferred_scene_change(path: String, params: Dictionary) -> void:
	current_scene.free()

	var next_scene: PackedScene = ResourceLoader.load(path)
	current_scene = next_scene.instance()

	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	
	if params.has("data"):
		current_scene.make(params.data)
	if params.has("suspense"):
		yield(get_tree().create_timer(params.suspense), "timeout")
	$AnimationPlayer.play("fade_in")
	yield($AnimationPlayer, "animation_finished")
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func clear_queue() -> void:
	scene_queue.clear()


func queue(path: String, params: Dictionary = {}) -> void:
	scene_queue.append({ "path": path, "params": params })


func next() -> bool:
	var next_transition: Dictionary = scene_queue.pop_front()
	print(next_transition.path)
	if next_transition != null:
		to(next_transition.path, next_transition.params)
		return true
	else:
		return false
