@tool
class_name Board
extends Node2D

enum Turn {OFFENSE, DEFENSE, SERVE}

@onready var board_manager: BoardManager = %BoardManager

#region Screenshot Stuff
@onready var camera_2d: Camera2D = $Camera2D

func screenshot() -> void:
	if Engine.is_editor_hint():
		return
	camera_2d.get_viewport().get_texture().get_image().save_png('user:///image.png')

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("screenshot"):
		screenshot()
#endregion
