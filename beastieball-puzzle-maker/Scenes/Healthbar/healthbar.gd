@tool
class_name Healthbar
extends Control

const MAX_LABEL_LENGTH : int = 150
const DEFAULT_FONT_SIZE : int = 48


@export var beastie : Beastie = null :
	set(value):
		if not is_node_ready():
			await ready

		if value == null:
			beastie_name = "Sprecko"
			sport_number = 123
			color = Color.GREEN
			update_lifebar(100)

			if beastie:
				if beastie.my_name_updated.is_connected(update_name_label):
					beastie.my_name_updated.disconnect(update_name_label)
				if beastie.sport_number_updated.is_connected(update_number_label):
					beastie.sport_number_updated.disconnect(update_number_label)
				if beastie.health_updated.is_connected(update_lifebar):
					beastie.health_updated.disconnect(update_lifebar)

			beastie = value
			return

		beastie = value # Must not duplicate so it's the same one from BeastieScene!
		beastie.my_name_updated.connect(update_name_label)
		beastie.sport_number_updated.connect(update_number_label)
		beastie.health_updated.connect(update_lifebar)
		update_lifebar(beastie.health)
		beastie_name = beastie.my_name
		sport_number = beastie.sport_number
		color = beastie.bar_color

@export var my_side : Global.MySide = Global.MySide.LEFT :
	set(value):
		my_side = value
		update_side(my_side)

@export var h_allign : HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER :
	set(value):
		h_allign = value
		if not is_node_ready():
			await ready
		lifebar.h_allign = h_allign

var beastie_name : String = "Sprecko" :
	set(value):
		value = value.substr(0, 12)
		beastie_name = value
		update_name_label(beastie_name)

var sport_number : int = 123 :
	set(value):
		clamp(value, 0, 999)
		sport_number = value
		update_number_label(sport_number)

var color : Color = Color.GREEN :
	set(value):
		color = value
		update_color(color)

var my_name_setting : LabelSettings = null
var my_level_setting : LabelSettings = null

@onready var name_label: Label = %NameLabel
@onready var number_label: Label = %NumberLabel
@onready var lifebar: LifeBar = %Lifebar
@onready var level_label: Label = %LevelLabel
@onready var background_para: Parallelogram = %BackgroundPara
@onready var lower_spacer: Control = %LowerSpacer

func _ready() -> void:
	if not is_node_ready():
		await ready

	my_name_setting = name_label.label_settings.duplicate()
	name_label.label_settings = my_name_setting

	my_level_setting = level_label.label_settings.duplicate()
	level_label.label_settings = my_level_setting


func update_name_label(assigned_name : String) -> void:
	if not is_node_ready():
		await ready

	my_name_setting.font_size = DEFAULT_FONT_SIZE # Reset
	assigned_name = assigned_name.substr(0, 12)
	var new_name : String = ""
	if assigned_name == "" and beastie:
		new_name = beastie.specie_name
	else:
		new_name = assigned_name
	name_label.text = new_name

	var font : Font = my_name_setting.font
	var text_width := font.get_string_size(
		name_label.text,
		HORIZONTAL_ALIGNMENT_RIGHT,
		-1,
		DEFAULT_FONT_SIZE
	).x

	if text_width > MAX_LABEL_LENGTH:
		var font_scale : float = float(MAX_LABEL_LENGTH / text_width)
		my_name_setting.font_size = int(DEFAULT_FONT_SIZE * font_scale)
	else:
		my_name_setting.font_size = DEFAULT_FONT_SIZE


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
	my_level_setting.font_color = new_color


func update_side(new_side : Global.MySide) -> void:
	if not is_node_ready():
		await ready

	background_para.flip_h = (new_side == Global.MySide.LEFT)
	lifebar.my_side = new_side


	# Absolute bandage fix. Screw this...
	if new_side == Global.MySide.RIGHT:
		lower_spacer.custom_minimum_size.x = 25.0
	else:
		lower_spacer.custom_minimum_size.x = 15.0
