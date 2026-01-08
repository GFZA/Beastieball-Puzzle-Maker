@tool
class_name TeamController
extends Node2D

signal field_updated(pos_dict : Dictionary[Beastie.Position, Beastie])

const BEASTIE_SCENE := preload("uid://dptoj76e40ldo")

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
		bench_beastie_1_beastie = _process_beastie_value(value)
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
		bench_beastie_2_beastie = _process_beastie_value(value)
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

@export_group("Reset Buttons")
@export_tool_button("Reset Position") var reset_pos_var : Callable = reset_position
@export_subgroup("Reset Team NO UNDO!")
@export_tool_button("Reset Team") var reset_team_var : Callable = reset_team

var position_markers : Array[Node] = []
var bench_position_markers : Array[Node] = []

var beastie_scene_dict : Dictionary[Beastie, BeastieScene] = {
	beastie_1_beastie : null,
	beastie_2_beastie : null,
	bench_beastie_1_beastie : null,
	bench_beastie_2_beastie : null,
}


func _ready() -> void:
	var all_children : Array[Node] = get_children()
	var bench_node_2d : Node2D = null
	for child in all_children:
		if child is not Marker2D:
			bench_node_2d = child
			continue
		position_markers.append(child)
	bench_position_markers = bench_node_2d.get_children()


func _process_beastie_value(value : Beastie) -> Beastie:
	if not value:
		return null

	var processed_value = value.duplicate(true)
	processed_value.my_side = side
	processed_value.health_updated.connect(_update_field.unbind(1))
	processed_value.my_plays_updated.connect(_update_field.unbind(1))
	processed_value.my_trait_updated.connect(_update_field.unbind(1))
	processed_value.current_boosts_updated.connect(_update_field.unbind(1))
	processed_value.current_feelings_updated.connect(_update_field.unbind(1))
	return processed_value


func _update_field() -> void:
	if not is_node_ready():
		await ready

	for marker : Marker2D in position_markers:
		for child in marker.get_children():
			child.queue_free()

	for marker : Marker2D in bench_position_markers:
		for child in marker.get_children():
			child.queue_free()

	beastie_scene_dict.clear()

	if beastie_1_beastie:
		_add_new_beastie_scene(beastie_1_beastie, beastie_1_position)
		_update_scene_show_plays(beastie_1_beastie, beastie_1_show_play)
		_update_scene_show_bench_damage(beastie_1_beastie, beastie_1_show_bench_damage)
		_update_scene_have_ball(beastie_1_beastie, beastie_1_have_ball)
		_update_scene_ball_type(beastie_1_beastie, beastie_1_ball_type)
		_update_scene_h_align(beastie_1_beastie, beastie_1_h_allign)

	if beastie_2_beastie:
		_add_new_beastie_scene(beastie_2_beastie, beastie_2_position)
		_update_scene_show_plays(beastie_2_beastie, beastie_2_show_play)
		_update_scene_show_bench_damage(beastie_2_beastie, beastie_2_show_bench_damage)
		_update_scene_have_ball(beastie_2_beastie, beastie_2_have_ball)
		_update_scene_ball_type(beastie_2_beastie, beastie_2_ball_type)
		_update_scene_h_align(beastie_2_beastie, beastie_2_h_allign)

	if beastie_1_beastie and beastie_2_beastie: # Weird place to assign these?
		beastie_1_beastie.ally_field_position = beastie_2_position
		beastie_2_beastie.ally_field_position = beastie_1_position

	if bench_beastie_1_beastie:
		_add_new_beastie_scene(bench_beastie_1_beastie, Beastie.Position.BENCH_1)
		_update_scene_show_plays(bench_beastie_1_beastie, bench_beastie_1_show_play)
		_update_scene_h_align(bench_beastie_1_beastie, bench_beastie_1_h_allign)

	if bench_beastie_2_beastie:
		_add_new_beastie_scene(bench_beastie_2_beastie, Beastie.Position.BENCH_2)
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


func _add_new_beastie_scene(beastie : Beastie, new_position : Beastie.Position) -> void:
	beastie.my_field_position = new_position # Assign position into the resource
	var new_scene : BeastieScene = BEASTIE_SCENE.instantiate()
	new_scene.beastie = beastie
	new_scene.my_side = side

	if new_position == Beastie.Position.BENCH_1 or new_position == Beastie.Position.BENCH_2:
		new_scene.benched = true
		if _check_bench_size() == 1: # Add to middle bench anchor
			bench_position_markers[1].add_child(new_scene)
		else:
			if new_position == Beastie.Position.BENCH_1:
				bench_position_markers[0].add_child(new_scene)
			elif new_position == Beastie.Position.BENCH_2:
				bench_position_markers[2].add_child(new_scene)
	else:
		var index : int = int(new_position)
		position_markers[index].add_child(new_scene)

	beastie_scene_dict[beastie] = new_scene


func _update_scene_show_plays(beastie : Beastie, show_plays : bool) -> void:
	if not is_node_ready():
		await ready
	var scene : BeastieScene = beastie_scene_dict.get(beastie)
	if scene:
		scene.show_plays = show_plays


func _update_scene_show_bench_damage(beastie : Beastie, show_bench_damage : bool) -> void:
	if not is_node_ready():
		await ready
	var scene : BeastieScene = beastie_scene_dict.get(beastie)
	if scene:
		scene.show_bench_damage = show_bench_damage


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


func reset_team() -> void:
	beastie_1_beastie = null
	beastie_1_show_play = true
	beastie_1_have_ball = false
	beastie_1_ball_type = BeastieScene.BallType.EASY_RECEIVE
	beastie_1_h_allign = HORIZONTAL_ALIGNMENT_CENTER

	beastie_2_beastie = null
	beastie_2_show_play = true
	beastie_2_have_ball = false
	beastie_2_ball_type = BeastieScene.BallType.EASY_RECEIVE
	beastie_2_h_allign = HORIZONTAL_ALIGNMENT_CENTER

	reset_position()

	bench_beastie_1_beastie = null
	bench_beastie_1_show_play = true
	bench_beastie_1_h_allign = HORIZONTAL_ALIGNMENT_CENTER

	bench_beastie_2_beastie = null
	bench_beastie_2_show_play = true
	bench_beastie_2_h_allign = HORIZONTAL_ALIGNMENT_CENTER


func reset_position() -> void:
	beastie_1_position = Beastie.Position.UPPER_BACK
	beastie_2_position = Beastie.Position.LOWER_BACK


func _check_bench_size() -> int:
	var count : int = 0
	if bench_beastie_1_beastie: count += 1
	if bench_beastie_2_beastie: count += 1
	return count


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
