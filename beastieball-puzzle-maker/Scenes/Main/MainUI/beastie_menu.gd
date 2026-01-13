@tool
class_name BeastieMenu
extends ScrollContainer

const STAMINA_FILL_STYLEBOX := preload("uid://ci28vvsldarw1")

@export var beastie : Beastie = null :
	set(value):
		beastie = value
		_update_beastie()

@export var side : Global.MySide = Global.MySide.LEFT :
	set(value):
		side = value
		_update_side()

var team_pos : TeamController.TeamPosition = TeamController.TeamPosition.FIELD_1

@onready var name_label: Label = %NameLabel
@onready var sprite_texture_rec: TextureRect = %SpriteTextureRec

@onready var custom_name_line_edit: LineEdit = %CustomNameLineEdit
@onready var custom_number_line_edit: LineEdit = %CustomNumberLineEdit

@onready var stamina_slider: HSlider = %StaminaSlider
@onready var stamina_progress_bar: ProgressBar = %StaminaProgressBar
@onready var stamina_label: Label = %StaminaLabel

@onready var tab_container: TabContainer = %TabContainer

@onready var on_field_tab: TabBar = %"_On Field_"
@onready var pos_tab_upper_button_container: HBoxContainer = %UpperButtonContainer
@onready var pos_tab_upper_back_button: Button = %UpperBackButton
@onready var pos_tab_upper_front_button: Button = %UpperFrontButton
@onready var pos_tab_lower_button_container: HBoxContainer = %LowerButtonContainer
@onready var pos_tab_lower_back_button: Button = %LowerBackButton
@onready var pos_tab_lower_front_button: Button = %LowerFrontButton
@onready var bpow_boost_number_ui: NumberUI = %BPOWNumberUI
@onready var bdef_boost_number_ui: NumberUI = %BDEFNumberUI
@onready var spow_boost_number_ui: NumberUI = %SPOWNumberUI
@onready var sdef_boost_number_ui: NumberUI = %SDEFNumberUI
@onready var mpow_boost_number_ui: NumberUI = %MPOWNumberUI
@onready var mdef_boost_number_ui: NumberUI = %MDEFNumberUI
@onready var clear_boost_button: Button = %ClearBoostButton

@onready var sets_tab: TabBar = %_Sets_

@onready var feelings_tab: TabBar = %_Feelings_

@onready var invests_tab: TabBar = %_Invests_


func _ready() -> void:
	visibility_changed.connect(_load_from_beastie)

	stamina_slider.value_changed.connect(_on_stamina_slider_value_changed)
	custom_name_line_edit.text_changed.connect(_on_custom_name_line_edit_text_changed)
	custom_name_line_edit.text_submitted.connect(custom_name_line_edit.release_focus.unbind(1))
	custom_number_line_edit.text_submitted.connect(_on_custom_number_line_edit_text_changed)
	custom_number_line_edit.text_submitted.connect(custom_number_line_edit.release_focus.unbind(1))

	# On Field Tab
	pos_tab_upper_back_button.pressed.connect(_on_pos_button_pressed.bind(Beastie.Position.UPPER_BACK))
	pos_tab_upper_front_button.pressed.connect(_on_pos_button_pressed.bind(Beastie.Position.UPPER_FRONT))
	pos_tab_lower_back_button.pressed.connect(_on_pos_button_pressed.bind(Beastie.Position.LOWER_BACK))
	pos_tab_lower_front_button.pressed.connect(_on_pos_button_pressed.bind(Beastie.Position.LOWER_FRONT))
	bpow_boost_number_ui.value_updated.connect(_on_boost_changed.bind(Beastie.Stats.B_POW))
	bdef_boost_number_ui.value_updated.connect(_on_boost_changed.bind(Beastie.Stats.B_DEF))
	spow_boost_number_ui.value_updated.connect(_on_boost_changed.bind(Beastie.Stats.S_POW))
	sdef_boost_number_ui.value_updated.connect(_on_boost_changed.bind(Beastie.Stats.S_DEF))
	mpow_boost_number_ui.value_updated.connect(_on_boost_changed.bind(Beastie.Stats.M_POW))
	mdef_boost_number_ui.value_updated.connect(_on_boost_changed.bind(Beastie.Stats.M_DEF))
	clear_boost_button.pressed.connect(_reset_on_field_tab)


func _load_from_beastie() -> void:
	if not is_node_ready():
		await ready
	if not beastie:
		return

	custom_name_line_edit.text = beastie.my_name
	custom_number_line_edit.text = str(beastie.sport_number)
	_on_stamina_slider_value_changed(beastie.health)

	_load_on_field_tab()
	#_load_sets_tab()
	#_load_feelings_tab()
	#_load_invests_tab()


func _load_on_field_tab() -> void:
	bpow_boost_number_ui.num = beastie.get_boosts(Beastie.Stats.B_POW)
	bdef_boost_number_ui.num = beastie.get_boosts(Beastie.Stats.B_DEF)
	spow_boost_number_ui.num = beastie.get_boosts(Beastie.Stats.S_POW)
	sdef_boost_number_ui.num = beastie.get_boosts(Beastie.Stats.S_DEF)
	mpow_boost_number_ui.num = beastie.get_boosts(Beastie.Stats.M_POW)
	mdef_boost_number_ui.num = beastie.get_boosts(Beastie.Stats.M_DEF)


func reset() -> void:
	scroll_vertical = 0
	beastie = null
	side = Global.MySide.LEFT
	team_pos = TeamController.TeamPosition.FIELD_1

	_reset_on_field_tab()
	#_reset_sets_tab()
	#_reset_feelings_tab()
	#_reset_invests_tab()


func _reset_on_field_tab() -> void:
	bpow_boost_number_ui.reset()
	bdef_boost_number_ui.reset()
	spow_boost_number_ui.reset()
	sdef_boost_number_ui.reset()
	mpow_boost_number_ui.reset()
	mdef_boost_number_ui.reset()


func _update_beastie() -> void:
	if not is_node_ready():
		await ready
	if not beastie:
		name_label.text = "UNKNOWN"
		sprite_texture_rec.texture = null
		custom_name_line_edit.placeholder_text = "Name"
		custom_number_line_edit.placeholder_text = "999"
		_update_stamina_progress_bar_stylebox()
		tab_container.set_tab_hidden(0, false)
		return

	name_label.text = beastie.specie_name
	sprite_texture_rec.texture = beastie.get_sprite(Beastie.Sprite.ICON)
	custom_name_line_edit.placeholder_text = beastie.specie_name
	custom_number_line_edit.placeholder_text = str(beastie.beastiepedia_id)
	_update_stamina_progress_bar_stylebox()
	if team_pos in [TeamController.TeamPosition.BENCH_1, TeamController.TeamPosition.BENCH_2]:
		tab_container.set_tab_hidden(0, true) # Hide On Field tab if is benched


func _update_side() -> void:
	if not is_node_ready():
		await ready

	var new_index : int = 0 if side == Global.MySide.LEFT else 1
	pos_tab_upper_button_container.move_child(pos_tab_upper_back_button, new_index)
	pos_tab_lower_button_container.move_child(pos_tab_lower_back_button, new_index)


func _on_stamina_slider_value_changed(new_value : int) -> void:
	stamina_progress_bar.value = new_value
	stamina_label.text = str(new_value)
	beastie.health = new_value


func _update_stamina_progress_bar_stylebox() -> void:
	var new_stylebox : StyleBoxFlat = STAMINA_FILL_STYLEBOX.duplicate()
	new_stylebox.bg_color = Color.GREEN if not beastie else beastie.bar_color
	stamina_progress_bar.add_theme_stylebox_override("fill", new_stylebox)


func _on_custom_name_line_edit_text_changed(new_text : String) -> void:
	if not beastie:
		return
	beastie.my_name = new_text


func _on_custom_number_line_edit_text_changed(new_text : String) -> void:
	if not beastie:
		return
	beastie.sport_number = new_text.to_int()


func _on_pos_button_pressed(new_pos : Beastie.Position) -> void:
	# signal up to teamcontroller
	return


func _on_boost_changed(value : int, boost_type : Beastie.Stats) -> void:
	if not beastie:
		return
	if value == 0:
		beastie.current_boosts.erase(boost_type)
	else:
		beastie.current_boosts[boost_type] = value
	beastie.current_boosts_updated.emit(beastie.current_boosts) # Need to maunally emit it for some reason
