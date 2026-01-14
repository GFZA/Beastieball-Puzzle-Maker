class_name BoardAddBeastieButton
extends Button

signal beastie_select_ui_requested(side : Global.MySide, team_pos : TeamController.TeamPosition)

@export var side : Global.MySide = Global.MySide.LEFT
@export var team_pos : TeamController.TeamPosition = TeamController.TeamPosition.FIELD_1


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	beastie_select_ui_requested.emit(side, team_pos)


func on_beastie_selected(beastie : Beastie, selected_side : Global.MySide, selected_team_pos : TeamController.TeamPosition) -> void:
	if selected_side != side or selected_team_pos != team_pos:
		return
	visible = (beastie == null)
