@tool
class_name BoardOverlay
extends Control

signal overlay_edit_requested

const TURN_BARS : Dictionary[Board.Turn, Texture2D] = {
	Board.Turn.OFFENSE : preload("uid://caafonrcdyiwp"),
	Board.Turn.DEFENSE : preload("uid://0ldn2nscb15e"),
	Board.Turn.CSERVE : preload("uid://0ldn2nscb15e"), # same as defense
	Board.Turn.SERVE : preload("uid://dslneqx6ype82"),
}

const TURN_TEXT : Dictionary[Board.Turn, String] = {
	Board.Turn.OFFENSE : "Offense",
	Board.Turn.DEFENSE : "Defense",
	Board.Turn.CSERVE : "CounterServe",
	Board.Turn.SERVE : "Serve",
}

const OFFENSE_ACTION_TEXTURES : Dictionary[int, Texture2D] = {
	4 : preload("uid://dd07iat8y5gpe"),
	3 : preload("uid://dd07iat8y5gpe"),
	2 : preload("uid://disbdk34lqf5m"),
	1 : preload("uid://cylrwlyp3hghp"),
}
const DEFENSE_END_TURN_OVERLAY : Texture2D = preload("uid://cr65n1bm44s8v")

@export var turn : Board.Turn = Board.Turn.OFFENSE :
	set(value):
		turn = value
		_update_turn()

@export_range(1, 9) var max_score : int = 3 :
	set(value):
		max_score = value
		if not is_node_ready():
			await ready
		left_max_score_label.text = str(max_score)
		right_max_score_label.text = str(max_score)

@export_range(0, 9) var left_score : int = 0 :
	set(value):
		left_score = value
		if not is_node_ready():
			await ready
		left_score_label.text = str(left_score)

@export_range(0, 9) var right_score : int = 0 :
	set(value):
		right_score = value
		if not is_node_ready():
			await ready
		right_score_label.text = str(right_score)

@export_range(1, 3) var offense_action_amount : int = 3 :
	set(value):
		offense_action_amount = value
		_update_offense_action_amount()

@export_group("Logo & Texts")
@export var logo : Texture2D = null :
	set(value):
		logo = value
		if not is_node_ready():
			await ready

		logo_texture_rec.hide()
		if not logo:
			return
		logo_texture_rec.texture = logo
		logo_texture_rec.show()

@export_multiline var title_text : String = "Find the guaranteed win" :
	set(value):
		title_text = value
		if not is_node_ready():
			await ready
		title.text = title_text

@export_multiline var misc_text : String = "" :
	set(value):
		misc_text = value
		if not is_node_ready():
			await ready
		misc_label.text = misc_text


@onready var title: Label = %Title
@onready var turn_bar_bg: TextureRect = %TurnBarBG
@onready var turn_name_label: Label = %TurnNameLabel
@onready var left_score_label: Label = %LeftScoreLabel
@onready var left_max_score_label: Label = %LeftMaxScoreLabel
@onready var right_score_label: Label = %RightScoreLabel
@onready var right_max_score_label: Label = %RightMaxScoreLabel
@onready var misc_label: Label = %MiscLabel
@onready var logo_texture_rec: TextureRect = %LogoTextureRec
@onready var misc_turn_overlay: TextureRect = %MiscTurnOverlay

@onready var opponent_serve_label: Label = %OpponentServeLabel
@onready var overlay_edit_button: Button = %OverlayEditButton
@onready var edit_overlay_label: Label = %EditOverlayLabel

var hover_stylebox : StyleBox = preload("uid://dw1dvbm31ux8x")
var stylebox_empty := StyleBoxEmpty.new()


func _ready() -> void:
	overlay_edit_button.pressed.connect(_on_overlay_button_mouse_pressed.bind(overlay_edit_button))
	overlay_edit_button.mouse_entered.connect(_on_overlay_button_mouse_entered)
	overlay_edit_button.mouse_exited.connect(_on_overlay_button_mouse_exited)

	edit_overlay_label.hide()
	opponent_serve_label.hide()


func _update_turn() -> void:
	if not is_node_ready():
		await ready
	opponent_serve_label.hide()
	turn_bar_bg.texture = TURN_BARS.get(turn)
	turn_name_label.text = TURN_TEXT.get(turn)
	_update_misc_overlay()
	_update_opponent_serve_label()


func _update_misc_overlay() -> void:
	misc_turn_overlay.hide()
	match turn:
		Board.Turn.OFFENSE:
			_update_offense_action_amount()
			misc_turn_overlay.show()
		Board.Turn.DEFENSE, Board.Turn.CSERVE:
			misc_turn_overlay.texture = DEFENSE_END_TURN_OVERLAY
			misc_turn_overlay.show()
		# SERVE don't have this overlay so stay hidden


func _update_offense_action_amount() -> void:
	if not is_node_ready():
		await ready
	if not turn == Board.Turn.OFFENSE:
		return
	misc_turn_overlay.texture = OFFENSE_ACTION_TEXTURES.get(offense_action_amount)


func _update_opponent_serve_label() -> void:
	opponent_serve_label.hide()
	if turn == Board.Turn.CSERVE:
		opponent_serve_label.show()


func _on_overlay_button_mouse_pressed(button : Button) -> void:
	if button.has_focus():
		button.release_focus()
	overlay_edit_requested.emit()


func _on_overlay_button_mouse_entered() -> void:
	overlay_edit_button.add_theme_stylebox_override("normal", hover_stylebox)
	edit_overlay_label.show()


func _on_overlay_button_mouse_exited() -> void:
	overlay_edit_button.add_theme_stylebox_override("normal", stylebox_empty)
	edit_overlay_label.hide()


func on_max_point_changed(max_point : int) -> void:
	max_score = max_point


func on_your_point_changed(your_point : int) -> void:
	left_score = your_point


func on_opponent_point_change(opponent_point : int) -> void:
	right_score = opponent_point


func on_turn_changed(new_turn : Board.Turn) -> void:
	turn = new_turn


func on_offense_action_changed(action_lefts : int) -> void:
	offense_action_amount = action_lefts


func on_title_text_changed(new_text : String) -> void:
	title_text = new_text


func on_right_text_changed(new_text : String) -> void:
	misc_text = new_text


func on_logo_changed(new_logo : Texture2D) -> void:
	logo = new_logo
