@tool
class_name Parallelogram
extends Polygon2D

var flip_h : bool = false :
	set(value):
		if not is_node_ready():
			await ready
		flip_h = value
		if (is_pointing_right() and not flip_h) or\
			(not is_pointing_right() and flip_h):
			_filp()

func _filp() -> void:
	var old_polygon : PackedVector2Array = polygon
	var new_polygon := PackedVector2Array([
		Vector2(old_polygon[1].x, old_polygon[0].y),
		Vector2(old_polygon[0].x, old_polygon[1].y),
		Vector2(old_polygon[3].x, old_polygon[2].y),
		Vector2(old_polygon[2].x, old_polygon[3].y)
	])
	polygon = new_polygon

func is_pointing_right() -> bool:
	return sign(polygon[1].x - polygon[0].x) > 0.0
