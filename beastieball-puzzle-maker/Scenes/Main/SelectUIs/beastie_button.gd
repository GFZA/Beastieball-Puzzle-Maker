@tool
class_name BeastieButton
extends Button

const LENGTH_WHEN_NAME := 651.0
const LENGTH_WHEN_NO_NAME := 232.0


signal beastie_selected(selected_beastie : Beastie)

@export var beastie : Beastie = null :
	set(value):
		beastie = value
		_update_beastie()

@export var show_name : bool = true:
	set(value):
		show_name = value
		_update_show_name()


@onready var main_margin_container: MarginContainer = %MainMarginContainer
@onready var icon_rec: TextureRect = %IconRec
@onready var name_info_container: VBoxContainer = %NameInfoContainer
@onready var number_label: Label = %Numberlabel
@onready var name_label: Label = %NameLabel


func _ready() -> void:
	pressed.connect(beastie_selected.emit.bind(beastie.duplicate(true)))
	pressed.connect(print.bind("Selected %s" % beastie.specie_name))


func _update_beastie() -> void:
	if not is_node_ready():
		await ready
	if not beastie:
		icon_rec.texture = null
		number_label.text = "999"
		name_label.text = "UNKNOWN"
		return
	var new_icon : Texture2D = beastie.get_sprite(Beastie.Sprite.ICON)
	icon_rec.texture = new_icon if new_icon else null
	number_label.text = str(beastie.beastiepedia_id)
	name_label.text = beastie.specie_name


func _update_show_name() -> void:
	if not is_node_ready():
		await ready
	name_info_container.visible = show_name
	self.custom_minimum_size.x = LENGTH_WHEN_NAME if show_name else LENGTH_WHEN_NO_NAME
	self.size.x = self.custom_minimum_size.x
