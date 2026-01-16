@tool
class_name FieldEffectsMenu
extends ScrollContainer

signal rally_stack_changed(new_stack : int)
signal dread_stack_changed(new_stack : int)
signal left_rhythm_stack_changed(new_stack : int)
signal left_trap_stack_changed(new_stack : int)
signal left_quake_stack_changed(new_stack : int)
signal left_barrier_upper_stack_changed(new_stack : int)
signal left_barrier_lower_stack_changed(new_stack : int)
signal right_rhythm_stack_changed(new_stack : int)
signal right_trap_stack_changed(new_stack : int)
signal right_quake_stack_changed(new_stack : int)
signal right_barrier_upper_stack_changed(new_stack : int)
signal right_barrier_lower_stack_changed(new_stack : int)


@onready var rally_number_ui: NumberUI = %RallyNumberUI
@onready var dread_number_ui: NumberUI = %DreadNumberUI
@onready var both_side_clear_button: Button = %BothSideClearButton

@onready var left_rhythm_number_ui: NumberUI = %LeftRhythmNumberUI
@onready var left_trap_number_ui: NumberUI = %LeftTrapNumberUI
@onready var left_quake_number_ui: NumberUI = %LeftQuakeNumberUI
@onready var left_barrier_upper_number_ui: NumberUI = %LeftBarrierUpperNumberUI # Unused
@onready var left_barrier_lower_number_ui: NumberUI = %LeftBarrierLowerNumberUI # Unused
@onready var left_barrier_upper_check_box: CheckBox = %LeftBarrierUpperCheckBox
@onready var left_barrier_lower_check_box: CheckBox = $MainContainer/BarrierLowerLabel/LeftBarrierLowerCheckBox

@onready var right_rhythm_number_ui: NumberUI = %RightRhythmNumberUI
@onready var right_trap_number_ui: NumberUI = %RightTrapNumberUI
@onready var right_quake_number_ui: NumberUI = %RightQuakeNumberUI
@onready var right_barrier_upper_number_ui: NumberUI = %RightBarrierUpperNumberUI # Unused
@onready var right_barrier_lower_number_ui: NumberUI = %RightBarrierLowerNumberUI # Unused
@onready var right_barrier_upper_check_box: CheckBox = %RightBarrierUpperCheckBox
@onready var right_barrier_lower_check_box: CheckBox = %RightBarrierLowerCheckBox


func _ready() -> void:
	rally_number_ui.value_updated.connect(rally_stack_changed.emit)
	dread_number_ui.value_updated.connect(dread_stack_changed.emit)
	both_side_clear_button.pressed.connect(clear_both_side)

	left_rhythm_number_ui.value_updated.connect(left_rhythm_stack_changed.emit)
	left_trap_number_ui.value_updated.connect(left_trap_stack_changed.emit)
	left_quake_number_ui.value_updated.connect(left_quake_stack_changed.emit)
	left_barrier_upper_number_ui.value_updated.connect(left_barrier_upper_stack_changed.emit) # Unused
	left_barrier_lower_number_ui.value_updated.connect(left_barrier_lower_stack_changed.emit) # Unused
	left_barrier_upper_check_box.toggled.connect(_on_barrier_upper_check_box_toggled.bind(Global.MySide.LEFT))
	left_barrier_lower_check_box.toggled.connect(_on_barrier_lower_check_box_toggled.bind(Global.MySide.LEFT))

	right_rhythm_number_ui.value_updated.connect(right_rhythm_stack_changed.emit)
	right_trap_number_ui.value_updated.connect(right_trap_stack_changed.emit)
	right_quake_number_ui.value_updated.connect(right_quake_stack_changed.emit)
	right_barrier_upper_number_ui.value_updated.connect(right_barrier_upper_stack_changed.emit) # Unused
	right_barrier_lower_number_ui.value_updated.connect(right_barrier_lower_stack_changed.emit) # Unused
	right_barrier_upper_check_box.toggled.connect(_on_barrier_upper_check_box_toggled.bind(Global.MySide.RIGHT))
	right_barrier_lower_check_box.toggled.connect(_on_barrier_lower_check_box_toggled.bind(Global.MySide.RIGHT))


func reset()	-> void:
	clear_both_side()
	clear_left_side()
	clear_right_side()
	scroll_vertical = 0


func clear_both_side() -> void:
	rally_number_ui.reset()
	dread_number_ui.reset()
	clear_left_side()
	clear_right_side()


func clear_left_side() -> void:
	left_rhythm_number_ui.reset()
	left_trap_number_ui.reset()
	left_quake_number_ui.reset()
	left_barrier_upper_number_ui.reset() # Unused
	left_barrier_lower_number_ui.reset() # Unused
	left_barrier_upper_check_box.button_pressed = false
	left_barrier_lower_check_box.button_pressed = false


func clear_right_side() -> void:
	right_rhythm_number_ui.reset()
	right_trap_number_ui.reset()
	right_quake_number_ui.reset()
	right_barrier_upper_number_ui.reset() # Unused
	right_barrier_lower_number_ui.reset() # Unused
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
