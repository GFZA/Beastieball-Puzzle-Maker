@tool
class_name  Healthbar
extends Node2D

const MAX_LABEL_LENGTH : int = 175
const DEFAULT_FONT_SIZE : int = 48

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


@onready var name_label: Label = %NameLabel
@onready var number_label: Label = %NumberLabel


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
