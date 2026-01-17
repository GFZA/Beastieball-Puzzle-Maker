@tool
class_name BeastieMenu
extends ScrollContainer

signal beastie_position_change_requested(side : Global.MySide, team_pos : TeamController.TeamPosition, new_pos : Beastie.Position)
signal beastie_ball_change_requested(side : Global.MySide, team_pos : TeamController.TeamPosition, \
									have_ball : bool, ball_type : BeastieScene.BallType)

const STAMINA_FILL_STYLEBOX := preload("uid://ci28vvsldarw1")
const MAX_INVESTS_TOTAL : int = 60
const MAX_INVESTS_PER_STATS : int = 60


@export var beastie : Beastie = null :
	set(value):
		beastie = value
		_update_beastie()

@export var side : Global.MySide = Global.MySide.LEFT :
	set(value):
		side = value
		_update_side()

var team_pos : TeamController.TeamPosition = TeamController.TeamPosition.FIELD_1
var invest_points_pool : int = MAX_INVESTS_TOTAL

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
@onready var invests_points_left_label: Label = %InvestsPointsLeftLabel
@onready var clear_invests_button: Button = %ClearInvestsButton


func _ready() -> void:
	stamina_line_edit.text_submitted.connect(_on_stamina_line_edit_text_summited)
	stamina_up_button.pressed.connect(_on_stamina_up_button_pressed)
	stamina_down_button.pressed.connect(_on_stamina_down_button_pressed)

	visibility_changed.connect(_load_from_beastie) # Load data when appears

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
	if not is_node_ready():
		await ready
	if not visible:
		return
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


func _load_sets_tab() -> void:
	return


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
	return


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
	invest_points_pool = MAX_INVESTS_TOTAL
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

# TODO? : Capping Invests
#func _can_add_invests(beastie : Beastie, add_value : int, invests_type : Beastie.Stats) -> bool:
	#var current_invests : int = beastie.get_total_invests_points()
	#if current_invests + add_value > MAX_INVESTS_TOTAL:
		#return false
	#if beastie.invests.get(invests_type) + add_value > MAX_INVESTS_PER_STATS:
		#return false
	#return true

#endregion
