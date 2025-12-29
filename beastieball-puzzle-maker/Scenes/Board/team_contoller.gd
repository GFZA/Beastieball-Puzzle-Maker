@tool
class_name TeamController
extends Node2D

signal field_updated(pos_dict : Dictionary[Beastie.Position, Beastie])

const BEASTIE_SCENE := preload("uid://dptoj76e40ldo")
enum FieldID {ONE, TWO}
enum BenchID {ONE, TWO, THREE}

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
		field_array[0][0] = beastie_1
		_update_field()

@export var beastie_1_position : Beastie.Position = Beastie.Position.UPPER_BACK :
	set(value):
		beastie_1_position = value
		field_array[0][1] = beastie_1_position
		_update_field()

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
		field_array[1][0] = beastie_2
		_update_field()

@export var beastie_2_position : Beastie.Position = Beastie.Position.LOWER_BACK :
	set(value):
		beastie_2_position = value
		field_array[1][1] = beastie_2_position
		_update_field()

@export_group("Bench")
@export var bench_beastie_1 : Beastie = null
@export var bench_beastie_2 : Beastie = null
@export var bench_beastie_3 : Beastie = null

@export_group("Inner vars")
@export var side : Global.MySide = Global.MySide.LEFT

var position_markers : Array[Node] = []
#var bench_position_markers : Array[Node] = [] TODO TODO TODO

var field_array : Array[Array] = [
	[null, Beastie.Position.UPPER_BACK],
	[null, Beastie.Position.LOWER_BACK]
]


func _ready() -> void:
	position_markers = get_children()


func _update_field() -> void:
	if not is_node_ready():
		await ready

	for marker : Marker2D in position_markers:
		for child in marker.get_children():
			child.queue_free()

	for data_array in field_array: # Each data_array is [Beastie, Beastie.Position]
		if data_array[0]:
			data_array[0].my_field_position = data_array[1] # Assign position into the resource
			var new_scene : BeastieScene = BEASTIE_SCENE.instantiate()
			new_scene.beastie = data_array[0]
			new_scene.my_side = side
			var index : int = int(data_array[1])
			position_markers[index].add_child(new_scene)

	if field_array[0][0] and field_array[1][0]: # Vomit-inducing code...
		field_array[0][0].ally_field_position = field_array[1][1]
		field_array[1][0].ally_field_position = field_array[0][1]

	field_updated.emit(get_position_dict())


func get_position_dict() -> Dictionary[Beastie.Position, Beastie]:
	var result : Dictionary[Beastie.Position, Beastie] = {
		Beastie.Position.UPPER_BACK : null,
		Beastie.Position.UPPER_FRONT : null,
		Beastie.Position.LOWER_BACK : null,
		Beastie.Position.LOWER_FRONT : null,
	}
	for data_array in field_array: # Each data_array is [Beastie, Beastie.Position]
		if data_array[0]:
			result[data_array[1]] = data_array[0]
	return result
