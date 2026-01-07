class_name OverlayMenu
extends ScrollContainer

signal max_point_changed(max_point : int)
signal your_point_changed(your_point : int)
signal opponent_point_change(opponent_point : int)
signal turn_changed(turn : Board.Turn)
signal offense_action_changed(action_lefts : int)
signal defense_against_serve_changed(defense_against_serve : bool)
signal title_text_changed(new_text : String)
signal right_text_changed(new_text : String)
signal bottom_text_changed(new_text : String)
signal logo_changed(new_logo : Texture2D)

const DEFAULT_TITLE_TEXT := "Find the guaranteed win"
const DEFAULT_RIGHT_TEXT := ""
const DEFAULT_BOTTOM_TEXT := "Puzzle solution: after Outro"

@onready var max_point_number_ui: NumberUI = %MaxPointNumberUI
@onready var your_points_number_ui: NumberUI = %YourPointsNumberUI
@onready var opponent_points_number_ui: NumberUI = %OpponentPointsNumberUI
@onready var offense_button: Button = %OffenseButton
@onready var defense_button: Button = %DefenseButton
@onready var serve_button: Button = %ServeButton

@onready var offense_action_container: HBoxContainer = %OffenseActionContainer
@onready var action_lefts_number_ui: NumberUI = %ActionLeftsNumberUI
@onready var defense_against_serve_container: HBoxContainer = %DefenseAgainstServeContainer
@onready var defense_against_serve_check_box: CheckBox = %DefenseAgainstServeCheckBox

@onready var title_text_line_edit: LineEdit = %TitleTextLineEdit
@onready var right_text_line_edit: LineEdit = %RightTextLineEdit
@onready var bottom_text_line_edit: LineEdit = %BottomTextLineEdit
@onready var load_logo_button: Button = %LoadLogoButton


func _ready() -> void:
	max_point_number_ui.value_updated.connect(max_point_changed.emit)
	your_points_number_ui.value_updated.connect(your_point_changed.emit)
	opponent_points_number_ui.value_updated.connect(opponent_point_change.emit)
	offense_button.pressed.connect(_on_turn_changed.bind(Board.Turn.OFFENSE))
	defense_button.pressed.connect(_on_turn_changed.bind(Board.Turn.DEFENSE))
	serve_button.pressed.connect(_on_turn_changed.bind(Board.Turn.SERVE))

	action_lefts_number_ui.value_updated.connect(offense_action_changed.emit)
	defense_against_serve_check_box.toggled.connect(_on_defense_against_serve_toggled)

	title_text_line_edit.text_changed.connect(title_text_changed.emit)
	title_text_line_edit.text_submitted.connect(title_text_line_edit.release_focus.unbind(1))
	right_text_line_edit.text_changed.connect(right_text_changed.emit)
	right_text_line_edit.text_submitted.connect(right_text_line_edit.release_focus.unbind(1))
	bottom_text_line_edit.text_changed.connect(bottom_text_changed.emit)
	bottom_text_line_edit.text_submitted.connect(bottom_text_line_edit.release_focus.unbind(1))
	load_logo_button.pressed.connect(_on_load_logo_button_pressed)

	_press_offense()


func _press_offense() -> void:
	offense_action_container.show()
	defense_against_serve_container.hide()
	turn_changed.emit(Board.Turn.OFFENSE)


func reset() -> void:
	max_point_number_ui.reset()
	your_points_number_ui.reset()
	opponent_points_number_ui.reset()

	_press_offense()

	action_lefts_number_ui.reset()
	defense_against_serve_check_box.button_pressed = false
	defense_against_serve_changed.emit(false)  # It's connected to button pressed so we have to manually emit this

	title_text_line_edit.text = DEFAULT_TITLE_TEXT
	title_text_changed.emit(DEFAULT_TITLE_TEXT) # Have to manually emit or some reason...
	right_text_line_edit.text = DEFAULT_RIGHT_TEXT
	right_text_changed.emit(DEFAULT_RIGHT_TEXT) # Have to manually emit or some reason...
	bottom_text_line_edit.text = DEFAULT_BOTTOM_TEXT
	bottom_text_changed.emit(DEFAULT_BOTTOM_TEXT) # Have to manually emit or some reason...
	logo_changed.emit(null)  # It's connected to button pressed so we have to manually emit this


func _on_turn_changed(new_turn : Board.Turn) -> void:
	offense_action_container.hide()
	defense_against_serve_container.hide()
	match new_turn:
		Board.Turn.OFFENSE:
			offense_action_container.show()
		Board.Turn.DEFENSE:
			defense_against_serve_container.show()
	turn_changed.emit(new_turn)


func _on_defense_against_serve_toggled(toggled_on : bool) -> void:
	defense_against_serve_changed.emit(toggled_on)


func _on_load_logo_button_pressed() -> void:
	print("open files")
	logo_changed.emit(null)
	return
