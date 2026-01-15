class_name Main
extends Control

@export var temp_data : BoardData = null

@onready var main_ui: MainUI = %MainUI
@onready var board: Board = %Board
@onready var saving_rect: ColorRect = %SavingRect
@onready var saving_label: Label = %SavingLabel

@onready var select_ui: SelectUIs = %SelectUIs


func _ready() -> void:
	# Some Vars
	select_ui.board = board

	# Overlay Menu Signals
	board.board_overlay.overlay_edit_requested.connect(main_ui.show_overlay_menu)
	main_ui.overlay_menu.max_point_changed.connect(board.board_overlay.on_max_point_changed)
	main_ui.overlay_menu.your_point_changed.connect(_on_your_point_changed)
	main_ui.overlay_menu.opponent_point_changed.connect(_on_opponent_point_changed)
	main_ui.overlay_menu.turn_changed.connect(board.on_turn_changed)
	main_ui.overlay_menu.offense_action_changed.connect(board.board_overlay.on_offense_action_changed)
	main_ui.overlay_menu.title_text_changed.connect(board.board_overlay.on_title_text_changed)
	main_ui.overlay_menu.right_text_changed.connect(board.board_overlay.on_right_text_changed)
	main_ui.overlay_menu.logo_changed.connect(board.board_overlay.on_logo_changed)

	# Field Effects Menu Signals
	board.field_effects_edit_requested.connect(main_ui.show_field_effect_menu)
	main_ui.field_effects_menu.rally_stack_changed.connect(board.board_manager.left_team_controller.on_rally_stacked_changed)
	main_ui.field_effects_menu.dread_stack_changed.connect(board.board_manager.left_team_controller.on_dread_stacked_changed)
	main_ui.field_effects_menu.left_rhythm_stack_changed.connect(board.board_manager.left_team_controller.on_rhythm_stacked_changed)
	main_ui.field_effects_menu.left_trap_stack_changed.connect(board.board_manager.left_team_controller.on_trap_stacked_changed)
	main_ui.field_effects_menu.left_quake_stack_changed.connect(board.board_manager.left_team_controller.on_quake_stacked_changed)
	main_ui.field_effects_menu.left_barrier_upper_stack_changed.connect(board.board_manager.left_team_controller.on_barrier_upper_stacked_changed)
	main_ui.field_effects_menu.left_barrier_lower_stack_changed.connect(board.board_manager.left_team_controller.on_barrier_lower_stacked_changed)
	main_ui.field_effects_menu.right_rhythm_stack_changed.connect(board.board_manager.right_team_controller.on_rhythm_stacked_changed)
	main_ui.field_effects_menu.right_trap_stack_changed.connect(board.board_manager.right_team_controller.on_trap_stacked_changed)
	main_ui.field_effects_menu.right_quake_stack_changed.connect(board.board_manager.right_team_controller.on_quake_stacked_changed)
	main_ui.field_effects_menu.right_barrier_upper_stack_changed.connect(board.board_manager.right_team_controller.on_barrier_upper_stacked_changed)
	main_ui.field_effects_menu.right_barrier_lower_stack_changed.connect(board.board_manager.right_team_controller.on_barrier_lower_stacked_changed)

	# Team Menu Signals
	main_ui.your_team_menu.controller_reset_slot_requested.connect(_on_controller_reset_slot_requested)
	main_ui.opponent_team_menu.controller_reset_slot_requested.connect(_on_controller_reset_slot_requested)
	main_ui.your_team_menu.swap_slot_requested.connect(board.board_manager.on_swap_slot_requested.bind(Global.MySide.LEFT))
	main_ui.opponent_team_menu.swap_slot_requested.connect(board.board_manager.on_swap_slot_requested.bind(Global.MySide.RIGHT))

	# Beastie Menu Signals
	board.board_manager.left_team_controller.beastie_menu_requested.connect(main_ui.show_beastie_menu)
	board.board_manager.right_team_controller.beastie_menu_requested.connect(main_ui.show_beastie_menu)
	main_ui.beastie_menu.beastie_position_change_requested.connect(board.board_manager.on_beastie_position_change_requested)
	main_ui.beastie_menu.beastie_ball_change_requested.connect(board.board_manager.on_beastie_ball_change_requested)

	# Lower buttons Signals
	main_ui.save_image_requested.connect(_on_save_image_requested)
	main_ui.save_json_requested.connect(_on_save_json_requested)
	main_ui.load_json_requested.connect(_on_load_json_requested)
	main_ui.reset_board_requested.connect(_on_reset_board_requested)

	# Select Ui Signal
	var beastie_requester : Array[Node] = get_tree().get_nodes_in_group("beastie_select_ui_requester")
	for requester in beastie_requester:
		requester.beastie_select_ui_requested.connect(select_ui.show_beastie_select_ui)
		select_ui.beastie_selected.connect(requester.on_beastie_selected)


func _on_your_point_changed(new_point : int) -> void:
	board.board_overlay.on_your_point_changed(new_point)
	board.board_manager.left_team_controller.current_score = new_point


func _on_opponent_point_changed(new_point : int) -> void:
	board.board_overlay.on_opponent_point_change(new_point)
	board.board_manager.right_team_controller.current_score = new_point


func _on_controller_reset_slot_requested(side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	board.board_manager.add_beastie_to_scene(null, side, team_pos)
	select_ui.beastie_selected.emit(null, side, team_pos)


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
	Global.resetting = true

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
	board.reset()
	await board.board_manager.board_resetted

	saving_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	saving_label.text = ""
	saving_rect.hide()

	Global.resetting = false

#endregion
