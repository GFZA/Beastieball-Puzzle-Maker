@tool
class_name Board
extends Control

signal image_saved

enum Turn {OFFENSE, DEFENSE, SERVE}
enum TrapStack {ONE = 1, TWO = 2, THREE = 3, FOUR = 4}

const TRAP_VISUALS_DICT : Dictionary[TrapStack, Array] = {
	TrapStack.ONE : [preload("uid://be4fx7xip2lal"), preload("uid://bvywpvocaqq32")], # [LEFT, RIGHT]
	TrapStack.TWO : [preload("uid://chq4iwkouargt"), preload("uid://bn1gn7878iqx4")],
	TrapStack.THREE : [preload("uid://dch8q1l4yem4q"), preload("uid://jw5124rypo20")],
	TrapStack.FOUR : [preload("uid://b12tfn7n1l8qs"), preload("uid://sxxdcxrcur20")],
}

@export_tool_button("Get Image!") var tool_button_var : Callable = save_image

@export_range(1, 999, 1) var image_number : int = 1

@onready var sub_viewport_container: SubViewportContainer = %SubViewportContainer
@onready var sub_viewport: SubViewport = %SubViewport

@onready var left_quake_visuals: Node2D = %LeftQuakeVisuals
@onready var right_quake_visuals: Node2D = %RightQuakeVisuals

@onready var dread_visuals: Node2D = %DreadVisuals

@onready var left_barrier_upper: Sprite2D = %LeftBarrierUpper
@onready var right_barrier_upper: Sprite2D = %RightBarrierUpper
@onready var left_barrier_lower: Sprite2D = %LeftBarrierLower
@onready var right_barrier_lower: Sprite2D = %RightBarrierLower

@onready var left_trap_visuals: Sprite2D = %LeftTrapVisuals
@onready var right_trap_visuals: Sprite2D = %RightTrapVisuals

@onready var left_rhythm_visuals: Node2D = %LeftRhythmVisuals
@onready var right_rhythm_visuals: Node2D = %RightRhythmVisuals

@onready var board_overlay: BoardOverlay = %BoardOverlay
@onready var board_manager: BoardManager = %BoardManager


func _ready() -> void:
	hide_all_field_visuals()


func save_image() -> void:
	var original_size = sub_viewport.size

	sub_viewport_container.stretch = false
	sub_viewport.size = Vector2(2700, 2025)

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

	image_saved.emit()
	print("Image saved!")


func hide_all_field_visuals() -> void:
	left_quake_visuals.hide()
	right_quake_visuals.hide()

	dread_visuals.hide()

	left_barrier_upper.hide()
	right_barrier_upper.hide()
	left_barrier_lower.hide()
	right_barrier_lower.hide()

	left_trap_visuals.hide()
	right_trap_visuals.hide()

	left_rhythm_visuals.hide()
	right_rhythm_visuals.hide()

	board_overlay.hide()
	board_manager.hide()


func show_quake(side : Global.MySide) -> void:
	match side:
		Global.MySide.LEFT:
			left_quake_visuals.show()
		Global.MySide.RIGHT:
			right_quake_visuals.show()


func show_dread() -> void:
	dread_visuals.show()


func show_barrier(side : Global.MySide, pos : Beastie.Position) -> void:
	var array_for_match : Array = [side, pos]
	match array_for_match:
		[Global.MySide.LEFT, Beastie.Position.UPPER_BACK]:
			left_barrier_upper.show()
		[Global.MySide.LEFT, Beastie.Position.LOWER_BACK]:
			left_barrier_lower.show()
		[Global.MySide.RIGHT, Beastie.Position.UPPER_BACK]:
			right_barrier_upper.show()
		[Global.MySide.RIGHT, Beastie.Position.LOWER_BACK]:
			right_barrier_lower.show()


func show_trap(side : Global.MySide, stack : int) -> void:
	match side:
		Global.MySide.LEFT:
			left_trap_visuals.texture = TRAP_VISUALS_DICT.get(int(stack))[0]
			left_trap_visuals.show()
		Global.MySide.RIGHT:
			right_trap_visuals.texture = TRAP_VISUALS_DICT.get(int(stack))[1]
			right_trap_visuals.show()


func show_rhythm(side : Global.MySide) -> void:
	match side:
		Global.MySide.LEFT:
			left_rhythm_visuals.show()
		Global.MySide.RIGHT:
			right_rhythm_visuals.show()
