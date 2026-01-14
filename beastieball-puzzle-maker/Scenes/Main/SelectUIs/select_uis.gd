class_name SelectUIs
extends MarginContainer

signal beastie_selected(beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition)

var board : Board = null # Set by Main on ready

@onready var beastie_select_ui: BeastieSelectUI = %BeastieSelectUI


func _ready() -> void:
	beastie_select_ui.beastie_selected.connect(_on_beastie_selected)
	reset_and_hide()


func _on_beastie_selected(beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	board.board_manager.add_beastie_to_scene(beastie, side, team_pos)
	beastie_selected.emit(beastie, side, team_pos)
	reset_and_hide()


func reset_and_hide() -> void:
	beastie_select_ui.reset()
	#play_select_ui.reset()
	#trait_select_ui.reset()
	beastie_select_ui.hide()
	#play_select_ui.hide()
	#trait_select_ui.hide()
	hide()


func hide_all_ui() -> void:
	beastie_select_ui.hide()
	#play_select_ui.hide()
	#trait_select_ui.hide()


func show_beastie_select_ui(side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	show()
	hide_all_ui()
	beastie_select_ui.side = side
	beastie_select_ui.team_pos = team_pos
	beastie_select_ui.show()
