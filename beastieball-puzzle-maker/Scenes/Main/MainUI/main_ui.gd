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
@onready var your_team_menu: TeamMenu = %YourTeamMenu
@onready var opponent_team_menu: TeamMenu = %OpponentTeamMenu
@onready var beastie_menu: BeastieMenu = %BeastieMenu
@onready var overlay_menu: OverlayMenu = %OverlayMenu
@onready var field_effects_menu: ScrollContainer = %FieldEffectsMenu

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

	your_team_menu.beastie_menu_requested.connect(show_beastie_menu)

	_on_back_button_pressed()


func _on_back_button_pressed() -> void:
	if beastie_menu.visible:
		match beastie_menu.side:
			Global.MySide.LEFT:
				show_your_team_menu()
			Global.MySide.RIGHT:
				show_opponent_team_menu()
		beastie_menu.reset()
	else:
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
		if menu is BeastieMenu:
			menu.beastie = null


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


func show_beastie_menu(beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	hide_all_menu()
	var side_text : String = "Your Team" if side == Global.MySide.LEFT else "Opponent Team"
	upper_label.text = "Editing " + side_text
	back_button_container.show()
	beastie_menu.team_pos = team_pos # Order matter here because beastie_menu beastie setter use this
	beastie_menu.side = side
	beastie_menu.beastie = beastie
	beastie_menu.show()


func show_overlay_menu() -> void:
	hide_all_menu()
	upper_label.text = "Editing Overlay"
	back_button_container.show()
	overlay_menu.show()


func show_field_effect_menu() -> void:
	hide_all_menu()
	upper_label.text = "Editing Field Effects"
	back_button_container.show()
	field_effects_menu.show()
