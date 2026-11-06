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
			_update_lifebar(100)
			_update_level_label(50)

			if beastie:
				if beastie.my_name_updated.is_connected(_update_name_label):
					beastie.my_name_updated.disconnect(_update_name_label)
				if beastie.sport_number_updated.is_connected(_update_number_label):
					beastie.sport_number_updated.disconnect(_update_number_label)
				if beastie.health_updated.is_connected(_update_lifebar):
					beastie.health_updated.disconnect(_update_lifebar)
				if beastie.level_updated.is_connected(_update_level_label):
					beastie.level_updated.disconnect(_update_level_label)

			beastie = value
			return

		beastie = value # Must not duplicate so it's the same one from BeastieScene!
		beastie.my_name_updated.connect(_update_name_label)
		beastie.sport_number_updated.connect(_update_number_label)
		beastie.health_updated.connect(_update_lifebar)
		beastie.level_updated.connect(_update_level_label)
		if beastie.sport_number == null:
			_update_number_label(beastie.beastiepedia_id)
		else:
			_update_number_label(beastie.sport_number)
		_update_lifebar(beastie.health)
		_update_level_label(beastie.level)
		beastie_name = beastie.my_name
		color = beastie.bar_color

@export var benched : bool = false :
	set(value):
		benched = value
		_update_benched()

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
		_update_name_label(beastie_name)

var sport_number : int = 123 :
	set(value):
		clamp(value, 0, 999)
		sport_number = value
		_update_number_label(sport_number)

var level : int = 50 :
	set(value):
		clamp(value, 1, 100)
		level = value
		_update_level_label(level)

var color : Color = Color.GREEN :
	set(value):
		color = value
		_update_color(color)

var my_name_setting : LabelSettings = null
var my_level_setting : LabelSettings = null

@onready var background_para: Parallelogram = %BackgroundPara

@onready var upper_spacer: Control = %UpperSpacer
@onready var upper_bench_spacer: Control = %UpperBenchSpacer
@onready var name_label: Label = %NameLabel
@onready var number_label: Label = %NumberLabel
@onready var upper_spacer_2: Control = %UpperSpacer2

@onready var lower_spacer: Control = %LowerSpacer
@onready var lifebar: LifeBar = %Lifebar
@onready var lower_spacer_2: Control = %LowerSpacer2
@onready var level_label: Label = %LevelLabel

@onready var my_nodes_to_hide := [
	background_para,
	upper_spacer, name_label, number_label, upper_spacer_2,
	lower_spacer, lower_spacer_2, level_label
] # Can't use node group as it will add nodes from other BeastieScene


func _ready() -> void:
	if not is_node_ready():
		await ready

	my_name_setting = name_label.label_settings.duplicate()
	name_label.label_settings = my_name_setting

	my_level_setting = level_label.label_settings.duplicate()
	level_label.label_settings = my_level_setting


func _update_name_label(assigned_name : String) -> void:
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


func _update_number_label(new_number: int) -> void:
	if not is_node_ready():
		await ready

	if new_number == null:
		new_number = beastie.beastiepedia_id

	if new_number < 100:
		number_label.text = "#%02d" % new_number
	else:
		number_label.text = "#%03d" % new_number


func _update_lifebar(new_stamina: int) -> void:
	if not is_node_ready():
		await ready
	lifebar.hp = new_stamina


func _update_color(new_color : Color) -> void:
	if not is_node_ready():
		await ready
	lifebar.color = new_color
	my_level_setting.font_color = new_color


func _update_level_label(new_level : int) -> void:
	if not is_node_ready():
		await ready
	level_label.text = "Lv%s" % str(new_level)


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


func _update_benched() -> void:
	if not is_node_ready():
		await ready

	for node in my_nodes_to_hide:
		if benched:
			node.hide()
			upper_bench_spacer.show()
		else:
			node.show()
			upper_bench_spacer.hide()
