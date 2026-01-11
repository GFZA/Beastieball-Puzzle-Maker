@tool
class_name Board
extends Control

signal image_saved

enum Turn {OFFENSE, DEFENSE, SERVE}
enum TrapStack {ZERO = 0, ONE = 1, TWO = 2, THREE = 3, FOUR = 4}

const TRAP_VISUALS_DICT : Dictionary[TrapStack, Array] = {
	TrapStack.ZERO : [null, null],
	TrapStack.ONE : [preload("uid://be4fx7xip2lal"), preload("uid://bvywpvocaqq32")], # [LEFT, RIGHT]
	TrapStack.TWO : [preload("uid://chq4iwkouargt"), preload("uid://bn1gn7878iqx4")],
	TrapStack.THREE : [preload("uid://dch8q1l4yem4q"), preload("uid://jw5124rypo20")],
	TrapStack.FOUR : [preload("uid://b12tfn7n1l8qs"), preload("uid://sxxdcxrcur20")],
}

@export_tool_button("Get Image!") var tool_button_var : Callable = save_image

@export_range(1, 999, 1) var image_number : int = 1

@onready var sub_viewport_container: SubViewportContainer = %SubViewportContainer
@onready var sub_viewport: SubViewport = %SubViewport

@onready var rallly_visuals: Node2D = %RalllyVisuals

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

@onready var left_field_effecst_label: Label = %LeftFieldEffecstLabel
@onready var middle_field_effecst_label: Label = %MiddleFieldEffecstLabel
@onready var right_field_effecst_label: Label = %RightFieldEffecstLabel


func _ready() -> void:
	board_manager.left_team_controller.field_effects_updated.connect(show_field_effects_visuals_from_dict.bind(Global.MySide.LEFT))
	board_manager.right_team_controller.field_effects_updated.connect(show_field_effects_visuals_from_dict.bind(Global.MySide.RIGHT))


func show_field_effects_visuals_from_dict(field_dict : Dictionary[FieldEffect.Type, int], side : Global.MySide) -> void:
	hide_field_visuals_for_side(side)
	if not field_dict:
		return

	for field_effect : FieldEffect.Type in field_dict:
		var stack : int = field_dict[field_effect]
		if stack <= 0:
			continue
		match field_effect:
			FieldEffect.Type.RALLY:
				show_rally()
			FieldEffect.Type.QUAKE:
				show_quake(side)
			FieldEffect.Type.DREAD:
				show_dread()
			FieldEffect.Type.BARRIER_UPPER:
				show_barrier(side, Beastie.Position.UPPER_FRONT)
			FieldEffect.Type.BARRIER_LOWER:
				show_barrier(side, Beastie.Position.LOWER_FRONT)
			FieldEffect.Type.TRAP:
				show_trap(side, field_dict[field_effect])
			FieldEffect.Type.RHYTHM:
				show_rhythm(side)

	_update_field_effects_labels(field_dict, side)


func _update_field_effects_labels(field_dict : Dictionary[FieldEffect.Type, int], side : Global.MySide) -> void:

	# This is such a mess
	# Fix tomorrow...

	if not is_node_ready():
		await ready

	if not field_dict or field_dict.is_empty():
		if side == Global.MySide.LEFT:
			left_field_effecst_label.text = ""
		else:
			right_field_effecst_label.text = ""
		return

	var side_text : String = ""
	#var middle_text : String = ""
	for field_effect : FieldEffect.Type in field_dict:
		var stack : int = field_dict[field_effect]
		if stack <= 0:
			continue
		match field_effect:
			#FieldEffect.Type.RALLY:
				#middle_text += "%s/6 RALLY" % str(stack) + "\n"
			#FieldEffect.Type.DREAD:
				#middle_text += "%s DREAD" % str(stack) + "\n"
			FieldEffect.Type.QUAKE:
				side_text += "%s QUAKE" % str(stack) + "\n"
			FieldEffect.Type.TRAP:
				side_text += "%s/4 TRAP" % str(stack) + "\n"
			FieldEffect.Type.RHYTHM:
				side_text += "%s RHYTHM" % str(stack) + "\n"
			#FieldEffect.Type.BARRIER_UPPER, FieldEffect.Type.BARRIER_LOWER:
				# No text

	if side == Global.MySide.LEFT:
		left_field_effecst_label.text = side_text.strip_edges()
	else:
		right_field_effecst_label.text = side_text.strip_edges()

	#middle_field_effecst_label.text = middle_text.strip_edges()


func hide_field_visuals_for_side(side : Global.MySide) -> void:
	if side == Global.MySide.LEFT:
		left_quake_visuals.hide()
		left_barrier_upper.hide()
		left_barrier_lower.hide()
		left_trap_visuals.hide()
		left_rhythm_visuals.hide()
	else:
		right_quake_visuals.hide()
		right_barrier_upper.hide()
		right_barrier_lower.hide()
		right_trap_visuals.hide()
		right_rhythm_visuals.hide()


func show_rally() -> void:
	rallly_visuals.show()


func show_quake(side : Global.MySide) -> void:
	match side:
		Global.MySide.LEFT:
			left_quake_visuals.show()
		Global.MySide.RIGHT:
			right_quake_visuals.show()


func show_dread() -> void:
	dread_visuals.show()


func show_barrier(side : Global.MySide, pos : Beastie.Position) -> void:
	assert(pos in [Beastie.Position.UPPER_FRONT, Beastie.Position.LOWER_FRONT], "show_barrier only accpet front positions!")
	var array_for_match : Array = [side, pos]
	match array_for_match:
		[Global.MySide.LEFT, Beastie.Position.UPPER_FRONT]:
			left_barrier_upper.show()
		[Global.MySide.LEFT, Beastie.Position.LOWER_FRONT]:
			left_barrier_lower.show()
		[Global.MySide.RIGHT, Beastie.Position.UPPER_FRONT]:
			right_barrier_upper.show()
		[Global.MySide.RIGHT, Beastie.Position.LOWER_FRONT]:
			right_barrier_lower.show()


func show_trap(side : Global.MySide, stack : int) -> void:
	stack = clamp(stack, 0, 4)
	if stack == 0:
		return

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
