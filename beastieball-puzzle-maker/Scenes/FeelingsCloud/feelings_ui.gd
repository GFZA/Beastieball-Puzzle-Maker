@tool
class_name FeelingsUI
extends Control


@export var feelings : Beastie.Feelings = Beastie.Feelings.WIPED :
	set(value):
		feelings = value
		_update_feelings_texture()


@export_range(1, 99) var stack : int = 1:
	set(value):
		stack = value
		_update_number_label()


@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label


func _update_feelings_texture() -> void:
	if not is_node_ready():
		await ready
	var icon : Texture2D = load(Global.get_icon_path_from_feelings(feelings))
	texture_rect.texture = icon


func _update_number_label() -> void:
	if not is_node_ready():
		await ready
	label.text = str(stack)
