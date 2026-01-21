@tool
class_name TeamMenu
extends ScrollContainer

signal beastie_menu_requested(requested_beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition)
signal controller_reset_slot_requested(side : Global.MySide, team_pos : TeamController.TeamPosition)
#signal swap_slot_requested(team_pos_1 : TeamController.TeamPosition, team_pos_2 : TeamController.TeamPosition)

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

	#member_one_slot_ui.swap_up_requested.connect(_on_swap_up_requested)
	#member_two_slot_ui.swap_up_requested.connect(_on_swap_up_requested)
	#bench_one_ui.swap_up_requested.connect(_on_swap_up_requested)
	#bench_two_ui.swap_up_requested.connect(_on_swap_up_requested)
#
	#member_one_slot_ui.swap_down_requested.connect(_on_swap_down_requested)
	#member_two_slot_ui.swap_down_requested.connect(_on_swap_down_requested)
	#bench_one_ui.swap_down_requested.connect(_on_swap_down_requested)
	#bench_two_ui.swap_down_requested.connect(_on_swap_down_requested)

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


#region Scrapped Swap Funcs
#func _on_swap_up_requested(requester : AddBeastieUI) -> void:
	#var adjacent_uis : Array[AddBeastieUI] = _get_adjacent_add_beastie_ui(requester)
	#var upper_ui : AddBeastieUI = adjacent_uis.get(0)
	#if upper_ui:
		#var beastie_1 : Beastie = requester.my_beastie
		#var beastie_2 : Beastie = upper_ui.my_beastie
		#swap_slot_requested.emit(requester.team_pos, upper_ui.team_pos)
		#requester.reset()
		#requester.my_beastie = beastie_2 # Swap
		#requester.update_visual_when_beastie()
		#upper_ui.reset()
		#upper_ui.my_beastie = beastie_1 # Swap
		#upper_ui.update_visual_when_beastie()


#func _on_swap_down_requested(requester : AddBeastieUI) -> void:
	#var adjacent_uis : Array[AddBeastieUI] = _get_adjacent_add_beastie_ui(requester)
	#var lower_ui : AddBeastieUI = adjacent_uis.get(1)
	#if lower_ui:
		#var beastie_1 : Beastie = requester.my_beastie
		#var beastie_2 : Beastie = lower_ui.my_beastie
		#swap_slot_requested.emit(requester.team_pos, lower_ui.team_pos)
		#requester.reset()
		#requester.my_beastie = beastie_2 # Swap
		#requester.update_visual_when_beastie()
		#lower_ui.reset()
		#lower_ui.my_beastie = beastie_1 # Swap
		#lower_ui.update_visual_when_beastie()

#
#func _get_adjacent_add_beastie_ui(add_beastie_ui : AddBeastieUI) -> Array[AddBeastieUI]: # [Upper, Lower]
	#match add_beastie_ui:
		#member_one_slot_ui:
			#return [null, member_two_slot_ui]
		#member_two_slot_ui:
			#return [member_one_slot_ui, bench_one_ui]
		#bench_one_ui:
			#return [member_two_slot_ui, bench_two_ui]
		#bench_two_ui:
			#return [bench_one_ui, null]
	#return [] # Shouldn't happen
#endregion
