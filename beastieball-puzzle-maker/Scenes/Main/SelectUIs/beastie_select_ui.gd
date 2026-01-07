@tool
class_name BeastieSelectUI
extends Control

signal beastie_selected(beastie : Beastie)

const BEASTIE_BUTTON = preload("uid://dpfyarbgjk6l4")

@export var show_name : bool = true :
	set(value):
		show_name = value
		_update_grid()

var all_beasties_data_sorted : Array[Beastie] = []

var current_search_string : String = "" :
	set(value):
		current_search_string = value
		_update_grid()

@onready var beastie_button_container: GridContainer = %BeastieButtonContainer
@onready var search_bar: LineEdit = %SearchBar
@onready var show_name_check_box: CheckBox = %ShowNameCheckBox
@onready var only_full_morphs_label_check_box: CheckBox = %OnlyFullMorphsLabelCheckBox


func _ready() -> void:
	search_bar.text_changed.connect(func(new_text : String): current_search_string = new_text)
	show_name_check_box.toggled.connect(func(is_toggled : bool): show_name = is_toggled)
	only_full_morphs_label_check_box.toggled.connect(func(is_toggled : bool): print("Only Full Morphs : %s" % str(is_toggled)))

	_assign_all_data_arrays()
	_update_grid()


func _assign_all_data_arrays() -> void:
	all_beasties_data_sorted = Global.all_beasties_data.duplicate()
	all_beasties_data_sorted.sort_custom(func(b1 : Beastie, b2 : Beastie):
		return b1.beastiepedia_id < b2.beastiepedia_id
	)


func _get_filtered_array(search_string : String) -> Array[Beastie]:
	if search_string == "":
		return all_beasties_data_sorted.duplicate()

	var result : Array[Beastie] = []
	for beastie : Beastie in all_beasties_data_sorted:
		if beastie and \
		(beastie.specie_name.to_lower().begins_with(search_string.to_lower()) or \
		(beastie.beastiepedia_id == search_string.to_int())):
			result.append(beastie)
	return result


func _update_grid() -> void:
	if not is_node_ready():
		await ready

	for child : BeastieButton in beastie_button_container.get_children():
		if child.beastie_selected.is_connected(self.beastie_selected.emit):
			child.beastie_selected.disconnect(self.beastie_selected.emit)
		child.queue_free()

	beastie_button_container.columns = 4 if show_name else 11

	var beastie_array : Array[Beastie] = _get_filtered_array(current_search_string)
	beastie_array.push_front(null) # Add None Button here

	for beastie : Beastie in beastie_array:
		var new_button : BeastieButton = BEASTIE_BUTTON.instantiate()
		new_button.beastie = beastie
		new_button.show_name = show_name
		new_button.beastie_selected.connect(self.beastie_selected.emit)
		beastie_button_container.add_child(new_button)


func reset() -> void:
	current_search_string = ""
	search_bar.text = ""
	_update_grid()
