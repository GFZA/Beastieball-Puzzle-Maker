@tool
class_name PlaysUIContainer
extends Control

const TRAIT_PLACEHOLDER_DESC := "Trait : Like to ball"
const UPPER_OFFSET := -440.0
const LOWER_OFFSET := 105.0

@export var beastie : Beastie = null :
	set(value):
		if not is_node_ready():
			await ready

		if value == null:
			update_plays_ui(Beastie.get_empty_slot_plays_array())
			update_trait_label(null)
			boost_ui.beastie = null
			my_field_positon = Beastie.Position.NOT_ASSIGNED
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
		boost_ui.beastie = beastie
		my_field_positon = beastie.my_field_position

@export var my_side : Global.MySide = Global.MySide.LEFT :
	set(value):
		my_side = value
		_update_side()


var my_field_positon : Beastie.Position = Beastie.Position.NOT_ASSIGNED :
	set(value):
		my_field_positon = value
		var offset : float = 0.0
		match my_field_positon:
			Beastie.Position.UPPER_BACK, Beastie.Position.UPPER_FRONT:
				offset = UPPER_OFFSET
			Beastie.Position.LOWER_BACK, Beastie.Position.LOWER_FRONT:
				offset = LOWER_OFFSET
			_:
				offset = 0.0
		position.y = offset

@onready var main_upper_container: HBoxContainer = %MainUpperContainer
@onready var main_plays_container: VBoxContainer = %MainPlaysContainer
@onready var damage_side_container: VBoxContainer = %DamageSideContainer

@onready var plays_ui_one: PlaysUI = %PlaysUIOne
@onready var plays_ui_two: PlaysUI = %PlaysUITwo
@onready var plays_ui_three: PlaysUI = %PlaysUIThree
@onready var trait_label: RichTextLabel = %TraitLabel

@onready var boost_ui: BoostUI = %BoostUI


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


func _update_side() -> void:
	if not is_node_ready():
		await ready

	var new_index : int = 0 if my_side == Global.MySide.LEFT else 1
	main_upper_container.move_child(main_plays_container, new_index)
