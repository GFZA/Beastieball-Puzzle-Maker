class_name DefaultMenu
extends ScrollContainer

signal your_team_edit_requested
signal opponent_team_edit_requested
signal overlay_edit_requested
signal field_effect_edit_requested


@onready var your_team_button: Button = %YourTeamButton
@onready var opponent_team_button: Button = %OpponentTeamButton
@onready var overlay_buttton: Button = %OverlayButtton
@onready var add_field_effects_button: Button = %AddFieldEffectsButton


func _ready() -> void:
	your_team_button.pressed.connect(your_team_edit_requested.emit)
	opponent_team_button.pressed.connect(opponent_team_edit_requested.emit)
	overlay_buttton.pressed.connect(overlay_edit_requested.emit)
	add_field_effects_button.pressed.connect(field_effect_edit_requested.emit)


func reset() -> void:
	# Do nothing lol
	# This is used in MainUI for resetting everything and I'm lazy to specifically exclude this menu
	return
