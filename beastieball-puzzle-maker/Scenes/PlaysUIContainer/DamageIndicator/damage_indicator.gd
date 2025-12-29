@tool
class_name DamageIndicator
extends MarginContainer

const DAMAGE_SPLASH_SCENE := preload("uid://cbc5i66rtpig1")
const EMPTY_DAMAGE_DICT : Dictionary[Beastie.Position, int] = {
		Beastie.Position.UPPER_BACK : -1,
		Beastie.Position.UPPER_FRONT : -1,
		Beastie.Position.LOWER_BACK : -1,
		Beastie.Position.LOWER_FRONT : -1,
	}

@export var damage_dict : Dictionary[Beastie.Position, int] = EMPTY_DAMAGE_DICT :
	set(value):
		value.sort()
		damage_dict = value
		_update_indicator()

@export var attack : Attack = null : # Use this for color lol. The damage is handled via the dict already
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
@onready var splash_anchors : Array[Control] = [upper_left_anchor, upper_right_anchor, lower_left_anchor, lower_right_anchor]


func _update_indicator() -> void:
	if not is_node_ready():
		await ready

	if not attack:
		_update_lines_color(Color.GREEN)
		_hide_all_lines()
		_update_splashes()
		return

	_update_target_line(attack.target)
	_update_splashes()


func _update_splashes() -> void:
	if not is_node_ready():
		await ready

	for anchor in splash_anchors:
		for child in anchor.get_children():
			child.queue_free()

	for pos : Beastie.Position in damage_dict:
		if damage_dict[pos] == -1:
			continue

		match my_side:
									# 			   || 1 | 0
			Global.MySide.LEFT:		# 	my_side -> || -----
									# 			   || 3 | 2
				match pos:
					Beastie.Position.UPPER_BACK: # 0
						_add_damage_splash(upper_right_anchor, damage_dict[pos])
					Beastie.Position.UPPER_FRONT: # 1
						_add_damage_splash(upper_left_anchor, damage_dict[pos])
					Beastie.Position.LOWER_BACK: # 2
						_add_damage_splash(lower_right_anchor, damage_dict[pos])
					Beastie.Position.LOWER_FRONT: # 3
						_add_damage_splash(lower_left_anchor, damage_dict[pos])

									# 0 | 1 ||
			Global.MySide.RIGHT:	# ----- || <- my_side
									# 2 | 3 ||
				match pos:
					Beastie.Position.UPPER_BACK: # 0
						_add_damage_splash(upper_left_anchor, damage_dict[pos])
					Beastie.Position.UPPER_FRONT: # 1
						_add_damage_splash(upper_right_anchor, damage_dict[pos])
					Beastie.Position.LOWER_BACK: # 2
						_add_damage_splash(lower_left_anchor, damage_dict[pos])
					Beastie.Position.LOWER_FRONT: # 3
						_add_damage_splash(lower_right_anchor, damage_dict[pos])


func _add_damage_splash(anchor : Control, damage : int) -> void:
	var new_splash : DamageSplash = DAMAGE_SPLASH_SCENE.instantiate()
	new_splash.amount = damage
	new_splash.attack = attack
	anchor.add_child(new_splash)


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
	straight_upper.color = new_color
	straight_lower.color = new_color
	sideway_left.color = new_color
	sideway_right.color = new_color
