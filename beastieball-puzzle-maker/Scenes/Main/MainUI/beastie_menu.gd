@tool
class_name BeastieMenu
extends ScrollContainer

signal beastie_position_change_requested(side : Global.MySide, team_pos : TeamController.TeamPosition, new_pos : Beastie.Position)
signal beastie_ball_change_requested(side : Global.MySide, team_pos : TeamController.TeamPosition, \
									have_ball : bool, ball_type : BeastieScene.BallType)
signal beastie_show_bench_damage_requested(side : Global.MySide, team_pos : TeamController.TeamPosition, show_bench_damage : bool)
signal plays_select_ui_requested(beastie : Beastie, slot_index : int, side : Global.MySide, team_pos : TeamController.TeamPosition)
signal trait_select_ui_requested(beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition)

const STAMINA_FILL_STYLEBOX := preload("uid://ci28vvsldarw1")
const ICON_WHISTLE := preload("uid://dnjn5ky0d157b")


@export var beastie : Beastie = null :
	set(value):
		beastie = value
		_update_beastie()

@export var side : Global.MySide = Global.MySide.LEFT :
	set(value):
		side = value
		_update_side()

var team_pos : TeamController.TeamPosition = TeamController.TeamPosition.FIELD_1
var board : Board = null # Really bad cheese. Assign by MainUI

@onready var name_label: Label = %NameLabel
@onready var sprite_texture_rec: TextureRect = %SpriteTextureRec

@onready var custom_name_line_edit: LineEdit = %CustomNameLineEdit
@onready var custom_number_line_edit: LineEdit = %CustomNumberLineEdit

@onready var stamina_line_edit: LineEdit = %StaminaLineEdit
@onready var stamina_up_button: Button = %StaminaUpButton
@onready var stamina_down_button: Button = %StaminaDownButton
@onready var stamina_slider: HSlider = %StaminaSlider
@onready var stamina_progress_bar: ProgressBar = %StaminaProgressBar

@onready var tab_container: TabContainer = %TabContainer

# On Field Tab
@onready var on_field_tab: TabBar = %"_On Field_"
@onready var pos_tab_upper_button_container: HBoxContainer = %UpperButtonContainer
@onready var pos_tab_upper_back_button: Button = %UpperBackButton
@onready var pos_tab_upper_front_button: Button = %UpperFrontButton
@onready var pos_tab_lower_button_container: HBoxContainer = %LowerButtonContainer
@onready var pos_tab_lower_back_button: Button = %LowerBackButton
@onready var pos_tab_lower_front_button: Button = %LowerFrontButton
@onready var no_ball_button: Button = %NoBallButton
@onready var body_ball_button: Button = %BodyBallButton
@onready var spirit_ball_button: Button = %SpiritBallButton
@onready var mind_ball_button: Button = %MindBallButton
@onready var ready_ball_button: Button = %ReadyBallButton
@onready var bpow_boost_number_ui: NumberUI = %BPOWNumberUI
@onready var bdef_boost_number_ui: NumberUI = %BDEFNumberUI
@onready var spow_boost_number_ui: NumberUI = %SPOWNumberUI
@onready var sdef_boost_number_ui: NumberUI = %SDEFNumberUI
@onready var mpow_boost_number_ui: NumberUI = %MPOWNumberUI
@onready var mdef_boost_number_ui: NumberUI = %MDEFNumberUI
@onready var clear_boost_button: Button = %ClearBoostButton

# Set Tab
@onready var sets_tab: TabBar = %_Sets_
@onready var play_slot_1_button: Button = %PlaySlot1Button
@onready var play_slot_2_button: Button = %PlaySlot2Button
@onready var play_slot_3_button: Button = %PlaySlot3Button
@onready var play_slot_1_plays_ui: PlaysUI = %PlaySlot1PlaysUI
@onready var play_slot_2_plays_ui: PlaysUI = %PlaySlot2PlaysUI
@onready var play_slot_3_plays_ui: PlaysUI = %PlaySlot3PlaysUI
@onready var slot_1_clear_button: Button = %Slot1ClearButton
@onready var slot_2_clear_button: Button = %Slot2ClearButton
@onready var slot_3_clear_button: Button = %Slot3ClearButton
@onready var clear_plays_button: Button = %ClearPlaysButton
@onready var play_slot_1_condition_container: HBoxContainer = %PlaySlot1ConditionContainer
@onready var play_slot_2_condition_container: HBoxContainer = %PlaySlot2ConditionContainer # Unused
@onready var play_slot_3_condition_container: HBoxContainer = %PlaySlot3ConditionContainer  # Unused
@onready var play_slot_1_condition_label: Label = %PlaySlot1ConditionLabel
@onready var play_slot_2_condition_label: Label = %PlaySlot2ConditionLabel # Unused
@onready var play_slot_3_condition_label: Label = %PlaySlot3ConditionLabel # Unused
@onready var play_slot_1_condition_check_box: CheckBox = %PlaySlot1ConditionCheckBox
@onready var play_slot_2_condition_check_box: CheckBox = %PlaySlot2ConditionCheckBox # Unused
@onready var play_slot_3_condition_check_box: CheckBox = %PlaySlot3ConditionCheckBox # Unused
@onready var show_bench_damage_container: HBoxContainer = %ShowBenchDamageContainer
@onready var show_bench_damage_check_box: CheckBox = %ShowBenchDamageCheckBox
@onready var trait_1_button: Button = %Trait1Button
@onready var trait_2_button: Button = %Trait2Button
@onready var custom_trait_button: Button = %CustomTraitButton
@onready var trait_condition_container: HBoxContainer = %TraitConditionContainer
@onready var trait_condition_label: Label = %TraitConditionLabel
@onready var trait_condition_check_box: CheckBox = %TraitConditionCheckBox

# Feelings Tab
@onready var feelings_tab: TabBar = %_Feelings_
@onready var wiped_number_ui: NumberUI = %WipedNumberUI
@onready var tired_number_ui: NumberUI = %TiredNumberUI
@onready var shook_number_ui: NumberUI = %ShookNumberUI
@onready var nervous_number_ui: NumberUI = %NervousNumberUI
@onready var jazzed_number_ui: NumberUI = %JazzedNumberUI
@onready var weepy_number_ui: NumberUI = %WeepyNumberUI
@onready var blocked_number_ui: NumberUI = %BlockedNumberUI
@onready var sweaty_number_ui: NumberUI = %SweatyNumberUI
@onready var tough_number_ui: NumberUI = %ToughNumberUI
@onready var tender_number_ui: NumberUI = %TenderNumberUI
@onready var noisy_number_ui: NumberUI = %NoisyNumberUI
@onready var angry_number_ui: NumberUI = %AngryNumberUI
@onready var stressed_number_ui: NumberUI = %StressedNumberUI
@onready var clear_feelings_button: Button = %ClearFeelingsButton

# Invests Tab
@onready var invests_tab: TabBar = %_Invests_
@onready var bpow_invests_number_ui: NumberUI = %BPOWInvestsNumberUI
@onready var bdef_invests_number_ui: NumberUI = %BDEFInvestsNumberUI
@onready var spow_invests_number_ui: NumberUI = %SPOWInvestsNumberUI
@onready var sdef_invests_number_ui: NumberUI = %SDEFInvestsNumberUI
@onready var mpow_invests_number_ui: NumberUI = %MPOWInvestsNumberUI
@onready var mdef_invests_number_ui: NumberUI = %MDEFInvestsNumberUI
@onready var clear_invests_button: Button = %ClearInvestsButton


func _ready() -> void:
	_load_from_beastie() # Load before connecting signal

	stamina_line_edit.text_submitted.connect(_on_stamina_line_edit_text_summited)
	stamina_up_button.pressed.connect(_on_stamina_up_button_pressed)
	stamina_down_button.pressed.connect(_on_stamina_down_button_pressed)

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

	no_ball_button.pressed.connect(_on_ball_button_pressed.bind(false, BeastieScene.BallType.EASY_RECEIVE))
	body_ball_button.pressed.connect(_on_ball_button_pressed.bind(true, BeastieScene.BallType.BODY))
	spirit_ball_button.pressed.connect(_on_ball_button_pressed.bind(true, BeastieScene.BallType.SPIRIT))
	mind_ball_button.pressed.connect(_on_ball_button_pressed.bind(true, BeastieScene.BallType.MIND))
	ready_ball_button.pressed.connect(_on_ball_button_pressed.bind(true, BeastieScene.BallType.EASY_RECEIVE))

	bpow_boost_number_ui.value_updated.connect(_on_boost_changed.bind(Beastie.Stats.B_POW))
	bdef_boost_number_ui.value_updated.connect(_on_boost_changed.bind(Beastie.Stats.B_DEF))
	spow_boost_number_ui.value_updated.connect(_on_boost_changed.bind(Beastie.Stats.S_POW))
	sdef_boost_number_ui.value_updated.connect(_on_boost_changed.bind(Beastie.Stats.S_DEF))
	mpow_boost_number_ui.value_updated.connect(_on_boost_changed.bind(Beastie.Stats.M_POW))
	mdef_boost_number_ui.value_updated.connect(_on_boost_changed.bind(Beastie.Stats.M_DEF))

	clear_boost_button.pressed.connect(_reset_on_field_tab) # Pos button doesn't need resetting so we can just use this

	# Set Tab
	play_slot_1_button.pressed.connect(plays_select_ui_requested.emit.bind(beastie, 0, side, team_pos))
	play_slot_2_button.pressed.connect(plays_select_ui_requested.emit.bind(beastie, 1, side, team_pos))
	play_slot_3_button.pressed.connect(plays_select_ui_requested.emit.bind(beastie, 2, side, team_pos))
	slot_1_clear_button.pressed.connect(_on_slot_clear_pressed.bind(0))
	slot_2_clear_button.pressed.connect(_on_slot_clear_pressed.bind(1))
	slot_3_clear_button.pressed.connect(_on_slot_clear_pressed.bind(2))
	clear_plays_button.pressed.connect(_reset_all_plays)
	play_slot_1_condition_check_box.toggled.connect(_on_play_checkbox_toggled.bind(0))
	play_slot_2_condition_check_box.toggled.connect(_on_play_checkbox_toggled.bind(1))
	play_slot_3_condition_check_box.toggled.connect(_on_play_checkbox_toggled.bind(2))
	show_bench_damage_check_box.toggled.connect(_on_show_bench_damage_checkbox_toggled)

	trait_1_button.pressed.connect(_on_trait_button_pressed.bind(0))
	trait_2_button.pressed.connect(_on_trait_button_pressed.bind(1))
	custom_trait_button.pressed.connect(trait_select_ui_requested.emit.bind(beastie, side, team_pos))
	trait_condition_check_box.toggled.connect(_on_trait_checkbox_toggled)

	# Feelings Tab
	wiped_number_ui.value_updated.connect(_on_feelings_changed.bind(Beastie.Feelings.WIPED))
	tired_number_ui.value_updated.connect(_on_feelings_changed.bind(Beastie.Feelings.TRIED))
	shook_number_ui.value_updated.connect(_on_feelings_changed.bind(Beastie.Feelings.SHOOK))
	nervous_number_ui.value_updated.connect(_on_feelings_changed.bind(Beastie.Feelings.NERVOUS))
	jazzed_number_ui.value_updated.connect(_on_feelings_changed.bind(Beastie.Feelings.JAZZED))
	weepy_number_ui.value_updated.connect(_on_feelings_changed.bind(Beastie.Feelings.WEEPY))
	blocked_number_ui.value_updated.connect(_on_feelings_changed.bind(Beastie.Feelings.BLOCKED))
	sweaty_number_ui.value_updated.connect(_on_feelings_changed.bind(Beastie.Feelings.SWEATY))
	tough_number_ui.value_updated.connect(_on_feelings_changed.bind(Beastie.Feelings.TOUGH))
	tender_number_ui.value_updated.connect(_on_feelings_changed.bind(Beastie.Feelings.TENDER))
	noisy_number_ui.value_updated.connect(_on_feelings_changed.bind(Beastie.Feelings.NOISY))
	angry_number_ui.value_updated.connect(_on_feelings_changed.bind(Beastie.Feelings.ANGRY))
	stressed_number_ui.value_updated.connect(_on_feelings_changed.bind(Beastie.Feelings.STRESSED))
	clear_feelings_button.pressed.connect(_reset_feelings_tab) # No others thing so just reset everything

	# Invests Tab
	bpow_invests_number_ui.value_updated.connect(_on_invests_changed.bind(Beastie.Stats.B_POW))
	bdef_invests_number_ui.value_updated.connect(_on_invests_changed.bind(Beastie.Stats.B_DEF))
	spow_invests_number_ui.value_updated.connect(_on_invests_changed.bind(Beastie.Stats.S_POW))
	sdef_invests_number_ui.value_updated.connect(_on_invests_changed.bind(Beastie.Stats.S_DEF))
	mpow_invests_number_ui.value_updated.connect(_on_invests_changed.bind(Beastie.Stats.M_POW))
	mdef_invests_number_ui.value_updated.connect(_on_invests_changed.bind(Beastie.Stats.M_DEF))
	clear_invests_button.pressed.connect(_reset_invests_tab) # No others thing so just reset everything


#region Load Funcs
func _load_from_beastie() -> void:
	if not beastie:
		return

	custom_name_line_edit.text = beastie.my_name
	custom_number_line_edit.text = str(beastie.sport_number) if beastie.sport_number != 0 else ""
	_on_stamina_slider_value_changed(beastie.health)

	_load_on_field_tab()
	_load_sets_tab()
	_load_feelings_tab()
	_load_invests_tab()


func _load_on_field_tab() -> void:
	bpow_boost_number_ui.num = beastie.get_boosts(Beastie.Stats.B_POW)
	bdef_boost_number_ui.num = beastie.get_boosts(Beastie.Stats.B_DEF)
	spow_boost_number_ui.num = beastie.get_boosts(Beastie.Stats.S_POW)
	sdef_boost_number_ui.num = beastie.get_boosts(Beastie.Stats.S_DEF)
	mpow_boost_number_ui.num = beastie.get_boosts(Beastie.Stats.M_POW)
	mdef_boost_number_ui.num = beastie.get_boosts(Beastie.Stats.M_DEF)
	play_slot_1_condition_container.hide()
	play_slot_2_condition_container.hide()
	play_slot_3_condition_container.hide()


func _load_sets_tab() -> void:
	for i in 3:
		if beastie.my_plays[i] != null:
			on_plays_selected(beastie.my_plays[i], i, side, team_pos) # side and team_pos is kinda cheesing lol

	show_bench_damage_container.visible = not beastie.is_really_at_bench
	var team_controller : TeamController = board.board_manager.left_team_controller if side == Global.MySide.LEFT else \
	 									board.board_manager.right_team_controller
	var plays_ui_container : PlaysUIContainer = team_controller.plays_ui_container_dict.get(beastie) # Cheesy access this shuld-be-private dict...
	if plays_ui_container:
		show_bench_damage_check_box.button_pressed = plays_ui_container.show_bench_damage

	trait_1_button.text = beastie.possible_traits[0].name
	if beastie.possible_traits.size() == 1: # Out of index
		trait_2_button.hide()
	else:
		trait_2_button.show()
		trait_2_button.text = beastie.possible_traits[1].name

	trait_condition_container.visible = beastie.my_trait.need_to_be_manually_activated
	trait_condition_check_box.button_pressed = beastie.my_trait.manually_activated


func _load_feelings_tab() -> void:
	wiped_number_ui.num = beastie.get_feeling_stack(Beastie.Feelings.WIPED)
	tired_number_ui.num = beastie.get_feeling_stack(Beastie.Feelings.TRIED)
	shook_number_ui.num = beastie.get_feeling_stack(Beastie.Feelings.SHOOK)
	nervous_number_ui.num = beastie.get_feeling_stack(Beastie.Feelings.NERVOUS)
	jazzed_number_ui.num = beastie.get_feeling_stack(Beastie.Feelings.JAZZED)
	weepy_number_ui.num = beastie.get_feeling_stack(Beastie.Feelings.WEEPY)
	blocked_number_ui.num = beastie.get_feeling_stack(Beastie.Feelings.BLOCKED)
	sweaty_number_ui.num = beastie.get_feeling_stack(Beastie.Feelings.SWEATY)
	tough_number_ui.num = beastie.get_feeling_stack(Beastie.Feelings.TOUGH)
	tender_number_ui.num = beastie.get_feeling_stack(Beastie.Feelings.TENDER)
	noisy_number_ui.num = beastie.get_feeling_stack(Beastie.Feelings.NOISY)
	angry_number_ui.num = beastie.get_feeling_stack(Beastie.Feelings.ANGRY)
	stressed_number_ui.num = beastie.get_feeling_stack(Beastie.Feelings.STRESSED)


func _load_invests_tab() -> void:
	bpow_invests_number_ui.num = beastie.invests.get(Beastie.Stats.B_POW)
	bdef_invests_number_ui.num = beastie.invests.get(Beastie.Stats.B_DEF)
	spow_invests_number_ui.num = beastie.invests.get(Beastie.Stats.S_POW)
	sdef_invests_number_ui.num = beastie.invests.get(Beastie.Stats.S_DEF)
	mpow_invests_number_ui.num = beastie.invests.get(Beastie.Stats.M_POW)
	mdef_invests_number_ui.num = beastie.invests.get(Beastie.Stats.M_DEF)
#endregion

#region Reset Funcs
func reset() -> void:
	scroll_vertical = 0
	beastie = null
	side = Global.MySide.LEFT
	team_pos = TeamController.TeamPosition.FIELD_1

	_reset_on_field_tab()
	_reset_sets_tab()
	_reset_feelings_tab()
	_reset_invests_tab()


func _reset_on_field_tab() -> void:
	bpow_boost_number_ui.reset()
	bdef_boost_number_ui.reset()
	spow_boost_number_ui.reset()
	sdef_boost_number_ui.reset()
	mpow_boost_number_ui.reset()
	mdef_boost_number_ui.reset()


func _reset_sets_tab() -> void:
	_reset_all_plays()
	_reset_trait()


func _reset_all_plays() -> void:
	for i in 3:
		_on_slot_clear_pressed(i)
	play_slot_1_condition_check_box.button_pressed = false
	play_slot_2_condition_check_box.button_pressed = false
	play_slot_3_condition_check_box.button_pressed = false
	show_bench_damage_check_box.button_pressed = false


func _reset_trait() -> void:
	trait_condition_container.hide()
	trait_condition_check_box.button_pressed = false


func _reset_feelings_tab() -> void:
	wiped_number_ui.reset()
	tired_number_ui.reset()
	shook_number_ui.reset()
	nervous_number_ui.reset()
	jazzed_number_ui.reset()
	weepy_number_ui.reset()
	blocked_number_ui.reset()
	sweaty_number_ui.reset()
	tough_number_ui.reset()
	tender_number_ui.reset()
	noisy_number_ui.reset()
	angry_number_ui.reset()
	stressed_number_ui.reset()


func _reset_invests_tab() -> void:
	bpow_invests_number_ui.reset()
	bdef_invests_number_ui.reset()
	spow_invests_number_ui.reset()
	sdef_invests_number_ui.reset()
	mpow_invests_number_ui.reset()
	mdef_invests_number_ui.reset()
#endregion


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
	sprite_texture_rec.flip_h = not bool(new_index) # Flip if Left


#region Outside Tab Funcs
func _on_stamina_line_edit_text_summited(new_text : String) -> void:
	var new_stamina : int = new_text.to_int() if new_text.length() != 0 else 100
	_update_stamina(new_stamina)
	stamina_line_edit.release_focus()


func _on_stamina_up_button_pressed() -> void:
	var new_stamina : int = min(100, beastie.health + 1)
	_update_stamina(new_stamina)


func _on_stamina_down_button_pressed() -> void:
	var new_stamina : int = max(0, beastie.health - 1)
	_update_stamina(new_stamina)


func _on_stamina_slider_value_changed(new_value : int) -> void:
	_update_stamina(new_value)


func _update_stamina(new_stamina : int) -> void:
	stamina_line_edit.text = str(new_stamina)
	stamina_progress_bar.value = new_stamina
	beastie.health = new_stamina


func _update_stamina_progress_bar_stylebox() -> void:
	var new_stylebox : StyleBoxFlat = STAMINA_FILL_STYLEBOX.duplicate()
	var new_color : Color = Color.GREEN if not beastie else beastie.bar_color
	new_stylebox.bg_color = new_color
	stamina_progress_bar.add_theme_stylebox_override("fill", new_stylebox)


func _on_custom_name_line_edit_text_changed(new_text : String) -> void:
	if not beastie:
		return
	beastie.my_name = new_text


func _on_custom_number_line_edit_text_changed(new_text : String) -> void:
	if not beastie:
		return
	beastie.sport_number = new_text.to_int()
#endregion

#region On Field Tab Funcs
func _on_pos_button_pressed(new_pos : Beastie.Position) -> void:
	beastie_position_change_requested.emit(side, team_pos, new_pos)


func _on_ball_button_pressed(have_ball : bool, ball_type : BeastieScene.BallType) -> void:
	beastie_ball_change_requested.emit(side, team_pos, have_ball, ball_type)


func _on_boost_changed(value : int, boost_type : Beastie.Stats) -> void:
	if not beastie:
		return
	if value == 0:
		beastie.current_boosts.erase(boost_type)
	else:
		beastie.current_boosts[boost_type] = value
	beastie.current_boosts_updated.emit(beastie.current_boosts) # Need to maunally emit it for some reason
#endregion

#region Sets Tab
func _on_slot_clear_pressed(slot_index : int) -> void:
	if not beastie:
		return
	beastie.my_plays[slot_index] = null
	beastie.my_plays_updated.emit(beastie.my_plays) # Need to manually emit for some reason
	var button : Button = _get_button_from_slot_index(slot_index)
	var plays_ui : PlaysUI = _get_plays_ui_from_slot_index(slot_index)
	button.text = "Add Play %s" % str(slot_index + 1)
	button.icon = ICON_WHISTLE
	button.flat = false
	var plays : Plays = plays_ui.my_play
	if plays is Attack and plays.need_to_be_manually_activated and slot_index == 0: # Only for first slot
		_get_condition_container_from_slot_index(slot_index).hide()
		_get_condition_label_from_slot_index(slot_index).text = ""
		_get_condition_checkbox_from_slot_index(slot_index).button_pressed = false
	plays_ui.my_play = null
	plays_ui.hide()


func on_plays_selected(plays : Plays, slot_index : int, side_that_changed : Global.MySide, team_pos_that_changed : TeamController.TeamPosition) -> void: # Called by SelectUI
	if not (side_that_changed == side and team_pos_that_changed == team_pos):
		return
	var button : Button = _get_button_from_slot_index(slot_index)
	var plays_ui : PlaysUI = _get_plays_ui_from_slot_index(slot_index)
	button.text = ""
	button.icon = null
	button.flat = true
	if plays is Attack and plays.need_to_be_manually_activated and slot_index == 0: # Only for first slot
		_get_condition_container_from_slot_index(slot_index).show()
		_get_condition_label_from_slot_index(slot_index).text = plays.manual_condition_name
		_get_condition_checkbox_from_slot_index(slot_index).button_pressed = plays.manually_activated
	plays_ui.my_play = plays
	plays_ui.show()


func _get_button_from_slot_index(slot_index : int) -> Button:
	match slot_index:
		0:
			return play_slot_1_button
		1:
			return play_slot_2_button
		2:
			return play_slot_3_button
	return null


func _get_plays_ui_from_slot_index(slot_index : int) -> PlaysUI:
	match slot_index:
		0:
			return play_slot_1_plays_ui
		1:
			return play_slot_2_plays_ui
		2:
			return play_slot_3_plays_ui
	return null


func _get_condition_container_from_slot_index(slot_index : int) -> HBoxContainer:
	match slot_index:
		0:
			return play_slot_1_condition_container
		1:
			return play_slot_2_condition_container # Unused
		2:
			return play_slot_3_condition_container # Unused
	return null


func _get_condition_label_from_slot_index(slot_index : int) -> Label:
	match slot_index:
		0:
			return play_slot_1_condition_label
		1:
			return play_slot_2_condition_label # Unused
		2:
			return play_slot_3_condition_label # Unused
	return null


func _get_condition_checkbox_from_slot_index(slot_index : int) -> CheckBox:
	match slot_index:
		0:
			return play_slot_1_condition_check_box
		1:
			return play_slot_2_condition_check_box # Unused
		2:
			return play_slot_3_condition_check_box # Unused
	return null


func _on_play_checkbox_toggled(toggled_on : bool, slot_index : int) -> void:
	if not beastie:
		return
	var plays: Plays = _get_plays_ui_from_slot_index(slot_index).my_play
	assert(plays is Attack, "Non-attack tried to manually activate its non-existing condition!")
	plays.manually_activated = toggled_on
	beastie.my_plays_updated.emit(beastie.my_plays) # Manually updated


func _on_show_bench_damage_checkbox_toggled(toggled_on : bool) -> void:
	beastie_show_bench_damage_requested.emit(side, team_pos, toggled_on)


func _on_trait_button_pressed(trait_index : int) -> void:
	if not beastie:
		return
	if beastie.possible_traits.size() == 1 and trait_index == 1: # Out of index
		return
	beastie.my_trait = beastie.possible_traits[trait_index]
	beastie.my_trait_updated.emit(beastie.my_trait)
	trait_condition_container.visible = beastie.my_trait.need_to_be_manually_activated
	trait_condition_label.text = beastie.my_trait.manual_condition_name
	trait_condition_check_box.button_pressed = beastie.my_trait.manually_activated


func on_trait_selected(new_trait : Trait, side_that_changed : Global.MySide, team_pos_that_changed : TeamController.TeamPosition) -> void: # Called by SelectUI
	if not (side_that_changed == side and team_pos_that_changed == team_pos):
		return
	if new_trait.need_to_be_manually_activated:
		trait_condition_container.show()
		trait_condition_label.text = new_trait.manual_condition_name
		trait_condition_check_box.button_pressed = new_trait.manually_activated


func _on_trait_checkbox_toggled(toggled_on : bool) -> void:
	if not beastie:
		return
	var my_trait : Trait = beastie.my_trait
	my_trait.manually_activated = toggled_on
	beastie.my_trait_updated.emit(beastie.my_trait) # Manually updated
#endregion

#region Feelings Tab Funcs
func _on_feelings_changed(value : int, feelings : Beastie.Feelings) -> void:
	if not beastie:
		return
	if value == 0:
		beastie.current_feelings.erase(feelings)
	else:
		beastie.current_feelings[feelings] = value
	beastie.current_feelings_updated.emit(beastie.current_feelings) # Need to maunally emit it for some reason
#endregion

#region Invests Tab Funcs
func _on_invests_changed(value : int, invests_type : Beastie.Stats) -> void:
	if not beastie:
		return
	beastie.invests[invests_type] = value
	beastie.invests_updated.emit(beastie.invests) # Need to maunally emit it for some reason
#endregion
