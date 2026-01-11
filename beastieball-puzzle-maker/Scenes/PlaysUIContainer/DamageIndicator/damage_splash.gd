@tool
class_name DamageSplash
extends MarginContainer

const DEFAULT_FONT_SIZE : int = 72
const BREAK_TEXT_FONT_SIZE : int = 60

@export_exp_easing() var amount : int = 0 :
	set(value):
		if value != Global.BREAK_TEXT_DAMAGE:
			value = clamp(value, 0, INF)
		amount = value
		_update_number_label()

@export var attack : Attack = null :
	set(value):
		attack = value
		_update_color()

var my_label_setting : LabelSettings = null

@onready var number_label: Label = %NumberLabel
@onready var bg_splash: Polygon2D = %BGSplash


func _ready() -> void:
	my_label_setting = number_label.label_settings.duplicate()
	number_label.label_settings = my_label_setting


func _update_number_label() -> void:
	if not is_node_ready():
		await ready

	if amount == Global.BREAK_TEXT_DAMAGE:
		number_label.text = "Break!"
		my_label_setting.font_size = BREAK_TEXT_FONT_SIZE
		return

	number_label.text = str(amount)
	my_label_setting.font_size = DEFAULT_FONT_SIZE


func _update_color() -> void:
	if not is_node_ready():
		await ready
	var new_color : Color = Color.GREEN
	if attack:
		var index : int = int(attack.type)
		var color_type := index as Global.ColorType
		new_color = Global.get_main_color(color_type)
	bg_splash.color = new_color
	my_label_setting.font_color = new_color
