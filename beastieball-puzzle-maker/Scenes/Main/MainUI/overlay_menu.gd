@tool
class_name OverlayMenu
extends ScrollContainer

signal max_point_changed(max_point : int)
signal your_point_changed(your_point : int)
signal opponent_point_changed(opponent_point : int)
signal turn_changed(turn : Board.Turn)
signal offense_action_changed(action_lefts : int)
signal title_text_changed(new_text : String)
signal right_text_changed(new_text : String)
signal logo_changed(new_logo : Texture2D)

const DEFAULT_TITLE_TEXT := "Find the guaranteed win"
const DEFAULT_RIGHT_TEXT := ""

@onready var max_point_number_ui: NumberUI = %MaxPointNumberUI
@onready var your_points_number_ui: NumberUI = %YourPointsNumberUI
@onready var opponent_points_number_ui: NumberUI = %OpponentPointsNumberUI
@onready var offense_button: Button = %OffenseButton
@onready var serve_button: Button = %ServeButton
@onready var defense_button: Button = %DefenseButton
@onready var c_serve_button: Button = %CServeButton

@onready var offense_action_container: HBoxContainer = %OffenseActionContainer
@onready var action_lefts_number_ui: NumberUI = %ActionLeftsNumberUI

@onready var title_text_line_edit: LineEdit = %TitleTextLineEdit
@onready var right_text_line_edit: LineEdit = %RightTextLineEdit
@onready var load_logo_button: Button = %LoadLogoButton


func _ready() -> void:
	max_point_number_ui.value_updated.connect(max_point_changed.emit)
	your_points_number_ui.value_updated.connect(your_point_changed.emit)
	opponent_points_number_ui.value_updated.connect(opponent_point_changed.emit)
	offense_button.pressed.connect(_on_turn_changed.bind(Board.Turn.OFFENSE))
	serve_button.pressed.connect(_on_turn_changed.bind(Board.Turn.SERVE))
	defense_button.pressed.connect(_on_turn_changed.bind(Board.Turn.DEFENSE))
	c_serve_button.pressed.connect(_on_turn_changed.bind(Board.Turn.CSERVE))

	action_lefts_number_ui.value_updated.connect(offense_action_changed.emit)

	title_text_line_edit.text_changed.connect(title_text_changed.emit)
	title_text_line_edit.text_submitted.connect(title_text_line_edit.release_focus.unbind(1))
	right_text_line_edit.text_changed.connect(right_text_changed.emit)
	right_text_line_edit.text_submitted.connect(right_text_line_edit.release_focus.unbind(1))
	load_logo_button.pressed.connect(_on_load_logo_button_pressed)

	_press_offense()


func _press_offense() -> void:
	offense_action_container.show()
	turn_changed.emit(Board.Turn.OFFENSE)


func reset() -> void:
	max_point_number_ui.reset()
	your_points_number_ui.reset()
	opponent_points_number_ui.reset()

	_press_offense()

	action_lefts_number_ui.reset()

	title_text_line_edit.text = DEFAULT_TITLE_TEXT
	title_text_changed.emit(DEFAULT_TITLE_TEXT) # Have to manually emit or some reason...
	right_text_line_edit.text = DEFAULT_RIGHT_TEXT
	right_text_changed.emit(DEFAULT_RIGHT_TEXT) # Have to manually emit or some reason...
	logo_changed.emit(null)  # It's connected to button pressed so we have to manually emit this

	scroll_vertical = 0


func _on_turn_changed(new_turn : Board.Turn) -> void:
	offense_action_container.hide()
	if new_turn == Board.Turn.OFFENSE:
		offense_action_container.show()
	turn_changed.emit(new_turn)


func _on_load_logo_button_pressed() -> void:
	print("open files")
	logo_changed.emit(null)
	return
