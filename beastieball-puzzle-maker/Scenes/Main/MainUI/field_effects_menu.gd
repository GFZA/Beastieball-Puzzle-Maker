@tool
class_name FieldEffectsMenu
extends ScrollContainer


signal left_rally_stack_changed(new_stack : int)
signal left_dread_stack_changed(new_stack : int)
signal left_rhythm_stack_changed(new_stack : int)
signal left_trap_stack_changed(new_stack : int)
signal left_quake_stack_changed(new_stack : int)
signal left_barrier_upper_stack_changed(new_stack : int)
signal left_barrier_lower_stack_changed(new_stack : int)

signal right_rally_stack_changed(new_stack : int)
signal right_dread_stack_changed(new_stack : int)
signal right_rhythm_stack_changed(new_stack : int)
signal right_trap_stack_changed(new_stack : int)
signal right_quake_stack_changed(new_stack : int)
signal right_barrier_upper_stack_changed(new_stack : int)
signal right_barrier_lower_stack_changed(new_stack : int)


@onready var left_rally_number_ui: NumberUI = %LeftRallyNumberUI
@onready var left_dread_number_ui: NumberUI = %LeftDreadNumberUI
@onready var left_rhythm_number_ui: NumberUI = %LeftRhythmNumberUI
@onready var left_trap_number_ui: NumberUI = %LeftTrapNumberUI
@onready var left_quake_number_ui: NumberUI = %LeftQuakeNumberUI
@onready var left_barrier_upper_number_ui: NumberUI = %LeftBarrierUpperNumberUI # Unused
@onready var left_barrier_lower_number_ui: NumberUI = %LeftBarrierLowerNumberUI # Unused
@onready var left_barrier_upper_check_box: CheckBox = %LeftBarrierUpperCheckBox
@onready var left_barrier_lower_check_box: CheckBox = $MainContainer/BarrierLowerLabel/LeftBarrierLowerCheckBox

@onready var right_rally_number_ui: NumberUI = %RightRallyNumberUI
@onready var right_dread_number_ui: NumberUI = %RightDreadNumberUI
@onready var right_rhythm_number_ui: NumberUI = %RightRhythmNumberUI
@onready var right_trap_number_ui: NumberUI = %RightTrapNumberUI
@onready var right_quake_number_ui: NumberUI = %RightQuakeNumberUI
@onready var right_barrier_upper_number_ui: NumberUI = %RightBarrierUpperNumberUI # Unused
@onready var right_barrier_lower_number_ui: NumberUI = %RightBarrierLowerNumberUI # Unused
@onready var right_barrier_upper_check_box: CheckBox = %RightBarrierUpperCheckBox
@onready var right_barrier_lower_check_box: CheckBox = %RightBarrierLowerCheckBox

@onready var both_side_clear_button: Button = %BothSideClearButton


func _ready() -> void:
	left_rally_number_ui.value_updated.connect(left_rally_stack_changed.emit)
	left_dread_number_ui.value_updated.connect(left_dread_stack_changed.emit)
	left_rhythm_number_ui.value_updated.connect(left_rhythm_stack_changed.emit)
	left_trap_number_ui.value_updated.connect(left_trap_stack_changed.emit)
	left_quake_number_ui.value_updated.connect(left_quake_stack_changed.emit)
	#left_barrier_upper_number_ui.value_updated.connect(left_barrier_upper_stack_changed.emit) # Unused but still in scene
	#left_barrier_lower_number_ui.value_updated.connect(left_barrier_lower_stack_changed.emit) # Unused but still in scene
	left_barrier_upper_check_box.toggled.connect(_on_barrier_upper_check_box_toggled.bind(Global.MySide.LEFT))
	left_barrier_lower_check_box.toggled.connect(_on_barrier_lower_check_box_toggled.bind(Global.MySide.LEFT))

	right_rally_number_ui.value_updated.connect(right_rally_stack_changed.emit)
	right_dread_number_ui.value_updated.connect(right_dread_stack_changed.emit)
	right_rhythm_number_ui.value_updated.connect(right_rhythm_stack_changed.emit)
	right_trap_number_ui.value_updated.connect(right_trap_stack_changed.emit)
	right_quake_number_ui.value_updated.connect(right_quake_stack_changed.emit)
	#right_barrier_upper_number_ui.value_updated.connect(right_barrier_upper_stack_changed.emit) # Unused but still in scene
	#right_barrier_lower_number_ui.value_updated.connect(right_barrier_lower_stack_changed.emit) # Unused but still in scene
	right_barrier_upper_check_box.toggled.connect(_on_barrier_upper_check_box_toggled.bind(Global.MySide.RIGHT))
	right_barrier_lower_check_box.toggled.connect(_on_barrier_lower_check_box_toggled.bind(Global.MySide.RIGHT))

	both_side_clear_button.pressed.connect(clear_both_side)


func reset() -> void:
	clear_both_side()
	clear_left_side()
	clear_right_side()
	scroll_vertical = 0


func load_from_data(board_data : BoardData) -> void:
	var left_dict : Dictionary = board_data.left_team_dict["field_effects"]
	var right_dict : Dictionary = board_data.right_team_dict["field_effects"]

	left_rally_number_ui.num = _get_stack(left_dict, FieldEffect.Type.RALLY)
	left_dread_number_ui.num = _get_stack(left_dict, FieldEffect.Type.DREAD)
	left_rhythm_number_ui.num = _get_stack(left_dict, FieldEffect.Type.RHYTHM)
	left_trap_number_ui.num = _get_stack(left_dict, FieldEffect.Type.TRAP)
	left_quake_number_ui.num = _get_stack(left_dict, FieldEffect.Type.QUAKE)
	#left_barrier_upper_number_ui.num = _get_stack(left_dict, FieldEffect.Type.BARRIER_UPPER) # Unused but still in scene
	#left_barrier_lower_number_ui.num = _get_stack(left_dict, FieldEffect.Type.BARRIER_LOWER) # Unused but still in scene
	left_barrier_upper_check_box.button_pressed = _get_stack(left_dict, FieldEffect.Type.BARRIER_UPPER) > 0
	left_barrier_lower_check_box.button_pressed = _get_stack(left_dict, FieldEffect.Type.BARRIER_LOWER) > 0

	right_rally_number_ui.num = _get_stack(right_dict, FieldEffect.Type.RALLY)
	right_dread_number_ui.num = _get_stack(right_dict, FieldEffect.Type.DREAD)
	right_rhythm_number_ui.num = _get_stack(right_dict, FieldEffect.Type.RHYTHM)
	right_trap_number_ui.num = _get_stack(right_dict, FieldEffect.Type.TRAP)
	right_quake_number_ui.num = _get_stack(right_dict, FieldEffect.Type.QUAKE)
	#right_barrier_upper_number_ui.num = _get_stack(right_dict, FieldEffect.Type.BARRIER_UPPER) # Unused but still in scene
	#right_barrier_lower_number_ui.num = _get_stack(right_dict, FieldEffect.Type.BARRIER_LOWER) # Unused but still in scene
	right_barrier_upper_check_box.button_pressed = _get_stack(right_dict, FieldEffect.Type.BARRIER_UPPER) > 0
	right_barrier_lower_check_box.button_pressed = _get_stack(right_dict, FieldEffect.Type.BARRIER_LOWER) > 0


func _get_stack(dict : Dictionary, type : FieldEffect.Type) -> int:
	if dict.get(type) == null:
		return 0
	return dict.get(type)


func clear_both_side() -> void:
	Global.pause_updating_field = true
	clear_left_side()
	clear_right_side()
	if not Global.resetting:
		Global.pause_updating_field = false
	left_rhythm_number_ui.reset() # Need to force update on each side again for some reason
	right_rhythm_number_ui.reset() # or else the team will just become invisible


func clear_left_side() -> void:
	left_rally_number_ui.reset()
	left_dread_number_ui.reset()
	left_rhythm_number_ui.reset()
	left_trap_number_ui.reset()
	left_quake_number_ui.reset()
	#left_barrier_upper_number_ui.reset() # Unused but still in scene
	#left_barrier_lower_number_ui.reset() # Unused but still in scene
	left_barrier_upper_check_box.button_pressed = false
	left_barrier_lower_check_box.button_pressed = false


func clear_right_side() -> void:
	right_rally_number_ui.reset()
	right_dread_number_ui.reset()
	right_rhythm_number_ui.reset()
	right_trap_number_ui.reset()
	right_quake_number_ui.reset()
	#right_barrier_upper_number_ui.reset() # Unused but still in scene
	#right_barrier_lower_number_ui.reset() # Unused but still in scene
	right_barrier_upper_check_box.button_pressed = false
	right_barrier_lower_check_box.button_pressed = false


func _on_barrier_upper_check_box_toggled(toggled_on : bool, side : Global.MySide) -> void:
	var stack : int = int(toggled_on)
	match side:
		Global.MySide.LEFT:
			left_barrier_upper_stack_changed.emit(stack)
		Global.MySide.RIGHT:
			right_barrier_upper_stack_changed.emit(stack)


func _on_barrier_lower_check_box_toggled(toggled_on : bool, side : Global.MySide) -> void:
	var stack : int = int(toggled_on)
	match side:
		Global.MySide.LEFT:
			left_barrier_lower_stack_changed.emit(stack)
		Global.MySide.RIGHT:
			right_barrier_lower_stack_changed.emit(stack)
