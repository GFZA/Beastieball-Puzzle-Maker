@tool
class_name AddBeastieUI
extends Control

signal beastie_select_ui_requested(side : Global.MySide, team_pos : TeamController.TeamPosition)
signal beastie_menu_requested(requested_beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition)
signal controller_reset_slot_requested(side : Global.MySide, team_pos : TeamController.TeamPosition)

@export var text : String = "Member One" :
	set(value):
		text = value
		if not is_node_ready():
			await ready
		front_label.text = text

@export var team_pos : TeamController.TeamPosition = TeamController.TeamPosition.FIELD_1

var side : Global.MySide = Global.MySide.LEFT

@onready var front_label: Label = %FrontLabel
@onready var beastie_button: Button = %BeastieButton
@onready var add_button: Button = %AddButton
@onready var reset_button: Button = %ResetButton


var my_beastie : Beastie = null


func _ready() -> void:
	add_button.pressed.connect(_on_add_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	beastie_button.pressed.connect(_on_beastie_button_pressed)

	reset()


func reset() -> void:
	my_beastie = null
	add_button.show()
	beastie_button.text = ""
	beastie_button.hide()
	reset_button.hide()


func _on_add_button_pressed() -> void:
	beastie_select_ui_requested.emit(side, team_pos)


func on_beastie_selected(beastie : Beastie, selected_side : Global.MySide, selected_team_pos : TeamController.TeamPosition) -> void:
	if selected_side != side or selected_team_pos != team_pos:
		return
	if not beastie:
		reset()
		return
	my_beastie = beastie
	update_visual_when_beastie()
	beastie_menu_requested.emit(my_beastie, side, team_pos) # Go to Beastie Menu right after selecting


func update_visual_when_beastie() -> void:
	if not my_beastie:
		return
	add_button.hide()
	beastie_button.text = my_beastie.specie_name
	beastie_button.show()
	reset_button.show()


func _on_reset_button_pressed() -> void:
	reset()
	controller_reset_slot_requested.emit(side, team_pos)


func _on_beastie_button_pressed() -> void:
	beastie_menu_requested.emit(my_beastie, side, team_pos)
