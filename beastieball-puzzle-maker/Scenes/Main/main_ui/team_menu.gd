@tool
class_name TeamMenu
extends ScrollContainer


@export var side : Global.MySide = Global.MySide.LEFT:
	set(value):
		side = value
		_update_side()

@onready var main_container: VBoxContainer = %MainContainer
@onready var serve_slot_ui: AddBeastieUI = %ServeSlotUI
@onready var non_serve_slot_ui: AddBeastieUI = %NonServeSlotUI
@onready var bench_one_ui: AddBeastieUI = %BenchOneUI
@onready var bench_two_ui: AddBeastieUI = %BenchTwoUI


func _update_side() -> void:
	if not is_node_ready():
		await ready
	for ui : AddBeastieUI in main_container.get_children():
		ui.side = side
