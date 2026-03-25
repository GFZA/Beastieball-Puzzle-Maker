class_name WarningRec
extends ColorRect

enum Warning {NONE, NO_BALL, TOO_MANY_BALL, BALL_WRONG_OFFENSE, BALL_WRONG_DEFENSE,
				BALL_WRONG_SERVE, BALL_WRONG_CSERVE, POS_WRONG_SERVE_TURNS, BALL_TYPE_WRONG_SERVE_TURNS}

var board : Board = null
var main_ui : MainUI = null : # This node is ready before MainUI so this kinda cheese that
	set(value):
		main_ui = value
		save_anyway_button.pressed.connect(func():
			hide()
			main_ui.start_saving_image()
		)
		go_back_button.pressed.connect(hide)
		main_ui.save_image_button_pressed.connect(_on_main_ui_save_image_button_pressed)

@onready var warning_name_lable: Label = %WarningNameLable
@onready var warning_desc_label: RichTextLabel = %WarningDescLabel
@onready var save_anyway_button: Button = %SaveAnywayButton
@onready var go_back_button: Button = %GoBackButton


func _on_main_ui_save_image_button_pressed() -> void:
	var warning : Warning = check_for_error()
	if warning != Warning.NONE:
		show_warning(warning)
	else:
		main_ui.start_saving_image()


func check_for_error() -> Warning :
	var all_beastie_scene : Array[Node] = get_tree().get_nodes_in_group("beastie_scene")
	all_beastie_scene = all_beastie_scene.filter(func(scene : BeastieScene):
		return not scene.benched
	)

	var ball_count : int = 0
	for scene : BeastieScene in all_beastie_scene:
		if scene.have_ball:
			ball_count += 1
	if ball_count == 0:
		return Warning.NO_BALL
	if ball_count > 1:
		return Warning.TOO_MANY_BALL

	match board.turn:
		Board.Turn.OFFENSE:
			for scene : BeastieScene in all_beastie_scene:
				if scene.have_ball and scene.my_side == Global.MySide.RIGHT:
					return Warning.BALL_WRONG_OFFENSE
		Board.Turn.DEFENSE:
			for scene : BeastieScene in all_beastie_scene:
				if scene.have_ball and scene.my_side == Global.MySide.LEFT:
					return Warning.BALL_WRONG_DEFENSE
		Board.Turn.SERVE, Board.Turn.CSERVE:
			var serving_side : Global.MySide = Global.MySide.LEFT if board.turn == Board.Turn.SERVE else Global.MySide.RIGHT
			for scene : BeastieScene in all_beastie_scene:
				var is_server : bool = (scene.my_side == serving_side and scene.beastie.my_field_position == Beastie.Position.UPPER_BACK)
				if scene.have_ball:
					if not is_server:
						return Warning.BALL_WRONG_SERVE
					elif not scene.ball_type == BeastieScene.BallType.EASY_RECEIVE:
						return Warning.BALL_TYPE_WRONG_SERVE_TURNS
				if scene.beastie.my_field_position in [Beastie.Position.UPPER_FRONT, Beastie.Position.LOWER_FRONT]:
					return Warning.POS_WRONG_SERVE_TURNS


	return Warning.NONE


func show_warning(warning : Warning) -> void:
	show()
	match warning:
		Warning.NONE:
			push_error("Warning shown when there isn't one!")
		Warning.NO_BALL:
			warning_name_lable.text = "No Ball On Field!"
			warning_desc_label.text = "None of the fielded beasties have the ball.\nHow would they play like this?"
		Warning.TOO_MANY_BALL:
			warning_name_lable.text = "Too Many Balls!"
			warning_desc_label.text = "More than one beasties have the ball.\nThey're having fun, sure, but that's not good for puzzle."
		Warning.BALL_WRONG_OFFENSE:
			warning_name_lable.text = "Ball On Wrong Team!"
			warning_desc_label.text = "It's Offense but the opponent have the ball.\nThat's cheating! Take back the ball!"
		Warning.BALL_WRONG_DEFENSE:
			warning_name_lable.text = "Ball On Wrong Team!"
			warning_desc_label.text = "It's Defense but your team have the ball.\nThat's cheating! Give them the ball!"
		Warning.BALL_WRONG_SERVE:
			warning_name_lable.text = "Ball On Wrong Beastie!"
			warning_desc_label.text = "You are serving but the ball is not on your server.\nThat's cheating! Let them serve!"
		Warning.BALL_WRONG_CSERVE:
			warning_name_lable.text = "Ball On Wrong Beastie!"
			warning_desc_label.text = "Opponent is serving but the ball is not on their server.\nThat's cheating! Let them serve!"
		Warning.POS_WRONG_SERVE_TURNS:
			warning_name_lable.text = "Wrong Position!"
			warning_desc_label.text = "It's Serve or CServe but there's beastie at net\nThat's cheating! Push them back!"
		Warning.BALL_TYPE_WRONG_SERVE_TURNS:
			warning_name_lable.text = "Ball Not Volleyed!"
			warning_desc_label.text = "The ball on the server is not volleyed.\nYou can't serve with that!"
