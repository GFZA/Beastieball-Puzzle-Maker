class_name MainUI
extends Control

signal save_image_requested
signal save_json_requested
signal load_json_requested
signal reset_board_requested
signal connect_for_new_beastie_menu_requested(beastie_menu : BeastieMenu)

const BEASTIE_MENU_SCENE := preload("uid://ck45vbd1ldi5t")

var board : Board = null

var left_beastie_menus : Dictionary[TeamController.TeamPosition, BeastieMenu] = {
	TeamController.TeamPosition.FIELD_1 : null,
	TeamController.TeamPosition.FIELD_2 : null,
	TeamController.TeamPosition.BENCH_1 : null,
	TeamController.TeamPosition.BENCH_2 : null,
}

var right_beastie_menus : Dictionary[TeamController.TeamPosition, BeastieMenu] = {
	TeamController.TeamPosition.FIELD_1 : null,
	TeamController.TeamPosition.FIELD_2 : null,
	TeamController.TeamPosition.BENCH_1 : null,
	TeamController.TeamPosition.BENCH_2 : null,
}
var currently_shown_beastie_menu : BeastieMenu = null
var current_beastie_menu_tab : int = 0

@onready var back_button_container: MarginContainer = %BackButtonContainer
@onready var back_button: Button = %BackButton

@onready var menu_container: MarginContainer = %MenuContainer
@onready var default_menu: DefaultMenu = %DefaultMenu
@onready var your_team_menu: TeamMenu = %YourTeamMenu
@onready var opponent_team_menu: TeamMenu = %OpponentTeamMenu
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

	your_team_menu.beastie_menu_requested.connect(on_beastie_menu_requested)
	your_team_menu.controller_reset_slot_requested.connect(on_reset_slot_requested)
	#your_team_menu.swap_slot_requested.connect(on_swap_slot_requested.bind(Global.MySide.LEFT))
	opponent_team_menu.beastie_menu_requested.connect(on_beastie_menu_requested)
	opponent_team_menu.controller_reset_slot_requested.connect(on_reset_slot_requested)
	#opponent_team_menu.swap_slot_requested.connect(on_swap_slot_requested.bind(Global.MySide.RIGHT))

	_on_back_button_pressed()


func _on_back_button_pressed() -> void:
	if not Global.resetting and currently_shown_beastie_menu != null:
		match currently_shown_beastie_menu.side:
			Global.MySide.LEFT:
				show_your_team_menu()
			Global.MySide.RIGHT:
				show_opponent_team_menu()
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
	currently_shown_beastie_menu = null


func reset() -> void:
	for menu in menu_container.get_children():
		menu.reset() # Not typed safe
		if menu is BeastieMenu:
			remove_menu(menu)
	for key : TeamController.TeamPosition in left_beastie_menus.keys():
		left_beastie_menus[key] = null
	for key : TeamController.TeamPosition in right_beastie_menus.keys():
		right_beastie_menus[key] = null
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


func show_beastie_menu(beastie_menu : BeastieMenu) -> void:
	var side_text : String = "Your Team" if beastie_menu.side == Global.MySide.LEFT else "Opponent Team"
	upper_label.text = "Editing " + side_text
	back_button_container.show()
	hide_all_menu()
	beastie_menu.show()
	currently_shown_beastie_menu = beastie_menu


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


func on_beastie_menu_requested(requested_beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	var dict_to_check : Dictionary[TeamController.TeamPosition, BeastieMenu] = left_beastie_menus \
															if side == Global.MySide.LEFT else right_beastie_menus
	var menu : BeastieMenu = dict_to_check.get(team_pos)
	if menu:
		show_beastie_menu(menu)
	else:
		var new_menu : BeastieMenu = BEASTIE_MENU_SCENE.instantiate()
		new_menu.beastie = requested_beastie
		new_menu.side = side
		new_menu.team_pos = team_pos
		new_menu.board = board
		menu_container.add_child(new_menu)
		if new_menu.tab_container.is_tab_hidden(current_beastie_menu_tab) and current_beastie_menu_tab == 0:
			new_menu.tab_container.current_tab = 1 # Sets Tab
		else:
			new_menu.tab_container.current_tab = current_beastie_menu_tab
		new_menu.tab_container.tab_changed.connect(on_beastie_menu_tab_changed.bind(new_menu))
		connect_for_new_beastie_menu_requested.emit(new_menu)
		dict_to_check[team_pos] = new_menu
		show_beastie_menu(new_menu)


func on_beastie_remove_requested(_requested_beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	var team_menu : TeamMenu = your_team_menu if side == Global.MySide.LEFT else opponent_team_menu
	team_menu.controller_reset_slot_requested.emit(side, team_pos)


#func on_swap_slot_requested(team_pos_1 : TeamController.TeamPosition, team_pos_2 : TeamController.TeamPosition, side : Global.MySide) -> void:
	#var menu_dict : Dictionary[TeamController.TeamPosition, BeastieMenu] = left_beastie_menus if side == Global.MySide.LEFT else right_beastie_menus
	#var menu_1 : BeastieMenu = menu_dict.get(team_pos_1)
	#var menu_2 : BeastieMenu = menu_dict.get(team_pos_2)
	#menu_dict[team_pos_1] = menu_2
	#menu_dict[team_pos_2] = menu_1


func remove_menu(menu : BeastieMenu) -> void:
	var dict_to_check : Dictionary[TeamController.TeamPosition, BeastieMenu] = left_beastie_menus \
															if menu.side == Global.MySide.LEFT else right_beastie_menus
	dict_to_check[menu.team_pos] = null
	menu.queue_free()


func on_reset_slot_requested(side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	var dict_to_check : Dictionary[TeamController.TeamPosition, BeastieMenu] = left_beastie_menus \
															if side == Global.MySide.LEFT else right_beastie_menus
	if currently_shown_beastie_menu and currently_shown_beastie_menu.side == side:
		_on_back_button_pressed() # When removing using right-click on BeastieScene
	var menu : BeastieMenu = dict_to_check.get(team_pos)
	if menu:
		remove_menu(menu)


func on_beastie_menu_tab_changed(tab_index : int, current_menu : BeastieMenu) -> void:
	if current_menu == currently_shown_beastie_menu:
		current_beastie_menu_tab = tab_index
	for i in 2:
		var dict : Dictionary[TeamController.TeamPosition, BeastieMenu] = left_beastie_menus \
															if i == 0 else right_beastie_menus
		for key : TeamController.TeamPosition in dict.keys():
			var menu : BeastieMenu = dict.get(key)
			if menu:
				if menu.tab_container.is_tab_hidden(current_beastie_menu_tab) and current_beastie_menu_tab == 0:
					menu.tab_container.current_tab = 1 # Sets Tab
				else:
					menu.tab_container.current_tab = current_beastie_menu_tab
