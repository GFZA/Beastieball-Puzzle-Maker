@tool
class_name PlaysUIContainer
extends Control

const TRAIT_PLACEHOLDER_DESC := "Trait : Like to ball"

#@export_tool_button("test") var test := test_fuc
#func test_fuc() -> void:
	#print("WIPED,".trim_suffix(","))


@export var beastie : Beastie = null :
	set(value):
		if not is_node_ready():
			await ready

		if value == null:
			update_plays_ui(Beastie.get_empty_slot_plays_array())
			update_trait_label(null)
			if beastie:
				if beastie.my_plays_updated.is_connected(update_plays_ui):
					beastie.my_plays_updated.disconnect(update_plays_ui)
				if beastie.my_trait_updated.is_connected(update_trait_label):
					beastie.my_trait_updated.disconnect(update_trait_label)
			beastie = value
			return

		beastie = value # Must not duplicate so it's the same one from BeastieScene!
		beastie.my_plays_updated.connect(update_plays_ui)
		beastie.my_trait_updated.connect(update_trait_label)
		update_plays_ui(beastie.my_plays)
		update_trait_label(beastie.my_trait)

@onready var plays_ui_one: PlaysUI = %PlaysUIOne
@onready var plays_ui_two: PlaysUI = %PlaysUITwo
@onready var plays_ui_three: PlaysUI = %PlaysUIThree
@onready var trait_label: RichTextLabel = %TraitLabel


func update_plays_ui(new_list : Array[Plays]) -> void:
	if not is_node_ready():
		await ready
	plays_ui_one.my_play = new_list[0]
	plays_ui_two.my_play = new_list[1]
	plays_ui_three.my_play = new_list[2]


func update_trait_label(new_trait : Trait) -> void:
	if not is_node_ready():
		await ready
	var desc : String = new_trait.name + " : " + Global.get_iconified_text(new_trait.description, false) \
						if new_trait else TRAIT_PLACEHOLDER_DESC
	trait_label.text = desc
