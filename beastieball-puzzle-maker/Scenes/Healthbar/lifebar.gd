@tool
class_name LifeBar
extends Control


@export_range(0, 100) var hp : int = 100 :
	set(value):
		hp = value
		_update_bar(value)

@export_color_no_alpha var color : Color = Color.GREEN :
	set(value):
		color = value
		_update_color(color)

@export var my_side : Global.MySide = Global.MySide.LEFT :
	set(value):
		my_side = value
		_update_side(my_side)

var my_setting : LabelSettings = null
var max_health_upper_x : float = 0.0
var max_health_lower_x : float = 0.0
var max_length : float = 0.0
var ref_pos : PackedVector2Array = []

@onready var lifebar_backrground: Parallelogram = %LifebarBackrground
@onready var lifebar_inner_ref: Parallelogram = %LifebarInnerRef
@onready var lifebar_inner: Parallelogram = %LifebarInner
@onready var life_label: Label = %LifeLabel


func _ready() -> void:
	if not is_node_ready():
		await ready

	my_setting = life_label.label_settings.duplicate()
	life_label.label_settings = my_setting

	_update_inner_vars()


func _update_inner_vars() -> void:
	if not is_node_ready():
		await ready
	ref_pos = lifebar_inner_ref.polygon
	max_health_upper_x = ref_pos[2].x
	max_health_lower_x = ref_pos[3].x
	max_length = max_health_upper_x - ref_pos[1].x


func _update_bar(value : int) -> void:
	if not is_node_ready():
		await ready

	lifebar_inner.show()
	if value == 0.0:
		lifebar_inner.hide() # Make it so 0 hp show nothing while 1 hp have little bar left

	life_label.text = str(value)

	var ratio : float = clamp(value, 0.0, 100.0) / 100.0
	var width : float = max(0.0, max_length * ratio)

	var new_polygon := PackedVector2Array([
		Vector2(ref_pos[0].x, ref_pos[0].y),   # bottom-left
		Vector2(ref_pos[1].x, ref_pos[1].y),   # top-left
		Vector2(ref_pos[1].x + width, ref_pos[1].y),  # top_right
		Vector2(ref_pos[0].x + width, ref_pos[0].y)   # bottom-right
	])

	lifebar_inner.polygon = new_polygon


func _update_color(new_color : Color) -> void:
	if not is_node_ready():
		await ready
	lifebar_inner.color = new_color
	my_setting.font_color = new_color


func _update_side(new_side : Global.MySide) -> void:
	if not is_node_ready():
		await ready
	lifebar_inner_ref.flip_h = (new_side == Global.MySide.LEFT)
	lifebar_inner.flip_h = (new_side == Global.MySide.LEFT)
	lifebar_backrground.flip_h = (new_side == Global.MySide.LEFT)
	_update_inner_vars()
