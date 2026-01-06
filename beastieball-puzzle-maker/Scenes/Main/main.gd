class_name Main
extends Control

@export var temp_data : BoardData = null


@onready var main_ui: MainUI = %MainUI
@onready var board: Board = %Board
@onready var saving_rect: ColorRect = %SavingRect
@onready var saving_label: Label = %SavingLabel


func _ready() -> void:
	# Board edits signals
	board.board_overlay.overlay_edit_requested.connect(main_ui.show_overlay_menu)

	# Lower buttons Signals
	main_ui.save_image_requested.connect(_on_save_image_requested)
	main_ui.save_json_requested.connect(_on_save_json_requested)
	main_ui.load_json_requested.connect(_on_load_json_requested)
	main_ui.reset_board_requested.connect(_on_reset_board_requested)


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
	board.board_manager.reset_board()
	await board.board_manager.board_resetted

	saving_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	saving_label.text = ""
	saving_rect.hide()

#endregion
