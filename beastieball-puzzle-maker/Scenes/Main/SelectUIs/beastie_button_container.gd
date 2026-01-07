@tool
class_name BeastieButtonContainer
extends GridContainer

const BEASTIE_BUTTON = preload("uid://dpfyarbgjk6l4")

@export var show_name : bool = true :
	set(value):
		show_name = value
		update()


var all_beasties_data_sorted : Array[Beastie] = []


func _ready() -> void:
	_assign_all_data_arrays()
	update()


func _assign_all_data_arrays() -> void:
	all_beasties_data_sorted = Global.all_beasties_data.duplicate()
	all_beasties_data_sorted.sort_custom(func(b1 : Beastie, b2 : Beastie):
		return b1.beastiepedia_id < b2.beastiepedia_id
	)


func update() -> void:
	if not is_node_ready():
		await ready

	for child : BeastieButton in get_children():
		child.queue_free()

	self.columns = 4 if show_name else 11

	for beastie : Beastie in all_beasties_data_sorted:
		var new_button : BeastieButton = BEASTIE_BUTTON.instantiate()
		new_button.beastie = beastie
		new_button.show_name = show_name
		add_child(new_button)
