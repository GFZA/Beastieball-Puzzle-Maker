@tool
class_name NumberUI
extends HBoxContainer

signal value_updated(value : int)

@export_range(-99, 99) var num : int = 0 :
	set(value):
		num = clamp(value, value_min, value_max)
		_update_ui()

@export_range(-99, 99) var default : int = 0
@export_range(-99, 99) var value_min : int = -99
@export_range(-99, 99) var value_max : int = 99

@export var side : Global.MySide = Global.MySide.RIGHT:
	set(value):
		side = value
		_update_side()

@export var show_min_button : bool = false :
	set(value):
		show_min_button = value
		if not is_node_ready():
			await ready
		min_button_spacer.visible = value
		min_button.visible = value

@onready var reset_button: Button = %ResetButton
@onready var number_label: Label = %NumberLabel
@onready var up_down_button_container: VBoxContainer = %UpDownButtonContainer
@onready var up_button: Button = %UpButton
@onready var down_button: Button = %DownButton
@onready var spacer: Control = %Spacer
@onready var max_button: Button = %MaxButton
@onready var min_button_spacer: Control = %MinButtonSpacer
@onready var min_button: Button = %MinButton


func _ready() -> void:
	reset_button.pressed.connect(func(): num = default)
	up_button.pressed.connect(func(): num += 1)
	down_button.pressed.connect(func(): num -= 1)
	max_button.pressed.connect(func(): num = value_max)
	min_button.pressed.connect(func(): num = value_min)

	reset()


func reset() -> void:
	num = default
	reset_button.hide()


func _update_ui() -> void:
	if not is_node_ready():
		await ready
	number_label.text = str(num)
	reset_button.visible = not (num == default)
	value_updated.emit(num)


func _update_side() -> void:
	if not is_node_ready():
		await ready

	# Ugly code. Pretty outcome. Worth it(?)
	match side:
		Global.MySide.LEFT:
			move_child(max_button, 0)
			move_child(spacer, 1)
			move_child(min_button, 2)
			move_child(min_button_spacer, 3)
			move_child(up_down_button_container, 4)
			move_child(number_label, 5)
			move_child(reset_button, 6)
		Global.MySide.RIGHT:
			move_child(reset_button, 0)
			move_child(number_label, 1)
			move_child(up_down_button_container, 2)
			move_child(spacer, 3)
			move_child(max_button, 4)
			move_child(min_button_spacer, 5)
			move_child(min_button, 6)
