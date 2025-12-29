@tool
class_name DamageIndicator
extends MarginContainer

const DAMAGE_SPLASH_SCENE := preload("uid://cbc5i66rtpig1")

@export var attack : Attack = null :
	set(value):
		attack = value
		_update_indicator()

@export var my_side : Global.MySide = Global.MySide.LEFT :
	set(value):
		my_side = value
		_update_indicator()


@onready var straight_upper: Polygon2D = %StraightUpper
@onready var straight_lower: Polygon2D = %StraightLower
@onready var sideway_left: Polygon2D = %SidewayLeft
@onready var sideway_right: Polygon2D = %SidewayRight

@onready var upper_left_anchor: Control = %UpperLeftAnchor
@onready var upper_right_anchor: Control = %UpperRightAnchor
@onready var lower_left_anchor: Control = %LowerLeftAnchor
@onready var lower_right_anchor: Control = %LowerRightAnchor


func _update_indicator() -> void:
	if not is_node_ready():
		await ready

	if not attack:
		_update_lines_color(Color.GREEN)
		_hide_all_lines()
		return

	_update_target_line(attack.target)


func _update_target_line(target_type : Attack.Target) -> void:
	if not is_node_ready():
		await ready

	_hide_all_lines()

	var new_color : Color = Color.GREEN
	if attack:
		var index : int = int(attack.type)
		var color_type := index as Global.ColorType
		new_color = Global.get_main_color(color_type)
	_update_lines_color(new_color)

	match (target_type):
		Attack.Target.STRAIGHT:
			straight_upper.show()
			straight_lower.show()
		Attack.Target.SIDEWAYS:
			sideway_left.show()
			sideway_right.show()
		Attack.Target.FRONT_ONLY:
			if my_side == Global.MySide.LEFT: sideway_left.show()
			if my_side == Global.MySide.RIGHT: sideway_right.show()
		Attack.Target.BACK_ONLY:
			if my_side == Global.MySide.LEFT: sideway_right.show()
			if my_side == Global.MySide.RIGHT: sideway_left.show()


func _hide_all_lines() -> void:
	if not is_node_ready():
		await ready

	straight_upper.hide()
	straight_lower.hide()
	sideway_left.hide()
	sideway_right.hide()


func _update_lines_color(new_color : Color) -> void:
	print(new_color)
	straight_upper.color = new_color
	straight_lower.color = new_color
	sideway_left.color = new_color
	sideway_right.color = new_color
