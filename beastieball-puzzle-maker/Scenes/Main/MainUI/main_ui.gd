class_name MainUI
extends Control

signal save_image_requested(path : String)
signal save_json_requested(path : String)
signal reset_board_requested
signal connect_for_new_beastie_menu_requested(beastie_menu : BeastieMenu)
signal logo_changed(new_logo : Texture2D)
signal board_data_file_loaded(data : BoardData)

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

var logo_file_access_web : FileAccessWeb = null
var load_file_access_web : FileAccessWeb = null

var logo_acceptable_image_type: String = ".jpeg, .jpg, .png"

var temp_pc_img_path : String = "C:/"
var temp_pc_res_path : String = "user://"
var temp_byte_storing_path : String = "user://temporary_byte.res"

@onready var back_button_container: MarginContainer = %BackButtonContainer
@onready var back_button: Button = %BackButton

@onready var menu_container: MarginContainer = %MenuContainer
@onready var default_menu: DefaultMenu = %DefaultMenu
@onready var your_team_menu: TeamMenu = %YourTeamMenu
@onready var opponent_team_menu: TeamMenu = %OpponentTeamMenu
@onready var overlay_menu: OverlayMenu = %OverlayMenu
@onready var field_effects_menu: ScrollContainer = %FieldEffectsMenu

@onready var save_image_button: Button = %SaveImageButton
@onready var save_json_button: Button = %SaveJSONButton # Planned for it to be JSON but got too lazy
@onready var load_json_button: Button = %LoadJSONButton # Planned for it to be JSON but got too lazy
@onready var reset_button: Button = %ResetButton
@onready var github_button: Button = %GithubButton

@onready var upper_label: Label = %UpperLabel

@onready var logo_select_dialog: FileDialog = %LogoFileDialog
@onready var load_file_dialog: FileDialog = %LoadFileDialog
@onready var save_file_dialog: FileDialog = %SaveFileDialog
@onready var save_image_dialog: FileDialog = %SaveImageDialog


func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)

	save_image_button.pressed.connect(_on_save_image_button_pressed)
	save_json_button.pressed.connect(_on_save_json_button_pressed)
	load_json_button.pressed.connect(_on_load_json_button_pressed)
	reset_button.pressed.connect(_on_reset_board_pressed)
	github_button.pressed.connect(_on_github_button_pressed)

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

	overlay_menu.logo_dialogue_requested.connect(_on_logo_dialog_requested)
	logo_select_dialog.file_selected.connect(on_logo_file_selected)
	logo_changed.connect(overlay_menu.on_logo_changed)
	overlay_menu.logo_remove_requested.connect(logo_changed.emit.bind(null))

	load_file_dialog.file_selected.connect(_on_load_dialog_file_selected)
	save_file_dialog.file_selected.connect(_on_save_dialog_file_selected)
	save_image_dialog.file_selected.connect(_on_save_image_dialog_file_selected)

	if Global.is_on_web:
		logo_file_access_web = FileAccessWeb.new()
		load_file_access_web = FileAccessWeb.new()
		logo_file_access_web.loaded.connect(_on_logo_file_access_web_file_loaded)
		load_file_access_web.loaded.connect(_on_load_file_access_web_file_loaded)
		load_file_access_web.progress.connect(func(_a, _b): print("loading"))
		load_file_access_web.error.connect(func(): print("error!"))
		load_file_access_web.upload_cancelled.connect(func(): print("upload canceled!"))
		load_file_access_web.load_started.connect(func(_a): print("load started!"))

	else:
		logo_select_dialog.root_subfolder = temp_pc_img_path
		load_file_dialog.root_subfolder = temp_pc_res_path
		save_file_dialog.root_subfolder = temp_pc_res_path
		save_image_dialog.root_subfolder = temp_pc_img_path

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


func hide_all_menu() -> void:
	for menu in menu_container.get_children():
		menu.hide()
	currently_shown_beastie_menu = null


func reset() -> void:
	for menu in menu_container.get_children():
		menu.reset() # Not typed safe
		if menu is BeastieMenu:
			remove_menu(menu)
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
	if is_instance_valid(dict_to_check.get(team_pos)):
		var menu : BeastieMenu = dict_to_check.get(team_pos)
		if menu:
			show_beastie_menu(menu)
		else:
			make_new_beastie_menu(requested_beastie, side, team_pos)
	else:
		make_new_beastie_menu(requested_beastie, side, team_pos)


func make_new_beastie_menu(requested_beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	var dict_to_add : Dictionary[TeamController.TeamPosition, BeastieMenu] = left_beastie_menus \
													if side == Global.MySide.LEFT else right_beastie_menus
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
	dict_to_add[team_pos] = new_menu
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
			if not is_instance_valid(dict.get(key)):
				continue
			var menu : BeastieMenu = dict.get(key)
			if menu:
				if menu.tab_container.is_tab_hidden(current_beastie_menu_tab) and current_beastie_menu_tab == 0:
					menu.tab_container.current_tab = 1 # Sets Tab
				else:
					menu.tab_container.current_tab = current_beastie_menu_tab


func _on_reset_board_pressed() -> void:
	reset_board_requested.emit()


func all_menu_load_data(board_data : BoardData) -> void:
	for menu in menu_container.get_children():
		if menu is BeastieMenu:
			remove_menu(menu) # will get made again by TeamMenu when loading
	overlay_menu.load_from_data(board_data)
	your_team_menu.load_from_data(board_data)
	opponent_team_menu.load_from_data(board_data)
	field_effects_menu.load_from_data(board_data)
	_on_back_button_pressed()
	show_default_menu()


#region Logo Dialog Handling
func _on_logo_dialog_requested() -> void:
	if Global.is_on_web:
		logo_file_access_web.open(logo_acceptable_image_type)
	else:
		logo_select_dialog.popup_centered()

# ----- Web -----
func _on_logo_file_access_web_file_loaded(_file_name : String, file_type : String, base64_data : String) -> void:
	var raw_data: PackedByteArray = Marshalls.base64_to_raw(base64_data)
	_raw_draw(file_type, raw_data)


func _raw_draw(type : String, data : PackedByteArray) -> void:
	var image := Image.new()
	var error: int = _load_image(image, type, data)

	if error:
		push_error("Error %s id" % error)
		return

	var texture : Texture2D = ImageTexture.create_from_image(image)
	logo_changed.emit(texture)


func _load_image(image: Image, type: String, data: PackedByteArray) -> int:
	match type:
		"image/png":
			return image.load_png_from_buffer(data)
		"image/jpeg", "image/jpg":
			return image.load_jpg_from_buffer(data)
		"image/webp":
			return image.load_webp_from_buffer(data)
		_:
			return Error.FAILED

# ----- PC -----
func on_logo_file_selected(path: String) -> void:
	var image := Image.new()
	var err := image.load(path)

	if err != OK:
		push_error("Failed to load image: %s" % path)
		return

	var texture := ImageTexture.create_from_image(image)
	logo_changed.emit(texture)
#endregion

#region Save Image Dialog Handling
func _on_save_image_button_pressed() -> void:
	if Global.is_on_web:
		save_image_requested.emit("") # Will prompt browser to download instead
	else:
		save_image_dialog.popup_centered()


func _on_save_image_dialog_file_selected(path : String) -> void:
	save_image_requested.emit(path)
#endregion

#region Save JSON Dialog Handling
func _on_save_json_button_pressed() -> void:
	if Global.is_on_web:
		save_json_requested.emit("") # Will prompt browser to download instead
	else:
		save_file_dialog.popup_centered()


func _on_save_dialog_file_selected(path : String) -> void:
	save_json_requested.emit(path)
#endregion

#region Load JSON Handling
func _on_load_json_button_pressed() -> void:
	if Global.is_on_web:
		load_file_access_web.open(".res")
	else:
		load_file_dialog.popup_centered()

# ----- Web -----
func _on_load_file_access_web_file_loaded(_file_name : String, _file_type : String, base64_data : String) -> void:
	var raw_data: PackedByteArray = Marshalls.base64_to_raw(base64_data)
	var file := FileAccess.open(temp_byte_storing_path, FileAccess.WRITE)
	if file and FileAccess.get_open_error() == OK:
		file.store_buffer(raw_data)
		file.close()

		var data : BoardData = ResourceLoader.load(temp_byte_storing_path)
		board_data_file_loaded.emit(data)

		var dir := DirAccess.open("user://")
		if dir:
			var error = dir.remove(temp_byte_storing_path)
			if error == OK:
				print("Temporary byte file deleted successfully!")
		else:
			print("Error opening user directory")
	else:
		print("Failed to save temporary file for resource loading.")


# ----- PC -----
func _on_load_dialog_file_selected(path: String) -> void:
	var data := ResourceLoader.load(path)
	if not data:
		push_error("Failed to load data: %s" % path)
		return
	if not data is BoardData:
		push_error("Loaded data is not BoardData! Path : %s" % path)
		return
	board_data_file_loaded.emit(data)
#endregion


func _on_github_button_pressed() -> void:
	OS.shell_open("https://github.com/GFZA/Beastieball-Puzzle-Maker/")
