class_name Main
extends Control

@export var temp_data : BoardData = null


@onready var main_ui: MainUI = %MainUI
@onready var board: Board = %Board
@onready var saving_rect: ColorRect = %SavingRect
@onready var saving_label: Label = %SavingLabel

@onready var select_ui: SelectUIs = %SelectUIs


func _ready() -> void:
	# Overlay menu signals
	board.board_overlay.overlay_edit_requested.connect(main_ui.show_overlay_menu)
	main_ui.overlay_menu.max_point_changed.connect(board.board_overlay.on_max_point_changed)
	main_ui.overlay_menu.your_point_changed.connect(board.board_overlay.on_your_point_changed)
	main_ui.overlay_menu.opponent_point_change.connect(board.board_overlay.on_opponent_point_change)
	main_ui.overlay_menu.turn_changed.connect(board.board_overlay.on_turn_changed)
	main_ui.overlay_menu.offense_action_changed.connect(board.board_overlay.on_offense_action_changed)
	main_ui.overlay_menu.defense_against_serve_changed.connect(board.board_overlay.on_defense_against_serve_changed)
	main_ui.overlay_menu.title_text_changed.connect(board.board_overlay.on_title_text_changed)
	main_ui.overlay_menu.right_text_changed.connect(board.board_overlay.on_right_text_changed)
	main_ui.overlay_menu.logo_changed.connect(board.board_overlay.on_logo_changed)

	# Lower buttons Signals
	main_ui.save_image_requested.connect(_on_save_image_requested)
	main_ui.save_json_requested.connect(_on_save_json_requested)
	main_ui.load_json_requested.connect(_on_load_json_requested)
	main_ui.reset_board_requested.connect(_on_reset_board_requested)

	# Select Ui Signal
	var beastie_requester : Array[Node] = get_tree().get_nodes_in_group("beastie_select_ui_requester")
	for requester in beastie_requester:
		requester.beastie_select_ui_requested.connect(select_ui.show_beastie_select_ui)


#region Lower buttons signal funcs

func _on_save_image_requested() -> void:
	saving_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	saving_label.text = "Saving..."
	saving_rect.show()

	# Cheap ass delay to make it looks good
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	board.save_image()
	await board.image_saved

	saving_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	saving_label.text = ""
	saving_rect.hide()


func _on_save_json_requested() -> void:
	saving_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	saving_label.text = "Saving..."
	saving_rect.show()

	# Cheap ass delay to make it looks good
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	board.board_manager.save_board_data()
	await board.board_manager.data_saved

	saving_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	saving_label.text = ""
	saving_rect.hide()


func _on_load_json_requested() -> void:
	saving_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	saving_label.text = "Loading..."
	saving_rect.show()

	# Cheap ass delay to make it looks good
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	board.board_manager.load_board_data(temp_data)
	await board.board_manager.data_loaded

	saving_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	saving_label.text = ""
	saving_rect.hide()


func _on_reset_board_requested() -> void:
	saving_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	saving_label.text = "Resetting..."
	saving_rect.show()

	# Cheap ass delay to make it looks good
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	main_ui.reset()
	board.board_manager.reset_board()
	await board.board_manager.board_resetted

	saving_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	saving_label.text = ""
	saving_rect.hide()

#endregion
