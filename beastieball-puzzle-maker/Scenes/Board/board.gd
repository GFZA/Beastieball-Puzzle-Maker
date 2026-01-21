@tool
class_name Board
extends Control

signal image_saved
signal field_effects_edit_requested

enum Turn {OFFENSE, DEFENSE, CSERVE, SERVE}
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

## IMPORTANT NOTE
# RALLY and DREAD visuals will be determinated by left dict only
# there should be codes to set both dict to have the same value of these anyway
var left_field_effects_dict : Dictionary[FieldEffect.Type, int] = {} :
	set(value):
		left_field_effects_dict = value
		_update_field_effect_visuals()
var right_field_effects_dict : Dictionary[FieldEffect.Type, int] = {} :
	set(value):
		right_field_effects_dict = value
		_update_field_effect_visuals()


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

@onready var edit_field_effects_button: Button = %EditFieldEffectsButton

@onready var board_add_beastie_button_anchor: Control = %BoardAddBeastieButtonAnchor
@onready var left_upper_bench_add_beastie_button: BoardAddBeastieButton = %LeftUpperBenchAddBeastieButton
@onready var left_lower_bench_add_beastie_button: BoardAddBeastieButton = %LeftLowerBenchAddBeastieButton
@onready var left_upper_add_beastie_button: BoardAddBeastieButton = %LeftUpperAddBeastieButton
@onready var left_lower_add_beastie_button: BoardAddBeastieButton = %LeftLowerAddBeastieButton
@onready var right_upper_add_beastie_button: BoardAddBeastieButton = %RightUpperAddBeastieButton
@onready var right_lower_add_beastie_button: BoardAddBeastieButton = %RightLowerAddBeastieButton
@onready var right_upper_bench_add_beastie_button: BoardAddBeastieButton = %RightUpperBenchAddBeastieButton
@onready var right_lower_bench_add_beastie_button: BoardAddBeastieButton = %RightLowerBenchAddBeastieButton


func _ready() -> void:
	board_manager.left_team_controller.field_effects_updated.connect(func(field_dict : Dictionary[FieldEffect.Type, int]):
		left_field_effects_dict = field_dict
		_update_field_effect_visuals()
	)
	board_manager.right_team_controller.field_effects_updated.connect(func(field_dict : Dictionary[FieldEffect.Type, int]):
		right_field_effects_dict = field_dict
		_update_field_effect_visuals()
	)
	edit_field_effects_button.pressed.connect(field_effects_edit_requested.emit)

	_update_field_effect_visuals()


func _update_field_effect_visuals() -> void:
	hide_all_field_effects()

	for i in 3:
		# First loop -> Left side field effects
		# Second loop -> Middle field effect USING LEFT DICT!!!
		# Third loop -> Right side field effects
		var field_dict : Dictionary[FieldEffect.Type, int] = left_field_effects_dict if i < 2 else right_field_effects_dict
		for field_effect : FieldEffect.Type in field_dict:
			var stack : int = field_dict[field_effect]
			if stack <= 0:
				continue
			if i == 1: # Middle Loop
				match field_effect:
					FieldEffect.Type.RALLY:
						show_rally()
					FieldEffect.Type.DREAD:
						show_dread()
			else:
				var side : Global.MySide = Global.MySide.LEFT if i == 0 else Global.MySide.RIGHT # when i == 2
				match field_effect:
					FieldEffect.Type.QUAKE:
						show_quake(side)
					FieldEffect.Type.BARRIER_UPPER:
						show_barrier(side, Beastie.Position.UPPER_FRONT)
					FieldEffect.Type.BARRIER_LOWER:
						show_barrier(side, Beastie.Position.LOWER_FRONT)
					FieldEffect.Type.TRAP:
						show_trap(side, stack)
					FieldEffect.Type.RHYTHM:
						show_rhythm(side)

	_update_field_effects_labels()


func _update_field_effects_labels() -> void:
	var left_text : String = ""
	var middle_text : String = ""
	var right_text : String = ""

	left_field_effecst_label.hide()
	middle_field_effecst_label.hide()
	right_field_effecst_label.hide()
	# YES it's a typo. No I'm not fixing it...

	for i in 3:
		# First loop -> Left side field effects
		# Second loop -> Middle field effect USING LEFT DICT!!!
		# Third loop -> Right side field effects
		var field_dict : Dictionary[FieldEffect.Type, int] = left_field_effects_dict if i < 2 else right_field_effects_dict
		for field_effect : FieldEffect.Type in field_dict:
			var stack : int = field_dict[field_effect]
			if stack <= 0:
				continue
			match i:
				0: # Left side
					match field_effect:
						FieldEffect.Type.QUAKE:
							left_text += "%s QUAKE" % str(stack) + "\n"
						FieldEffect.Type.TRAP:
							left_text += "%s/4 TRAP" % str(stack) + "\n"
						FieldEffect.Type.RHYTHM:
							left_text += "%s RHYTHM" % str(stack) + "\n"
						#FieldEffect.Type.BARRIER_UPPER, FieldEffect.Type.BARRIER_LOWER:
							# No text
				1: # Middle
					match field_effect:
						FieldEffect.Type.RALLY:
							middle_text += "%s/6 RALLY" % str(stack) + "\n"
						FieldEffect.Type.DREAD:
							middle_text += "%s DREAD" % str(stack) + "\n"
				2: # Right side
					match field_effect:
						FieldEffect.Type.QUAKE:
							right_text += "%s QUAKE" % str(stack) + "\n"
						FieldEffect.Type.TRAP:
							right_text += "%s/4 TRAP" % str(stack) + "\n"
						FieldEffect.Type.RHYTHM:
							right_text += "%s RHYTHM" % str(stack) + "\n"
						#FieldEffect.Type.BARRIER_UPPER, FieldEffect.Type.BARRIER_LOWER:
							# No text

	if not left_text == "":
		left_field_effecst_label.text = left_text.strip_edges()
		left_field_effecst_label.show()
	if not middle_text == "":
		middle_field_effecst_label.text = middle_text.strip_edges()
		middle_field_effecst_label.show()
	if not right_text == "":
		right_field_effecst_label.text = right_text.strip_edges()
		right_field_effecst_label.show()


func hide_all_field_effects() -> void:
	rallly_visuals.hide()
	dread_visuals.hide()
	left_quake_visuals.hide()
	left_barrier_upper.hide()
	left_barrier_lower.hide()
	left_trap_visuals.hide()
	left_rhythm_visuals.hide()
	right_quake_visuals.hide()
	right_barrier_upper.hide()
	right_barrier_lower.hide()
	right_trap_visuals.hide()
	right_rhythm_visuals.hide()


func show_rally() -> void:
	rallly_visuals.show()


func show_dread() -> void:
	dread_visuals.show()


func show_quake(side : Global.MySide) -> void:
	match side:
		Global.MySide.LEFT:
			left_quake_visuals.show()
		Global.MySide.RIGHT:
			right_quake_visuals.show()


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


func on_turn_changed(new_turn : Turn) -> void:
	board_overlay.on_turn_changed(new_turn)
	board_manager.on_turn_changed(new_turn)


func reset() -> void:
	for button in board_add_beastie_button_anchor.get_children():
		button.show()


func save_image(path : String) -> void:
	var image : Image = await capture_image()
	if Global.is_on_web:
		var raw : PackedByteArray = image.save_png_to_buffer()
		JavaScriptBridge.download_buffer(raw, "puzzle.png")
	else:
		image.save_png(path) # Path selected from PC FileDialog

	image_saved.emit()
	print("Image saved!")


func capture_image() -> Image:
	var original_size = sub_viewport.size
	sub_viewport_container.stretch = false
	sub_viewport.size = Vector2(2700, 2025) # Change result size here
								# (Hard-coded a bunch of stuff for this resolution though so please dont...)

	# Delay for rendering
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var image: Image = sub_viewport.get_texture().get_image()

	# Resetting subviewport
	sub_viewport.size = original_size
	sub_viewport_container.stretch = true

	return image
