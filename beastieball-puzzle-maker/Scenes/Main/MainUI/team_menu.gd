@tool
class_name TeamMenu
extends ScrollContainer

signal beastie_menu_requested(requested_beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition)
signal controller_reset_slot_requested(side : Global.MySide, team_pos : TeamController.TeamPosition)

@export var side : Global.MySide = Global.MySide.LEFT:
	set(value):
		side = value
		_update_side()

@onready var main_container: VBoxContainer = %MainContainer
@onready var member_one_slot_ui: AddBeastieUI = %MemberOneSlotUI
@onready var member_two_slot_ui: AddBeastieUI = %MemberTwoSlotUI
@onready var bench_one_ui: AddBeastieUI = %BenchOneUI
@onready var bench_two_ui: AddBeastieUI = %BenchTwoUI


func _ready() -> void:
	member_one_slot_ui.controller_reset_slot_requested.connect(controller_reset_slot_requested.emit)
	member_two_slot_ui.controller_reset_slot_requested.connect(controller_reset_slot_requested.emit)
	bench_one_ui.controller_reset_slot_requested.connect(controller_reset_slot_requested.emit)
	bench_two_ui.controller_reset_slot_requested.connect(controller_reset_slot_requested.emit)

	member_one_slot_ui.beastie_menu_requested.connect(beastie_menu_requested.emit)
	member_two_slot_ui.beastie_menu_requested.connect(beastie_menu_requested.emit)
	bench_one_ui.beastie_menu_requested.connect(beastie_menu_requested.emit)
	bench_two_ui.beastie_menu_requested.connect(beastie_menu_requested.emit)


func _update_side() -> void:
	if not is_node_ready():
		await ready
	for node in main_container.get_children():
		if node is AddBeastieUI:
			node.side = side


func reset() -> void:
	for add_beastie_ui in main_container.get_children():
		if add_beastie_ui is not AddBeastieUI:
			continue
		add_beastie_ui.reset()
	scroll_vertical = 0


func load_from_data(board_data : BoardData) -> void:
	var dict_to_load : Dictionary = board_data.left_team_dict if side == Global.MySide.LEFT else board_data.right_team_dict

	var loaded_beastie_1 : Beastie = dict_to_load.get("beastie_1_beastie")
	if loaded_beastie_1:
		member_one_slot_ui.on_beastie_selected(loaded_beastie_1, side, TeamController.TeamPosition.FIELD_1) # Cheessy but work

	var loaded_beastie_2 : Beastie = dict_to_load.get("beastie_2_beastie")
	if loaded_beastie_2:
		member_two_slot_ui.on_beastie_selected(loaded_beastie_2, side, TeamController.TeamPosition.FIELD_2) # Cheessy but work

	var loaded_bench_1 : Beastie = dict_to_load.get("bench_beastie_1_beastie")
	if loaded_bench_1:
		bench_one_ui.on_beastie_selected(loaded_bench_1, side, TeamController.TeamPosition.BENCH_1) # Cheessy but work

	var loaded_bench_2 : Beastie = dict_to_load.get("bench_beastie_2_beastie")
	if loaded_bench_2:
		bench_two_ui.on_beastie_selected(loaded_bench_2, side, TeamController.TeamPosition.BENCH_2) # Cheessy but work
