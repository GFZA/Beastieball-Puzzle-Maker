@tool
class_name BeastieMenu
extends ScrollContainer

const STAMINA_FILL_STYLEBOX := preload("uid://ci28vvsldarw1")

@export var beastie : Beastie = null :
	set(value):
		beastie = value
		_update_beastie()

var side : Global.MySide = Global.MySide.LEFT

@onready var name_label: Label = %NameLabel
@onready var sprite_texture_rec: TextureRect = %SpriteTextureRec

@onready var custom_name_line_edit: LineEdit = %CustomNameLineEdit
@onready var custom_number_line_edit: LineEdit = %CustomNumberLineEdit

@onready var stamina_slider: HSlider = %StaminaSlider
@onready var stamina_progress_bar: ProgressBar = %StaminaProgressBar
@onready var stamina_label: Label = %StaminaLabel

@onready var tab_container: TabContainer = %TabContainer
@onready var position_tab: TabBar = %_Position_
@onready var plays_tab: TabBar = %_Plays_
@onready var feelings_tab: TabBar = %_Feelings_
@onready var invests_tab: TabBar = %_Invests_


func _ready() -> void:
	stamina_slider.value_changed.connect(_on_stamina_slider_value_changed)
	custom_name_line_edit.text_submitted.connect(custom_name_line_edit.release_focus.unbind(1))
	custom_number_line_edit.text_submitted.connect(custom_number_line_edit.release_focus.unbind(1))


func reset() -> void:
	beastie = null
	scroll_vertical = 0


func _update_beastie() -> void:
	if not is_node_ready():
		await ready

	if not beastie:
		name_label.text = "UNKNOWN"
		sprite_texture_rec.texture = null
		custom_name_line_edit.placeholder_text = "Name"
		custom_number_line_edit.placeholder_text = "999"
		_update_stamina_progress_bar_stylebox()
		return
	name_label.text = beastie.specie_name
	sprite_texture_rec.texture = beastie.get_sprite(Beastie.Sprite.ICON)
	custom_name_line_edit.placeholder_text = beastie.specie_name
	custom_number_line_edit.placeholder_text = str(beastie.beastiepedia_id)
	_update_stamina_progress_bar_stylebox()


func _on_stamina_slider_value_changed(new_value : int) -> void:
	stamina_progress_bar.value = new_value
	stamina_label.text = str(new_value)
	# emit signal


func _update_stamina_progress_bar_stylebox() -> void:
	var new_stylebox : StyleBoxFlat = STAMINA_FILL_STYLEBOX.duplicate()
	new_stylebox.bg_color = Color.GREEN if not beastie else beastie.bar_color
	stamina_progress_bar.add_theme_stylebox_override("fill", new_stylebox)
