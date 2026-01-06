class_name MainUI
extends Control

signal save_image_requested
signal save_json_requested
signal load_json_requested
signal reset_board_requested

@onready var save_image_button: Button = %SaveImageButton
@onready var save_json_button: Button = %SaveJSONButton
@onready var load_json_button: Button = %LoadJSONButton
@onready var reset_button: Button = %ResetButton


func _ready() -> void:
	save_image_button.pressed.connect(_on_save_image_button_pressed)
	save_json_button.pressed.connect(_on_save_json_button_pressed)
	load_json_button.pressed.connect(_on_load_json_button_pressed)
	reset_button.pressed.connect(_on_reset_board_pressed)


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


func show_overlay_menu() -> void:
	return


func hide_overlay_menu() -> void:
	return
