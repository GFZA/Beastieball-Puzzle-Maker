@tool
class_name PlaysUIContainer
extends Control


@export var beastie : Beastie = null :
	set(value):
		if not is_node_ready():
			await ready

		if value == null:
			update_plays_ui(Beastie.get_empty_slot_plays_array())
			if beastie:
				if beastie.my_plays_updated.is_connected(update_plays_ui):
					beastie.my_plays_updated.disconnect(update_plays_ui)
			beastie = value
			return

		beastie = value # Must not duplicate so it's the same one from BeastieScene!
		beastie.my_plays_updated.connect(update_plays_ui)
		update_plays_ui(beastie.my_plays)


@onready var plays_ui_one: PlaysUI = %PlaysUIOne
@onready var plays_ui_two: PlaysUI = %PlaysUITwo
@onready var plays_ui_three: PlaysUI = %PlaysUIThree


func update_plays_ui(new_list : Array[Plays]) -> void:
	if not is_node_ready():
		await ready
	plays_ui_one.my_play = new_list[0]
	plays_ui_two.my_play = new_list[1]
	plays_ui_three.my_play = new_list[2]
