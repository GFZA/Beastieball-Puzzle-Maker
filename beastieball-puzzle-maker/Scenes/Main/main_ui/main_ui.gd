class_name MainUI
extends Control

signal save_image_requested
signal save_json_requested
signal load_json_requested
signal reset_board_requested

@onready var back_button_container: MarginContainer = %BackButtonContainer
@onready var back_button: Button = %BackButton

@onready var menu_container: MarginContainer = %MenuContainer
@onready var default_menu: DefaultMenu = %DefaultMenu
@onready var overlay_menu: OverlayMenu = %OverlayMenu
@onready var your_team_menu: TeamMenu = %YourTeamMenu
@onready var opponent_team_menu: TeamMenu = %OpponentTeamMenu

@onready var save_image_button: Button = %SaveImageButton
@onready var save_json_button: Button = %SaveJSONButton
@onready var load_json_button: Button = %LoadJSONButton
@onready var reset_button: Button = %ResetButton
@onready var upper_label: Label = %UpperLabel


func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)

	save_image_button.pressed.connect(_on_save_image_button_pressed)
	save_json_button.pressed.connect(_on_save_json_button_pressed)
	load_json_button.pressed.connect(_on_load_json_button_pressed)
	reset_button.pressed.connect(_on_reset_board_pressed)

	default_menu.your_team_edit_requested.connect(show_your_team_menu)
	default_menu.opponent_team_edit_requested.connect(show_opponent_team_menu)
	default_menu.overlay_edit_requested.connect(show_overlay_menu)
	default_menu.field_effect_edit_requested.connect(show_field_effect_menu)

	_on_back_button_pressed()


func _on_back_button_pressed() -> void:
	back_button_container.hide()
	show_default_menu()


func _on_save_image_button_pressed() -> void:
	save_image_button.release_focus()
	save_image_requested.emit()


func _on_save_json_button_pressed() -> void:
	save_json_button.release_focus()
	save_json_requested.emit()


func _on_load_json_button_pressed() -> void:
	load_json_button.release_focus()
	load_json_requested.emit()
	print("open files")


func _on_reset_board_pressed() -> void:
	reset_button.release_focus()
	reset_board_requested.emit()


func hide_all_menu() -> void:
	for menu in menu_container.get_children():
		menu.hide()


func reset() -> void:
	for menu in menu_container.get_children():
		menu.reset() # Not typed safe
	_on_back_button_pressed()


func show_default_menu() -> void:
	hide_all_menu()
	upper_label.text = "Click below or on the picture"
	default_menu.show()


func show_your_team_menu() -> void:
	hide_all_menu()
	upper_label.text = "Editing Your Team"
	back_button_container.show()
	your_team_menu.show()


func show_opponent_team_menu() -> void:
	hide_all_menu()
	upper_label.text = "Editing Opponent Team"
	back_button_container.show()
	opponent_team_menu.show()


func show_overlay_menu() -> void:
	hide_all_menu()
	upper_label.text = "Editing Overlay"
	back_button_container.show()
	overlay_menu.show()


func show_field_effect_menu() -> void:
	hide_all_menu()
	upper_label.text = "Editing Field Effects"
	back_button_container.show()
	#field_effect_menu.show()
