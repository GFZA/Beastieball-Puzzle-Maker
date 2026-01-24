@tool
class_name BigNumberContainer
extends MarginContainer

const DAMAGE_SPLASH_SCENE := preload("uid://cbc5i66rtpig1")
const EMPTY_DAMAGE_DICT : Dictionary[Beastie.Position, int] = {
		Beastie.Position.UPPER_BACK : -1,
		Beastie.Position.UPPER_FRONT : -1,
		Beastie.Position.LOWER_BACK : -1,
		Beastie.Position.LOWER_FRONT : -1,
	}


@export var damage_dict_array : Array[Dictionary] = [EMPTY_DAMAGE_DICT.duplicate(), EMPTY_DAMAGE_DICT.duplicate()] :
	set(value):
		value.sort()
		damage_dict_array = value
		_update_indicator()

@export var attack : Attack = null :
	set(value):
		attack = value
		_update_indicator()

@export var my_side : Global.MySide = Global.MySide.LEFT :
	set(value):
		my_side = value
		_update_side()

@export var show_bench_damage : bool = false :
	set(value):
		show_bench_damage = value
		_update_show_bench_damage()

@onready var main_container: HBoxContainer = %MainContainer
@onready var board_side_main_node: Control = %BoardSideMainNode
@onready var bench_side_main_node: Control = %BenchSideMainNode

@onready var straight_upper: Polygon2D = %StraightUpper
@onready var straight_lower: Polygon2D = %StraightLower
@onready var sideway_left: Polygon2D = %SidewayLeft
@onready var sideway_right: Polygon2D = %SidewayRight

@onready var upper_left_anchor: Control = %UpperLeftAnchor
@onready var upper_right_anchor: Control = %UpperRightAnchor
@onready var lower_left_anchor: Control = %LowerLeftAnchor
@onready var lower_right_anchor: Control = %LowerRightAnchor
@onready var splash_anchors : Array[Control] = [upper_left_anchor, upper_right_anchor, lower_left_anchor, lower_right_anchor]

@onready var bench_upper_left_anchor: Control = %BenchUpperLeftAnchor
@onready var bench_upper_right_anchor: Control = %BenchUpperRightAnchor
@onready var bench_lower_left_anchor: Control = %BenchLowerLeftAnchor
@onready var bench_lower_right_anchor: Control = %BenchLowerRightAnchor
@onready var bench_splash_anchors : Array[Control] = [bench_upper_left_anchor, bench_upper_right_anchor, bench_lower_left_anchor, bench_lower_right_anchor]

@onready var lane_label_container: HBoxContainer = %LaneLabelContainer
@onready var front_label: Label = %FrontLabel
@onready var back_label: Label = %BackLabel

@onready var attacker_pos_label: Label = %AttackerPosLabel


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
	_update_attacker_pos_labels()


func _update_splashes() -> void:
	if not is_node_ready():
		await ready

	for anchor in splash_anchors:
		for child in anchor.get_children():
			child.queue_free()

	for anchor in bench_splash_anchors:
		for child in anchor.get_children():
			child.queue_free()

	var count : int = 0  # Update Board Dict then Bench Dict
	for damage_dict : Dictionary[Beastie.Position, int] in damage_dict_array:
		for pos : Beastie.Position in damage_dict:
			if damage_dict[pos] == -1:
				continue

			var anchors_array : Array[Control] = splash_anchors if count == 0 else bench_splash_anchors
			match my_side:
										# 			   || 1 | 0
				Global.MySide.LEFT:		# 	my_side -> || -----
										# 			   || 3 | 2
					match pos:
						Beastie.Position.UPPER_BACK: # 0
							_add_damage_splash(anchors_array[1], damage_dict[pos]) # Upper RIGHT anchor
						Beastie.Position.UPPER_FRONT: # 1
							_add_damage_splash(anchors_array[0], damage_dict[pos]) # Upper LEFT anchor
						Beastie.Position.LOWER_BACK: # 2
							_add_damage_splash(anchors_array[3], damage_dict[pos]) # Lower RIGHT anchor
						Beastie.Position.LOWER_FRONT: # 3
							_add_damage_splash(anchors_array[2], damage_dict[pos]) # Lower LEFT anchor

										# 0 | 1 ||
				Global.MySide.RIGHT:	# ----- || <- my_side
										# 2 | 3 ||
					match pos:
						Beastie.Position.UPPER_BACK: # 0
							_add_damage_splash(anchors_array[0], damage_dict[pos]) # Upper LEFT anchor
						Beastie.Position.UPPER_FRONT: # 1
							_add_damage_splash(anchors_array[1], damage_dict[pos]) # Upper RIGHT anchor
						Beastie.Position.LOWER_BACK: # 2
							_add_damage_splash(anchors_array[2], damage_dict[pos]) # Lower LEFT anchor
						Beastie.Position.LOWER_FRONT: # 3
							_add_damage_splash(anchors_array[3], damage_dict[pos]) # Lower RIGHT anchor
		count += 1


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


func _update_lane_labels() -> void:
	if not is_node_ready():
		await ready

	var new_index : int = 0 if my_side == Global.MySide.LEFT else 1
	lane_label_container.move_child(front_label, new_index)


func _update_attacker_pos_labels() -> void:
	if not is_node_ready():
		await ready

	attacker_pos_label.hide()
	if not attack:
		return

	var new_text : String = ""
	if attack.use_condition == Attack.UseCondition.FRONT_ONLY:
		new_text = "WHEN AT NET"
	if attack.use_condition == Attack.UseCondition.BACK_ONLY:
		new_text = "WHEN AT BACK"
	if attack.manually_activated:
		new_text = attack.manual_condition_name

	attacker_pos_label.text = new_text
	attacker_pos_label.show()


func _update_side() -> void:
	if not is_node_ready():
		await ready

	var new_index : int = 0 if my_side == Global.MySide.LEFT else 1
	main_container.move_child(board_side_main_node, new_index)

	_update_lane_labels()
	_update_indicator()


func _update_show_bench_damage() -> void:
	if not is_node_ready():
		await ready

	bench_side_main_node.visible = show_bench_damage
