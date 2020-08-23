extends RigidBody2D
class_name Portrait

var PortraitScn: PackedScene = load("res://src/actors/Portrait.tscn")

signal became_marriage_material(self_portrait)
signal got_busy(self_portrait)

const BELL_FILL_RATE: float = 7.0
const HEART_FILL_RATE: float = 16.0
const BASE_CONTAINER_Y: float = 16.0
const CONTAINER_HEIGHT: float = 11.0
const MAX_FILL: float = 100.0

const SkinColors: Array = [ "skin1", "skin2", "skin3", "skin4", "skin5" ]
enum Age { BABY, ADULT, ELDERLY }

var collisions_enabled: bool = true setget _set_collisions_enabled
var skin_color: String = Utils.random_entry(SkinColors)
var gender: String = "female" if randf() >= 0.5 else "male"
var maturity: int = Age.BABY setget _set_maturity
var heart_fill: float = 0.0 setget _set_heart_fill
var bell_fill: float = 0.0 setget _set_bell_fill
var spouse: Portrait = null setget _set_spouse
var is_spouse: bool = false setget _set_is_spouse
var can_click: bool = true


func _ready() -> void:
	set_portrait()


func _process(delta: float) -> void:
	if bell_fill == MAX_FILL and not is_spouse and maturity == Age.ADULT:
		self.heart_fill += HEART_FILL_RATE * delta


func marry_up() -> void:
	self.bell_fill += BELL_FILL_RATE


func _set_collisions_enabled(value: bool) -> void:
	if value != collisions_enabled:
		collisions_enabled = value
		call_deferred("_update_collision_mask_and_layer")


func _update_collision_mask_and_layer() -> void:
	set_collision_layer_bit(0, collisions_enabled)
	set_collision_mask_bit(0, collisions_enabled)


func _set_maturity(value: int) -> void:
	if value != maturity:
		maturity = value
		call_deferred("_update_mode")

		if maturity == Age.ADULT:
			$BellFrame.visible = true
			$BellFill.visible = true
		else:
			$HeartFrame.visible = false
			$HeartFill.visible = false
			$BellFrame.visible = false
			$BellFill.visible = false


func turn_elderly() -> void:
	if maturity == Age.ADULT:
		self.maturity = Age.ELDERLY
		set_portrait()

		
func turn_adult() -> void:
	if maturity == Age.BABY:
		self.maturity = Age.ADULT
		set_portrait()


func _update_mode() -> void:
	if maturity == Age.ELDERLY:
		gravity_scale = 1
		mass = 0.1
	else:
		gravity_scale = 0
		mass = 1000


func _set_bell_fill(value: float) -> void:
	var was_full: bool = bell_fill == MAX_FILL
	bell_fill = min(value, MAX_FILL)
	_set_container_rect($BellFill, bell_fill / MAX_FILL)

	if bell_fill == MAX_FILL and not was_full:
		$HeartFrame.visible = true
		$HeartFill.visible = true
		emit_signal("became_marriage_material", self)


func _set_heart_fill(value: float) -> void:
	heart_fill = min(value, MAX_FILL)
	_set_container_rect($HeartFill, heart_fill / MAX_FILL)

	if heart_fill == MAX_FILL:
		if not is_spouse:
			emit_signal("got_busy", self)
	
	if spouse != null:
		spouse.heart_fill = heart_fill


func _set_container_rect(container: Sprite, percent: float) -> void:
	container.region_rect.position.y = CONTAINER_HEIGHT - percent * CONTAINER_HEIGHT
	container.region_rect.size.y = percent * CONTAINER_HEIGHT
	container.position.y = BASE_CONTAINER_Y + CONTAINER_HEIGHT - container.region_rect.size.y


func _on_Portrait_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if Utils.is_click_event(event) and maturity == Age.ADULT and can_click:
		marry_up()


func _set_spouse(value: Portrait) -> void:
	spouse = value
	spouse.is_spouse = true


func _set_is_spouse(value: bool) -> void:
	is_spouse = value
	if is_spouse:
		$HeartFrame.visible = true
		$HeartFill.visible = true
		bell_fill = MAX_FILL
		_set_container_rect($BellFill, bell_fill / MAX_FILL)


func find_spouse() -> Portrait:
	var fiance: Portrait = PortraitScn.instance()
	if randf() > 0.15:
		if gender == "female":
			fiance.gender = "male"
		else:
			fiance.gender = "female"
	else:
		fiance.gender = gender
	fiance.turn_adult()
	self.spouse = fiance
	return fiance


func find_baby() -> Portrait:
	var baby: Portrait = PortraitScn.instance()
	baby.skin_color = Utils.random_entry([skin_color, spouse.skin_color])
	return baby


func age_string() -> String:
	match (maturity):
		Age.BABY:
			return "child"
		Age.ADULT:
			return "adult"
		Age.ELDERLY:
			return "senior"
		_:
			return ""


func set_portrait() -> void:
	$Person.texture = load(str("res://assets/img/people/", skin_color, "_", gender, "_", age_string(), ".png"))
