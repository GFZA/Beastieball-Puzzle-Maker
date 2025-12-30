@tool
class_name Board
extends Node2D

enum Turn {OFFENSE, DEFENSE, SERVE}

@export var image_size : Vector2 = Vector2(2560, 1920)
@export_range(1, 999, 1) var image_number : int = 1

@export_tool_button("Get Image!") var subviewport_ss := func():
	var original_size = sub_viewport.size

	sub_viewport_container.stretch = false
	sub_viewport.size = image_size

	# Delay for rendering
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	var image: Image = sub_viewport.get_texture().get_image()
	# Use INTERPOLATE_LANCZOS for best downscaling quality if resizing is needed
	image.resize(original_size.x, original_size.y, Image.INTERPOLATE_LANCZOS)
	image.save_png("user:///puzzle_" + str(image_number) + ".png")

	sub_viewport.size = original_size
	sub_viewport_container.stretch = true

@onready var sub_viewport_container: SubViewportContainer = %SubViewportContainer
@onready var sub_viewport: SubViewport = %SubViewport

@onready var board_manager: BoardManager = %BoardManager
