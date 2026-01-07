@tool
class_name NumberUI
extends HBoxContainer

signal value_updated(value : int)

@export_range(0, 99) var num : int = 0 :
	set(value):
		num = clamp(value, value_min, value_max)
		_update_ui()

@export_range(0, 99) var default : int = 0
@export_range(0, 99) var value_min : int = 0
@export_range(0, 99) var value_max : int = 99

@onready var reset_button: Button = %ResetButton
@onready var number_label: Label = %NumberLabel
@onready var up_button: Button = %UpButton
@onready var down_button: Button = %DownButton
@onready var max_button: Button = %MaxButton


func _ready() -> void:
	reset_button.pressed.connect(func(): num = default)
	up_button.pressed.connect(func(): num += 1)
	down_button.pressed.connect(func(): num -= 1)
	max_button.pressed.connect(func(): num = value_max)

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
