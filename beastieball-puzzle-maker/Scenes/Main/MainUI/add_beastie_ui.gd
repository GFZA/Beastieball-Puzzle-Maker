@tool
class_name AddBeastieUI
extends Control


signal beastie_select_ui_requested(select_then_call_this : Callable)
signal add_beastie_to_board_requested(requested_beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition)
signal beastie_menu_requested(requested_beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition)


@export var text : String = "Serve Slot" :
	set(value):
		text = value
		if not is_node_ready():
			await ready
		front_label.text = text
@export var team_pos : TeamController.TeamPosition = TeamController.TeamPosition.FIELD_1

var side : Global.MySide = Global.MySide.LEFT

@onready var front_label: Label = %FrontLabel
@onready var swap_button_container: VBoxContainer = %SwapButtonContainer
@onready var swap_up_button: Button = %SwapUpButton
@onready var swap_down_button: Button = %SwapDownButton
@onready var beastie_button: Button = %BeastieButton
@onready var add_button: Button = %AddButton
@onready var reset_button: Button = %ResetButton


var my_beastie : Beastie = null


func _ready() -> void:
	swap_up_button.pressed.connect(_on_swap_up_pressed)
	swap_down_button.pressed.connect(_on_swap_down_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	add_button.pressed.connect(beastie_select_ui_requested.emit.bind(on_beastie_selected))
	beastie_button.pressed.connect(_on_beastie_button_pressed)

	reset()


func reset() -> void:
	my_beastie = null
	add_beastie_to_board_requested.emit(null, side, team_pos)
	add_button.show()
	beastie_button.text = ""
	beastie_button.hide()
	reset_button.hide()
	swap_button_container.hide()


func _on_swap_up_pressed() -> void:
	if not my_beastie:
		return
	print("Swap up (%s) requested." % my_beastie.specie_name)


func _on_swap_down_pressed() -> void:
	if not my_beastie:
		return
	print("Swap down (%s) requested." % my_beastie.specie_name)


func _on_add_button_pressed() -> void:
	beastie_select_ui_requested.emit(on_beastie_selected)


func on_beastie_selected(beastie : Beastie) -> void:
	if not beastie:
		reset()
		return
	my_beastie = beastie.duplicate(true)
	add_button.hide()
	beastie_button.text = my_beastie.specie_name
	beastie_button.show()
	reset_button.show()
	swap_button_container.show()

	add_beastie_to_board_requested.emit(my_beastie, side, team_pos)
	beastie_menu_requested.emit(my_beastie, side, team_pos) # Go to Beastie Menu right after selecting


func _on_reset_button_pressed() -> void:
	reset()


func _on_beastie_button_pressed() -> void:
	beastie_menu_requested.emit(my_beastie, side, team_pos)
