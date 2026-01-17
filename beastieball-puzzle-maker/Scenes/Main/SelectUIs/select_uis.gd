class_name SelectUIs
extends MarginContainer

signal beastie_selected(beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition)

var board : Board = null # Set by Main on ready

@onready var beastie_select_ui: BeastieSelectUI = %BeastieSelectUI
@onready var plays_select_ui: PlaysSelectUI = %PlaysSelectUI


func _ready() -> void:
	beastie_select_ui.beastie_selected.connect(_on_beastie_selected)
	plays_select_ui.plays_selected.connect(_on_plays_selected.unbind(1))
	reset_and_hide()


func _on_beastie_selected(beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	board.board_manager.add_beastie_to_scene(beastie, side, team_pos)
	beastie_selected.emit(beastie, side, team_pos)
	reset_and_hide()


func _on_plays_selected() -> void:
	# No need for signal as the UI can change beastie's play by itself
	reset_and_hide()


func reset_and_hide() -> void:
	beastie_select_ui.hide()
	plays_select_ui.hide()
	beastie_select_ui.reset()
	plays_select_ui.reset()
	#trait_select_ui.reset()
	#trait_select_ui.hide()
	hide()


func hide_all_ui() -> void:
	beastie_select_ui.hide()
	plays_select_ui.hide()
	#trait_select_ui.hide()


func show_beastie_select_ui(side : Global.MySide, team_pos : TeamController.TeamPosition) -> void:
	show()
	hide_all_ui()
	beastie_select_ui.show()
	beastie_select_ui.side = side
	beastie_select_ui.team_pos = team_pos
	beastie_select_ui.update_grid()


func show_plays_select_ui(beastie : Beastie, slot_index : int) -> void:
	show()
	hide_all_ui()
	plays_select_ui.show()
	plays_select_ui.beastie = beastie
	plays_select_ui.slot_index = slot_index
