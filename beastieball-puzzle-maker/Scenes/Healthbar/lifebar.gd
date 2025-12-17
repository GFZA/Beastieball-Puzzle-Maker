@tool
class_name LifeBar
extends MarginContainer

@export_range(0, 100) var hp : int = 100 :
	set(value):
		hp = value
		_update_bar(value)

var max_health_upper_x : float = 0.0
var max_health_lower_x : float = 0.0
var max_length : float = 0.0
var background_pos : PackedVector2Array = []
var margin : float = 2.0

@onready var lifebar_backrground: Polygon2D = %LifebarBackrground
@onready var lifebar_inner: Polygon2D = %LifebarInner
@onready var life_label: Label = %LifeLabel


func _ready() -> void:
	if not is_node_ready():
		await ready

	background_pos = lifebar_backrground.polygon
	max_health_upper_x = background_pos[2].x
	max_health_lower_x = background_pos[3].x

	var lifebar_pos : PackedVector2Array = lifebar_inner.polygon
	max_length = max_health_upper_x - lifebar_pos[1].x + margin


func _update_bar(value : int) -> void:
	if not is_node_ready():
		await ready

	lifebar_inner.show()
	if value == 0.0:
		lifebar_inner.hide() # Make it so 0 hp show nothing while 1 hp have little bar left

	life_label.text = str(value)

	# This code to draw lifebar is so bad...

	var ratio : float = clamp(value, margin + 0.5, 100) / 100.0
	var width : float = max(5.0, max_length * ratio)

	var new_polygon := PackedVector2Array([
		Vector2(background_pos[0].x + margin - 0.5, background_pos[0].y - margin),   # bottom-left
		Vector2(background_pos[1].x + margin + 0.5, background_pos[1].y + margin),   # top-left
		Vector2(background_pos[1].x + width - margin + 0.5, background_pos[1].y + margin),  # top_right
		Vector2(background_pos[0].x + width - margin - 0.5, background_pos[0].y - margin)   # bottom-right
	])

	lifebar_inner.polygon = new_polygon
