@tool
class_name TeamController
extends Node2D

signal field_updated(pos_dict : Dictionary[Beastie.Position, Beastie])

const BEASTIE_SCENE := preload("uid://dptoj76e40ldo")

@export_group("Serve Slot")
@export var beastie_1 : Beastie = null :
	set(value):
		if value:
			value = value.duplicate(true)
			value.my_side = side
			value.my_plays_updated.connect(_update_field.unbind(1))
			value.my_trait_updated.connect(_update_field.unbind(1))
			value.current_boosts_updated.connect(_update_field.unbind(1))
			value.current_feelings_updated.connect(_update_field.unbind(1))
		beastie_1 = value
		_update_field()

@export var beastie_1_position : Beastie.Position = Beastie.Position.UPPER_BACK :
	set(value):
		beastie_1_position = value
		_update_field()

@export var beastie_1_show_play : bool = true :
	set(value):
		beastie_1_show_play = value
		_update_scene_show_plays(beastie_1, beastie_1_show_play)

@export var beastie_1_have_ball : bool = false :
	set(value):
		beastie_1_have_ball = value
		_update_scene_have_ball(beastie_1, beastie_1_have_ball)

@export var beastie_1_ball_type : BeastieScene.BallType = BeastieScene.BallType.EASY_RECEIVE :
	set(value):
		beastie_1_ball_type = value
		_update_scene_ball_type(beastie_1, beastie_1_ball_type)

@export var beastie_1_lifebar_h_allign : HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER :
	set(value):
		beastie_1_lifebar_h_allign = value
		_update_scene_h_align(beastie_1, beastie_1_lifebar_h_allign)

@export_group("Non-serve Slot")
@export var beastie_2 : Beastie = null :
	set(value):
		if value:
			value = value.duplicate(true)
			value.my_side = side
			value.my_plays_updated.connect(_update_field.unbind(1))
			value.my_trait_updated.connect(_update_field.unbind(1))
			value.current_boosts_updated.connect(_update_field.unbind(1))
			value.current_feelings_updated.connect(_update_field.unbind(1))
		beastie_2 = value
		_update_field()

@export var beastie_2_position : Beastie.Position = Beastie.Position.LOWER_BACK :
	set(value):
		beastie_2_position = value
		_update_field()

@export var beastie_2_show_play : bool = true :
	set(value):
		beastie_2_show_play = value
		_update_scene_show_plays(beastie_2, beastie_2_show_play)

@export var beastie_2_have_ball : bool = false :
	set(value):
		beastie_2_have_ball = value
		_update_scene_have_ball(beastie_2, beastie_2_have_ball)

@export var beastie_2_ball_type : BeastieScene.BallType = BeastieScene.BallType.EASY_RECEIVE :
	set(value):
		beastie_2_ball_type = value
		_update_scene_ball_type(beastie_2, beastie_2_ball_type)

@export var beastie_2_lifebar_h_allign : HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER :
	set(value):
		beastie_2_lifebar_h_allign = value
		_update_scene_h_align(beastie_2, beastie_2_lifebar_h_allign)

@export_group("Bench")
@export var bench_beastie_1 : Beastie = null
@export var bench_beastie_2 : Beastie = null
@export var bench_beastie_3 : Beastie = null

@export_group("Inner vars")
@export var side : Global.MySide = Global.MySide.LEFT

var position_markers : Array[Node] = []
#var bench_position_markers : Array[Node] = [] TODO TODO TODO

var beastie_scene_dict : Dictionary[Beastie, BeastieScene] = {
	beastie_1 : null,
	beastie_2 : null
}


func _ready() -> void:
	position_markers = get_children()


func _update_field() -> void:
	if not is_node_ready():
		await ready

	for marker : Marker2D in position_markers:
		for child in marker.get_children():
			child.queue_free()

	beastie_scene_dict.clear()

	if beastie_1:
		_add_new_beastie_scene(beastie_1, beastie_1_position)
		_update_scene_show_plays(beastie_1, beastie_1_show_play)
		_update_scene_have_ball(beastie_1, beastie_1_have_ball)
		_update_scene_ball_type(beastie_1, beastie_1_ball_type)
		_update_scene_h_align(beastie_1, beastie_1_lifebar_h_allign)

	if beastie_2:
		_add_new_beastie_scene(beastie_2, beastie_2_position)
		_update_scene_show_plays(beastie_2, beastie_2_show_play)
		_update_scene_have_ball(beastie_2, beastie_2_have_ball)
		_update_scene_ball_type(beastie_2, beastie_2_ball_type)
		_update_scene_h_align(beastie_2, beastie_2_lifebar_h_allign)

	if beastie_1 and beastie_2: # Weird place to assign these?
		beastie_1.ally_field_position = beastie_2_position
		beastie_2.ally_field_position = beastie_1_position

	field_updated.emit(get_position_dict())


func get_position_dict() -> Dictionary[Beastie.Position, Beastie]:
	var result : Dictionary[Beastie.Position, Beastie] = {
		Beastie.Position.UPPER_BACK : null,
		Beastie.Position.UPPER_FRONT : null,
		Beastie.Position.LOWER_BACK : null,
		Beastie.Position.LOWER_FRONT : null,
	}
	result[beastie_1_position] = beastie_1
	result[beastie_2_position] = beastie_2
	return result


func _add_new_beastie_scene(beastie : Beastie, new_position : Beastie.Position) -> void:
	beastie.my_field_position = new_position # Assign position into the resource
	var new_scene : BeastieScene = BEASTIE_SCENE.instantiate()
	new_scene.beastie = beastie
	new_scene.my_side = side
	var index : int = int(new_position)
	position_markers[index].add_child(new_scene)
	beastie_scene_dict[beastie] = new_scene


func _update_scene_show_plays(beastie : Beastie, show_plays : bool) -> void:
	if not is_node_ready():
		await ready
	var scene : BeastieScene = beastie_scene_dict.get(beastie)
	if scene:
		scene.show_plays = show_plays


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







#func find_beastie_scene(beastie : Beastie) -> BeastieScene:
	#var all_scene : Array[Node] = get_tree().get_nodes_in_group("beastie_scene")
	#for scene : BeastieScene in all_scene:
		#if scene.beastie == beastie:
			#return scene
	#return null
#
## Functions below are dirty way to access the BeastieScene vars
## Shoule be refactored later I guess...
#
#func _update_show_play(beastie : Beastie, show_play : bool) -> void:
	#if not is_node_ready():
		#await ready
	#await get_tree().process_frame # Need to do this for some reason...
	#if beastie and find_beastie_scene(beastie) != null:
		#find_beastie_scene(beastie).show_plays = show_play
#
#
#func _update_h_align(beastie : Beastie, h_align : HorizontalAlignment) -> void:
	#if not is_node_ready():
		#await ready
	#await get_tree().process_frame # Need to do this for some reason...
	#if beastie and find_beastie_scene(beastie) != null:
		#find_beastie_scene(beastie).h_allign = h_align
#
#
#func _update_have_ball(beastie : Beastie, have_ball : bool) -> void:
	#if not is_node_ready():
		#await ready
	#await get_tree().process_frame # Need to do this for some reason...
	#if beastie and find_beastie_scene(beastie) != null:
		#find_beastie_scene(beastie).have_ball = have_ball
#
#
#func _update_ball_type(beastie : Beastie, ball_type : BeastieScene.BallType) -> void:
	#if not is_node_ready():
		#await ready
	#await get_tree().process_frame # Need to do this for some reason...
	#if beastie and find_beastie_scene(beastie) != null:
		#find_beastie_scene(beastie).have_ball = ball_type
