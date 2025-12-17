@tool
class_name Healthbar
extends Control

const MAX_LABEL_LENGTH : int = 175
const DEFAULT_FONT_SIZE : int = 48

@export var my_side : Global.MySide = Global.MySide.LEFT :
	set(value):
		my_side = value
		_update_side(my_side)

@export var beastie_name : String = "Sprecko" :
	set(value):
		value = value.substr(0, 12)
		beastie_name = value
		update_name_label(beastie_name)

@export_range(0, 999) var sport_number : int = 123 :
	set(value):
		clamp(value, 0, 999)
		sport_number = value
		update_number_label(sport_number)

@export_range(0, 100) var stamina : int = 100 :
	set(value):
		clamp(value, 0, 100)
		stamina = value
		update_lifebar(stamina)

@export_color_no_alpha var color : Color = Color.GREEN :
	set(value):
		color = value
		update_color(color)

@onready var name_label: Label = %NameLabel
@onready var number_label: Label = %NumberLabel
@onready var lifebar: LifeBar = %Lifebar
@onready var level_label: Label = %LevelLabel
@onready var background_para: Parallelogram = %BackgroundPara
@onready var lower_spacer: Control = %LowerSpacer


func update_name_label(new_text : String) -> void:
	if not is_node_ready():
		await ready

	name_label.label_settings.font_size = DEFAULT_FONT_SIZE # Reset
	new_text = new_text.substr(0, 12)
	name_label.text = new_text

	var font : Font = name_label.label_settings.font
	var text_width := font.get_string_size(
		name_label.text,
		HORIZONTAL_ALIGNMENT_RIGHT,
		-1,
		DEFAULT_FONT_SIZE
	).x

	if text_width > MAX_LABEL_LENGTH:
		var font_scale : float = float(MAX_LABEL_LENGTH / text_width)
		name_label.label_settings.font_size = int(DEFAULT_FONT_SIZE * font_scale)
	else:
		name_label.label_settings.font_size = DEFAULT_FONT_SIZE


func update_number_label(new_number: int) -> void:
	if not is_node_ready():
		await ready

	if new_number == null:
		new_number = 0
	number_label.text = "#%s" % str(new_number)


func update_lifebar(new_stamina: int) -> void:
	if not is_node_ready():
		await ready
	lifebar.hp = new_stamina


func update_color(new_color : Color) -> void:
	if not is_node_ready():
		await ready
	lifebar.color = new_color
	level_label.label_settings.font_color = new_color


func _update_side(new_side : Global.MySide) -> void:
	if not is_node_ready():
		await ready

	if (not background_para.is_pointing_right() and new_side == Global.MySide.LEFT) or\
	   (background_para.is_pointing_right() and new_side == Global.MySide.RIGHT):
		background_para.filp_h()
		print("FLIP")

	lifebar.my_side = new_side

	# Absolute bandage fix. Screw this...
	if my_side == Global.MySide.RIGHT:
		lower_spacer.custom_minimum_size.x = 25.0
	else:
		lower_spacer.custom_minimum_size.x = 15.0
