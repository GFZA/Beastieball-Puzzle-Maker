@tool
class_name PlaysUIContainer
extends Control

const TRAIT_PLACEHOLDER_DESC := "Trait : Likes to ball"
const TRAIT_BG_NORMAL : PackedVector2Array = [
	Vector2(-59.0, 250.0),
	Vector2(-117.0, 0.0),
	Vector2(965.0, 0.0),
	Vector2(1023.0, 250.0)
]
const TRAIT_BG_EXTENDED : PackedVector2Array = [
	Vector2(-59.0, 250.0),
	Vector2(-117.0, 0.0),
	Vector2(965.0 + 361.0, 0.0),
	Vector2(1023.0 + 361.0, 250.0)
]


@export var beastie : Beastie = null :
	set(value):
		if not is_node_ready():
			await ready

		if value == null:
			update_plays_ui(Beastie.get_empty_slot_plays_array())
			update_trait_label(null)
			boost_ui.beastie = null
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

@export var my_side : Global.MySide = Global.MySide.LEFT :
	set(value):
		my_side = value
		_update_side()

@export var show_bench_damage : bool = false :
	set(value):
		show_bench_damage = value
		_update_show_bench_damage()


@onready var main_container: VBoxContainer = %MainContainer
@onready var main_upper_container: HBoxContainer = %MainUpperContainer
@onready var main_plays_container: VBoxContainer = %MainPlaysContainer
@onready var damage_side_container: VBoxContainer = %DamageSideContainer
@onready var cheese_spacer: Control = %CheeseSpacer

@onready var plays_ui_one: PlaysUI = %PlaysUIOne
@onready var plays_ui_two: PlaysUI = %PlaysUITwo
@onready var plays_ui_three: PlaysUI = %PlaysUIThree
@onready var trait_label: RichTextLabel = %TraitLabel
@onready var background_para: Parallelogram = %BackgroundPara

@onready var damage_indicator: DamageIndicator = %DamageIndicator
@onready var boost_ui: BoostUI = %BoostUI


func update_plays_ui(new_list : Array[Plays]) -> void:
	if not is_node_ready():
		await ready

	plays_ui_one.my_play = new_list[0]
	plays_ui_two.my_play = new_list[1]
	plays_ui_three.my_play = new_list[2]

	if new_list[0] and new_list[0].type in [Plays.Type.ATTACK_BODY, Plays.Type.ATTACK_SPIRIT, Plays.Type.ATTACK_MIND]:
		_show_damage_indicator()
		damage_indicator.attack = new_list[0]
		# damage_dict will be updated by BoardManager in the Board scene
	else:
		_hide_damage_indicator()
		damage_indicator.attack = null
		damage_indicator.damage_dict_array = []


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

	damage_indicator.my_side = my_side


func _update_show_bench_damage() -> void:
	if not is_node_ready():
		await ready

	damage_indicator.show_bench_damage = show_bench_damage
	background_para.polygon = TRAIT_BG_EXTENDED if show_bench_damage else TRAIT_BG_NORMAL
	self.custom_minimum_size.x = 1615.0 if show_bench_damage else 1250.0
	self.size = self.custom_minimum_size


func _show_damage_indicator() -> void:
	damage_side_container.show()
	cheese_spacer.show() # Need this to look good


func _hide_damage_indicator() -> void:
	damage_side_container.hide()
	cheese_spacer.hide() # Need this to look good
