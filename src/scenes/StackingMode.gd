extends Node2D

const StartMenu: PackedScene = preload("res://src/menus/StartMenu.tscn")
const DeathMenu: PackedScene = preload("res://src/menus/DeathMenu.tscn")
const PaperPatternScn: PackedScene = preload("res://src/scenes/PaperPattern.tscn")
const WeddingScn: PackedScene = preload("res://src/overlay_scenes/Wedding.tscn")
const BirthScn: PackedScene = preload("res://src/overlay_scenes/Birth.tscn")
const PortraitScn: PackedScene = preload("res://src/actors/Portrait.tscn")
const TimeToBaby: float = 5.0

var biological_clock: float = 0
var placing: Portrait = null
var placing_collision: bool = false

func _ready() -> void:
	for x in range(-2, 3):
		for y in range(0, 5):
			var pattern: Sprite = PaperPatternScn.instance()
			pattern.position.x = x * 140
			pattern.position.y = y * 176 - 400
			if abs(x) == 1:
				pattern.position.y += 88
				pattern.flip_v = true
			pattern.camera = $PlayField/Camera2D
			$BackgroundLayer.add_child(pattern)

	var menu = StartMenu.instance()
	$TopCanvas.add_child(menu)
	get_tree().paused = true


func _init_portrait(position: Vector2) -> void:
	var portrait: Portrait = PortraitScn.instance()
	portrait.position = position
	portrait.connect("became_marriage_material", self, "get_married")
	portrait.connect("got_busy", self, "make_a_baby")
	portrait.set_portrait()
	$PortraitLayer.add_child(portrait)


func randomize_start() -> void:
	$PlayField/MaturityLine.visible = true
	$PlayField/BirthingLine.visible = true
	# One adult, one older child, one younger child
	_init_portrait(Vector2(rand_range(-180, 180), -80))
	_init_portrait(Vector2(rand_range(-180, 180), 40))
	_init_portrait(Vector2(rand_range(-180, 180), 135))


func _physics_process(_delta: float) -> void:
	if placing != null:
		update_placing_position()

	var placing_shape: Shape2D = null
	if placing != null:
		placing_shape = placing.find_node("Shape").shape

	placing_collision = false

	if placing != null and get_viewport().get_mouse_position().y < 355:
		placing_collision = true

	for portrait in $PortraitLayer.get_children():
		if portrait == placing:
			continue

		if placing_shape != null and placing_collision == false:
			var portrait_shape: Shape2D = placing.find_node("Shape").shape
			if placing_shape.collide(placing.transform, portrait_shape, portrait.transform):
				placing_collision = true

		if portrait.global_position.y < $PlayField/MaturityLine.global_position.y - 200:
			print("ASCENDED")
			portrait.queue_free()
		elif portrait.global_position.y + 32 < $PlayField/MaturityLine.global_position.y:
			portrait.turn_elderly()
		elif portrait.global_position.y + 32 < $PlayField/BirthingLine.global_position.y:
			portrait.turn_adult()
		elif portrait.global_position.y > $PlayField/MaturityLine.global_position.y + 480:
			var menu = DeathMenu.instance()
			$TopCanvas.add_child(menu)
			menu.make(portrait)
			get_tree().paused = true

	if placing != null:
		for portrait in $PortraitLayer.get_children():
			portrait.can_click = not placing_collision
			
		if placing_collision:
			placing.modulate.r = 0.58
			placing.modulate.g = 0.19
			placing.modulate.b = 0.36
		else:
			placing.modulate.r = 1.0
			placing.modulate.g = 1.0
			placing.modulate.b = 1.0


func update_placing_position() -> void:
	placing.position = get_viewport().get_mouse_position() + $PlayField.position - Vector2(320, 325)


func _on_BirthingZone_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if placing != null and placing_collision == false and \
			event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		placing.collisions_enabled = true
		placing.mode = RigidBody2D.MODE_RIGID
		placing = null
		biological_clock -= TimeToBaby


func play_overlay(overlay_scene: PackedScene) -> void:
	var overlay: Node2D = overlay_scene.instance()
	$TopCanvas.add_child(overlay)


func get_married(married: Portrait) -> void:
	play_overlay(WeddingScn)
	var spouse: Portrait = married.find_spouse()
	spouse.position = married.position + Vector2(64, 0)
	$PortraitLayer.add_child(spouse)


func make_a_baby(parent: Portrait) -> void:
	if placing == null:
		parent.heart_fill = 0.0
		# TODO: Need to do something if there is already a baby on the way.
			# Auto place??
			# Couldn't be a loss, if two people just have a baby at the same time that would be unfair
		play_overlay(BirthScn)
		placing = parent.find_baby()
		placing.mode = RigidBody2D.MODE_STATIC
		placing.connect("became_marriage_material", self, "get_married")
		placing.connect("got_busy", self, "make_a_baby")
		placing.collisions_enabled = false
		$PortraitLayer.add_child(placing)
		update_placing_position()
