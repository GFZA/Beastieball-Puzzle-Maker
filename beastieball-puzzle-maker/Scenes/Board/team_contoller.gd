@tool
class_name TeamController
extends Node2D

signal field_updated(pos_dict : Dictionary[Beastie.Position, Beastie])
signal field_effects_updated(field_dict : Dictionary[FieldEffect.Type, int])

enum TeamPosition {FIELD_1, FIELD_2, BENCH_1, BENCH_2}

const BEASTIE_SCENE := preload("uid://dptoj76e40ldo")
const PLAYS_UI_CONTAINER_SCENE : PackedScene = preload("uid://dksxc3rs20kkc")

@export var is_serving_team : bool = false:
	set(value):
		is_serving_team = value
		_update_field()

@export_range(0, 9) var current_score : int = 0:
	set(value):
		current_score = value
		_update_field()

@export var my_field_effects : Dictionary[FieldEffect.Type, int] = {} :
	set(value):
		value.sort()
		my_field_effects = value
		field_effects_updated.emit(my_field_effects)
		_update_field()

@export_group("Serve Slot", "beastie_1_")
@export var beastie_1_beastie : Beastie = null :
	set(value):
		beastie_1_beastie = _process_beastie_value(value)
		_update_field()

@export var beastie_1_position : Beastie.Position = Beastie.Position.UPPER_BACK :
	set(value):
		beastie_1_position = value
		_update_field()

@export var beastie_1_show_play : bool = true :
	set(value):
		beastie_1_show_play = value
		_update_scene_show_plays(beastie_1_beastie, beastie_1_show_play)

@export var beastie_1_show_bench_damage : bool = false :
	set(value):
		beastie_1_show_bench_damage = value
		_update_scene_show_bench_damage(beastie_1_beastie, beastie_1_show_bench_damage)

@export var beastie_1_have_ball : bool = false :
	set(value):
		beastie_1_have_ball = value
		_update_scene_have_ball(beastie_1_beastie, beastie_1_have_ball)

@export var beastie_1_ball_type : BeastieScene.BallType = BeastieScene.BallType.EASY_RECEIVE :
	set(value):
		beastie_1_ball_type = value
		_update_scene_ball_type(beastie_1_beastie, beastie_1_ball_type)

@export var beastie_1_h_allign : HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER :
	set(value):
		beastie_1_h_allign = value
		_update_scene_h_align(beastie_1_beastie, beastie_1_h_allign)

@export_group("Non-serve Slot", "beastie_2_")
@export var beastie_2_beastie : Beastie = null :
	set(value):
		beastie_2_beastie = _process_beastie_value(value)
		_update_field()

@export var beastie_2_position : Beastie.Position = Beastie.Position.LOWER_BACK :
	set(value):
		beastie_2_position = value
		_update_field()

@export var beastie_2_show_play : bool = true :
	set(value):
		beastie_2_show_play = value
		_update_scene_show_plays(beastie_2_beastie, beastie_2_show_play)

@export var beastie_2_show_bench_damage : bool = false :
	set(value):
		beastie_2_show_bench_damage = value
		_update_scene_show_bench_damage(beastie_2_beastie, beastie_2_show_bench_damage)

@export var beastie_2_have_ball : bool = false :
	set(value):
		beastie_2_have_ball = value
		_update_scene_have_ball(beastie_2_beastie, beastie_2_have_ball)

@export var beastie_2_ball_type : BeastieScene.BallType = BeastieScene.BallType.EASY_RECEIVE :
	set(value):
		beastie_2_ball_type = value
		_update_scene_ball_type(beastie_2_beastie, beastie_2_ball_type)

@export var beastie_2_h_allign : HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER :
	set(value):
		beastie_2_h_allign = value
		_update_scene_h_align(beastie_2_beastie, beastie_2_h_allign)

@export_group("Bench 1", "bench_beastie_1_")
@export var bench_beastie_1_beastie : Beastie = null :
	set(value):
		bench_beastie_1_beastie = _process_beastie_value(value, true)
		_update_field()

@export var bench_beastie_1_show_play : bool = true :
	set(value):
		bench_beastie_1_show_play = value
		_update_scene_show_plays(bench_beastie_1_beastie, bench_beastie_1_show_play)

@export var bench_beastie_1_h_allign : HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER :
	set(value):
		bench_beastie_1_h_allign = value
		_update_scene_h_align(bench_beastie_1_beastie, bench_beastie_1_h_allign)

@export_group("Bench 2", "bench_beastie_2_")
@export var bench_beastie_2_beastie : Beastie = null :
	set(value):
		bench_beastie_2_beastie = _process_beastie_value(value, true)
		_update_field()

@export var bench_beastie_2_show_play : bool = true :
	set(value):
		bench_beastie_2_show_play = value
		_update_scene_show_plays(bench_beastie_2_beastie, bench_beastie_2_show_play)

@export var bench_beastie_2_h_allign : HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER :
	set(value):
		bench_beastie_2_h_allign = value
		_update_scene_h_align(bench_beastie_2_beastie, bench_beastie_2_h_allign)

@export_group("Inner vars")
@export var side : Global.MySide = Global.MySide.LEFT

@export_subgroup("Reset Team NO UNDO!")
@export_tool_button("Reset Team") var reset_team_var : Callable = reset_team

var position_anchors : Array[Node] = []
var bench_position_anchors : Array[Node] = []
var plays_ui_container_anchors : Array[Node] = []
var bench_plays_ui_container_anchors : Array[Node] = []

var beastie_scene_dict : Dictionary[Beastie, BeastieScene] = {}
var plays_ui_container_dict : Dictionary[Beastie, PlaysUIContainer] = {}


func _ready() -> void:
	var all_children : Array[Node] = get_children()
	# Bad practice as this whole thing need exact position of node to work...
	# Sorry future me or whoever decided to view this abomination...
	position_anchors = all_children[0].get_children()
	bench_position_anchors = all_children[1].get_children()
	plays_ui_container_anchors = all_children[2].get_children()
	bench_plays_ui_container_anchors = all_children[3].get_children()

	_update_field()


func _process_beastie_value(value : Beastie, benched : bool = false) -> Beastie:
	if not value:
		return null

	var processed_value = value # Don't duplicate so it's the same with AddBeastieUI's beastie
	processed_value.my_side = side
	if processed_value.health_updated.is_connected(_update_field):
		processed_value.health_updated.connect(_update_field.unbind(1))
	if processed_value.my_plays_updated.is_connected(_update_field):
		processed_value.my_plays_updated.connect(_update_field.unbind(1))
	if processed_value.my_trait_updated.is_connected(_update_field):
		processed_value.my_trait_updated.connect(_update_field.unbind(1))
	if processed_value.current_boosts_updated.is_connected(_update_field):
		processed_value.current_boosts_updated.connect(_update_field.unbind(1))
	if processed_value.current_feelings_updated.is_connected(_update_field):
		processed_value.current_feelings_updated.connect(_update_field.unbind(1))
	processed_value.is_really_at_bench = benched
	return processed_value


func _update_field() -> void:
	if not is_node_ready():
		await ready


	for marker : Marker2D in position_anchors:
		for child in marker.get_children():
			child.queue_free()

	for marker : Marker2D in bench_position_anchors:
		for child in marker.get_children():
			child.queue_free()

	for marker : Marker2D in plays_ui_container_anchors:
		for child in marker.get_children():
			child.queue_free()

	for marker : Marker2D in bench_plays_ui_container_anchors:
		for child in marker.get_children():
			child.queue_free()

	beastie_scene_dict.clear()
	plays_ui_container_dict.clear()

	if Global.resetting: # this simple line greatly decrease reset speed! wow!
		return

	if beastie_1_beastie:
		_add_new_beastie_scene(beastie_1_beastie, beastie_1_position, beastie_1_show_play, beastie_1_show_bench_damage)
		_update_scene_show_plays(beastie_1_beastie, beastie_1_show_play)
		_update_scene_show_bench_damage(beastie_1_beastie, beastie_1_show_bench_damage)
		_update_scene_have_ball(beastie_1_beastie, beastie_1_have_ball)
		_update_scene_ball_type(beastie_1_beastie, beastie_1_ball_type)
		_update_scene_h_align(beastie_1_beastie, beastie_1_h_allign)

	if beastie_2_beastie:
		_add_new_beastie_scene(beastie_2_beastie, beastie_2_position, beastie_2_show_play, beastie_2_show_bench_damage)
		_update_scene_show_plays(beastie_2_beastie, beastie_2_show_play)
		_update_scene_show_bench_damage(beastie_2_beastie, beastie_2_show_bench_damage)
		_update_scene_have_ball(beastie_2_beastie, beastie_2_have_ball)
		_update_scene_ball_type(beastie_2_beastie, beastie_2_ball_type)
		_update_scene_h_align(beastie_2_beastie, beastie_2_h_allign)

	if beastie_1_beastie and beastie_2_beastie: # Weird place to assign these?
		beastie_1_beastie.ally_field_position = beastie_2_position
		beastie_2_beastie.ally_field_position = beastie_1_position

	if bench_beastie_1_beastie:
		_add_new_beastie_scene(bench_beastie_1_beastie, Beastie.Position.BENCH_1, bench_beastie_1_show_play, false)
		_update_scene_show_plays(bench_beastie_1_beastie, bench_beastie_1_show_play)
		_update_scene_h_align(bench_beastie_1_beastie, bench_beastie_1_h_allign)

	if bench_beastie_2_beastie:
		_add_new_beastie_scene(bench_beastie_2_beastie, Beastie.Position.BENCH_2, bench_beastie_2_show_play, false)
		_update_scene_show_plays(bench_beastie_2_beastie, bench_beastie_2_show_play)
		_update_scene_h_align(bench_beastie_2_beastie, bench_beastie_2_h_allign)

	field_updated.emit(get_position_dict())


func get_position_dict() -> Dictionary[Beastie.Position, Beastie]:
	var result : Dictionary[Beastie.Position, Beastie] = get_empty_position_dict()
	result[beastie_1_position] = beastie_1_beastie
	result[beastie_2_position] = beastie_2_beastie
	result[Beastie.Position.BENCH_1] = bench_beastie_1_beastie
	result[Beastie.Position.BENCH_2] = bench_beastie_2_beastie
	return result


static func get_empty_position_dict() -> Dictionary[Beastie.Position, Beastie]:
	return {
		Beastie.Position.UPPER_BACK : null,
		Beastie.Position.UPPER_FRONT : null,
		Beastie.Position.LOWER_BACK : null,
		Beastie.Position.LOWER_FRONT : null,
		Beastie.Position.BENCH_1 : null,
		Beastie.Position.BENCH_2 : null
	}


func _add_new_beastie_scene(beastie : Beastie, new_position : Beastie.Position, show_play : bool, show_bench_damage : bool) -> void:
	beastie.my_field_position = new_position # Assign position into the resource
	var new_scene : BeastieScene = BEASTIE_SCENE.instantiate()
	new_scene.beastie = beastie
	new_scene.my_side = side

	match new_position:
		Beastie.Position.BENCH_1, Beastie.Position.BENCH_2:
			if _check_bench_size() == 1:
				bench_position_anchors[1].add_child(new_scene) # Add to middle anchor to look nice
			else:
				if new_position == Beastie.Position.BENCH_1:
					bench_position_anchors[0].add_child(new_scene)
				if new_position == Beastie.Position.BENCH_2:
					bench_position_anchors[2].add_child(new_scene)
		_: # Field
			var index : int = int(new_position)
			position_anchors[index].add_child(new_scene)

	beastie_scene_dict[beastie] = new_scene
	_add_new_plays_ui_container(new_scene, show_play, show_bench_damage)


func _add_new_plays_ui_container(beastie_scene : BeastieScene, show_play : bool, show_bench_damage : bool) -> void:
	var beastie : Beastie = beastie_scene.beastie
	var pos : Beastie.Position = beastie.my_field_position
	var new_scene : PlaysUIContainer = PLAYS_UI_CONTAINER_SCENE.instantiate()
	new_scene.my_side = side
	new_scene.beastie = beastie
	new_scene.show_bench_damage = show_bench_damage
	new_scene.team_controller = self

	match pos:
		Beastie.Position.BENCH_1, Beastie.Position.BENCH_2:
			if _check_bench_size() == 1:
				# Offset it a little bit down to look nice
				bench_plays_ui_container_anchors[0].add_child(new_scene)
				new_scene.position.y += 100.0
			else:
				if pos == Beastie.Position.BENCH_1:
					bench_plays_ui_container_anchors[0].add_child(new_scene)
				if pos == Beastie.Position.BENCH_2:
					bench_plays_ui_container_anchors[1].add_child(new_scene)
		_: # Field
			if not show_bench_damage:
				var index : int = int(pos)
				plays_ui_container_anchors[index].add_child(new_scene)
			else:
				if pos in [Beastie.Position.UPPER_BACK, Beastie.Position.UPPER_FRONT]:
					plays_ui_container_anchors[4].add_child(new_scene) # Upper Middle PlaysUI Anchor
				if pos in [Beastie.Position.LOWER_BACK, Beastie.Position.LOWER_FRONT]:
					plays_ui_container_anchors[5].add_child(new_scene) # Lower Middle PlaysUI Anchor

	if not show_play:
		new_scene.hide()

	plays_ui_container_dict[beastie] = new_scene


func _update_scene_show_plays(beastie : Beastie, show_plays : bool) -> void:
	if not is_node_ready():
		await ready
	var scene : PlaysUIContainer = plays_ui_container_dict.get(beastie)
	if scene:
		scene.visible = show_plays


func _update_scene_show_bench_damage(beastie : Beastie, show_bench_damage : bool) -> void:
	if not is_node_ready():
		await ready
	var scene : PlaysUIContainer = plays_ui_container_dict.get(beastie)
	if scene:
		scene.show_bench_damage = show_bench_damage

		if not show_bench_damage:
			var index : int = int(beastie.my_field_position)
			scene.reparent(plays_ui_container_anchors[index], false)
		else:
			if beastie.my_field_position in [Beastie.Position.UPPER_BACK, Beastie.Position.UPPER_FRONT]:
				scene.reparent(plays_ui_container_anchors[4], false) # Upper Middle PlaysUI Anchor
			if beastie.my_field_position in [Beastie.Position.LOWER_BACK, Beastie.Position.LOWER_FRONT]:
				scene.reparent(plays_ui_container_anchors[5], false) # Lower Middle PlaysUI Anchor


func _update_scene_have_ball(beastie : Beastie, have_ball : bool) -> void:
	if not is_node_ready():
		await ready
	var scene : BeastieScene = beastie_scene_dict.get(beastie)
	if scene:
		scene.have_ball = have_ball


func _update_scene_ball_type(beastie : Beastie, ball_type : BeastieScene.BallType) -> void:
	if not is_node_ready():
		await ready
	var scene : BeastieScene = beastie_scene_dict.get(beastie)
	if scene:
		scene.ball_type = ball_type


func _update_scene_h_align(beastie : Beastie, h_allign : HorizontalAlignment) -> void:
	if not is_node_ready():
		await ready
	var scene : BeastieScene = beastie_scene_dict.get(beastie)
	if scene:
		scene.h_allign = h_allign


func _check_bench_size() -> int:
	var count : int = 0
	if bench_beastie_1_beastie: count += 1
	if bench_beastie_2_beastie: count += 1
	return count


func swap_slot(team_pos_1 : TeamPosition, team_pos_2 : TeamPosition) -> void:
	var slot_1_beastie : Beastie = _get_beastie_from_team_pos(team_pos_1)
	var slot_2_beastie : Beastie = _get_beastie_from_team_pos(team_pos_2)

	var	count : int = 0
	for team_pos in [team_pos_1, team_pos_2]:
		var beastie : Beastie = slot_2_beastie if count == 0 else slot_1_beastie
		match team_pos:
			TeamController.TeamPosition.FIELD_1:
				beastie_1_beastie = beastie
			TeamController.TeamPosition.FIELD_2:
				beastie_2_beastie = beastie
			TeamController.TeamPosition.BENCH_1:
				bench_beastie_1_beastie = beastie
				if bench_beastie_1_beastie:
					bench_beastie_1_beastie.current_boosts.clear() # Clear boosts when benched, just like in-game!
			TeamController.TeamPosition.BENCH_2:
				bench_beastie_2_beastie = beastie
				if bench_beastie_2_beastie:
					bench_beastie_2_beastie.current_boosts.clear() # Clear boosts when benched, just like in-game!
		count += 1


func _get_beastie_from_team_pos(team_pos : TeamPosition) -> Beastie:
	match team_pos:
		TeamController.TeamPosition.FIELD_1:
			return beastie_1_beastie
		TeamController.TeamPosition.FIELD_2:
			return beastie_2_beastie
		TeamController.TeamPosition.BENCH_1:
			return bench_beastie_1_beastie
		TeamController.TeamPosition.BENCH_2:
			return bench_beastie_2_beastie
	return null # Shouldn't happen


func reset_team() -> void:
	reset_beastie_1()
	reset_beastie_2()
	reset_bench_beastie_1()
	reset_bench_beastie_2()


func reset_beastie_1() -> void:
	beastie_1_beastie = null
	beastie_1_position = Beastie.Position.UPPER_BACK
	beastie_1_show_play = true
	beastie_1_show_bench_damage = false
	beastie_1_have_ball = false
	beastie_1_ball_type = BeastieScene.BallType.EASY_RECEIVE
	beastie_1_h_allign = HORIZONTAL_ALIGNMENT_CENTER


func reset_beastie_2() -> void:
	beastie_2_beastie = null
	beastie_2_position = Beastie.Position.LOWER_BACK
	beastie_2_show_play = true
	beastie_2_show_bench_damage = false
	beastie_2_have_ball = false
	beastie_2_ball_type = BeastieScene.BallType.EASY_RECEIVE
	beastie_2_h_allign = HORIZONTAL_ALIGNMENT_CENTER


func reset_bench_beastie_1() -> void:
	bench_beastie_1_beastie = null
	bench_beastie_1_show_play = true
	bench_beastie_1_h_allign = HORIZONTAL_ALIGNMENT_CENTER


func reset_bench_beastie_2() -> void:
	bench_beastie_2_beastie = null
	bench_beastie_2_show_play = true
	bench_beastie_2_h_allign = HORIZONTAL_ALIGNMENT_CENTER



# Exclusive to Right TeamController
# Use to copy RALLY and DREAD from right's my_field_effects
# as these will always be the samw between the two
func copy_middle_field_effects_from_another_controller(another_team_dict : Dictionary[FieldEffect.Type, int]) -> void:
	if another_team_dict.has(FieldEffect.Type.RALLY):
		var rally_stack : int = another_team_dict.get(FieldEffect.Type.RALLY)
		my_field_effects[FieldEffect.Type.RALLY] = rally_stack
	elif my_field_effects.has(FieldEffect.Type.RALLY):
		my_field_effects.erase(FieldEffect.Type.RALLY)

	if another_team_dict.has(FieldEffect.Type.DREAD):
		var dread_stack : int = another_team_dict.get(FieldEffect.Type.DREAD)
		my_field_effects[FieldEffect.Type.DREAD] = dread_stack
	elif my_field_effects.has(FieldEffect.Type.DREAD):
		my_field_effects.erase(FieldEffect.Type.DREAD)


#region Fuctions for Condition Checking

func check_if_serving() -> bool:
	return is_serving_team


func check_if_have_wiped() -> bool:
	for beastie : Beastie in beastie_scene_dict.keys():
		if beastie.get_feeling_stack(Beastie.Feelings.WIPED) > 0:
			return true
	return false


func check_for_cheerleader_buff(beastie_to_check : Beastie) -> bool:
	var cheerleader_count : int = 0
	for beastie : Beastie in beastie_scene_dict.keys():
		if beastie.is_really_at_bench:
			continue
		if beastie.my_trait.name.to_lower() == "cheerleader":
			cheerleader_count += 1
	match cheerleader_count:
		0:
			return false
		1:
			# Cheerleader beastie can't buff itself
			if beastie_to_check.my_trait.name.to_lower() == "cheerleader":
				return false
			return true
		_: # Since two cheerleader basically buff everyone, we can just cheese it like this lol
			return true


func check_for_friendship_buff(beastie_to_check : Beastie) -> bool:
	var friendship_count : int = 0
	for beastie : Beastie in beastie_scene_dict.keys():
		if beastie.my_trait.name.to_lower() == "friendship" \
			and beastie.my_field_position not in [Beastie.Position.BENCH_1, Beastie.Position.BENCH_2]:
			friendship_count += 1

	match friendship_count:
		0:
			return false
		1:
			# Cheerleader beastie can't buff itself
			if beastie_to_check.my_trait.name.to_lower() == "friendship":
				return false
			return true
		_: # Since two friendship basically buff everyone, we can just cheese it like this lol
			# TECHINALLY ingame twi friendship will x3/4 twice for bench beasties even though it's impossible
			# as you have to tag out friendship for that, so screw that lmao
			return true


func get_fielded_ally(beastie_to_check : Beastie) -> Beastie:
	for beastie : Beastie in beastie_scene_dict.keys():
		if beastie.is_really_at_bench or beastie == beastie_to_check:
			continue
		return beastie
	return null


func get_mimicked_attack_from_ally(mimic_user : Beastie) -> Attack:
	var ally : Beastie = get_fielded_ally(mimic_user)
	if not ally:
		return null
	var ally_first_slot : Plays = ally.my_plays[0]
	if ally_first_slot and ally_first_slot.type in [Plays.Type.ATTACK_BODY, Plays.Type.ATTACK_SPIRIT, Plays.Type.ATTACK_MIND]:
		var new_attack : Attack = ally_first_slot.duplicate(true)
		new_attack.base_pow = ceili(ally_first_slot.base_pow * 1.2)
		new_attack.type = ally_first_slot.type
		new_attack.use_condition = ally_first_slot.use_condition
		new_attack.target = ally_first_slot.target
		return new_attack
	return null

#endregion

#region Field Effects Stuffs

func get_field_effect_stack(field_effect : FieldEffect.Type) -> int:
	if not my_field_effects.has(field_effect):
		return 0
	return my_field_effects.get(field_effect)


func on_rally_stacked_changed(new_stack : int) -> void:
	my_field_effects[FieldEffect.Type.RALLY] = new_stack
	field_effects_updated.emit(my_field_effects)
	_update_field()


func on_dread_stacked_changed(new_stack : int) -> void:
	my_field_effects[FieldEffect.Type.DREAD] = new_stack
	field_effects_updated.emit(my_field_effects)
	_update_field()


func on_rhythm_stacked_changed(new_stack : int) -> void:
	my_field_effects[FieldEffect.Type.RHYTHM] = new_stack
	field_effects_updated.emit(my_field_effects)
	_update_field()


func on_trap_stacked_changed(new_stack : int) -> void:
	my_field_effects[FieldEffect.Type.TRAP] = new_stack
	field_effects_updated.emit(my_field_effects)
	_update_field()


func on_quake_stacked_changed(new_stack : int) -> void:
	my_field_effects[FieldEffect.Type.QUAKE] = new_stack
	field_effects_updated.emit(my_field_effects)
	_update_field()


func on_barrier_upper_stacked_changed(new_stack : int) -> void:
	my_field_effects[FieldEffect.Type.BARRIER_UPPER] = new_stack
	field_effects_updated.emit(my_field_effects)
	_update_field()


func on_barrier_lower_stacked_changed(new_stack : int) -> void:
	my_field_effects[FieldEffect.Type.BARRIER_LOWER] = new_stack
	field_effects_updated.emit(my_field_effects)
	_update_field()

#endregion

#region Save System

# Behold the worse ssavd/load system ever
# TODO make this better. Maybe using JSON?

func get_data_to_save() -> Array:
	return [
		beastie_1_beastie,
		beastie_1_position,
		beastie_1_show_play,
		beastie_1_have_ball,
		beastie_1_ball_type,
		beastie_1_h_allign,

		beastie_2_beastie,
		beastie_2_position,
		beastie_2_show_play,
		beastie_2_have_ball,
		beastie_2_ball_type,
		beastie_2_h_allign,

		bench_beastie_1_beastie,
		bench_beastie_1_show_play,
		bench_beastie_1_h_allign,

		bench_beastie_2_beastie,
		bench_beastie_2_show_play,
		bench_beastie_2_h_allign,
	]

func load_data_from_save(data_array : Array) -> void:
	beastie_1_beastie = data_array[0]
	beastie_1_position = data_array[1]
	beastie_1_show_play = data_array[2]
	beastie_1_have_ball = data_array[3]
	beastie_1_ball_type = data_array[4]
	beastie_1_h_allign = data_array[5]

	beastie_2_beastie = data_array[6]
	beastie_2_position = data_array[7]
	beastie_2_show_play = data_array[8]
	beastie_2_have_ball = data_array[9]
	beastie_2_ball_type = data_array[10]
	beastie_2_h_allign = data_array[11]

	bench_beastie_1_beastie = data_array[12]
	bench_beastie_1_show_play = data_array[13]
	bench_beastie_1_h_allign = data_array[14]

	bench_beastie_2_beastie = data_array[15]
	bench_beastie_2_show_play = data_array[16]
	bench_beastie_2_h_allign = data_array[17]

#endregion
