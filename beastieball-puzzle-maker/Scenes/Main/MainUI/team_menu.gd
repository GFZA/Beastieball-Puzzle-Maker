@tool
class_name TeamMenu
extends ScrollContainer

signal beastie_menu_requested(requested_beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition)


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
