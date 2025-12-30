@tool
class_name FeelingsCloud
extends Control

const FEELINGS_UI_SCENE = preload("uid://csnhyno0i0fh5")

@export var my_side : Global.MySide = Global.MySide.RIGHT :
	set(value):
		my_side = value
		if not is_node_ready():
			await ready
		cloud_texture_rec.flip_h = my_side == Global.MySide.LEFT

@export var beastie : Beastie = null :
	set(value):
		if not value:
			if beastie.current_feelings_updated.is_connected(_update_feelings_ui):
				beastie.current_feelings_updated.disconnect(_update_feelings_ui)
			_update_feelings_ui({})
			beastie = value
			return

		beastie = value
		if not beastie.current_feelings_updated.is_connected(_update_feelings_ui):
			beastie.current_feelings_updated.connect(_update_feelings_ui)
		_update_feelings_ui(beastie.current_feelings)

@onready var cloud_texture_rec: TextureRect = %CloudTextureRec
@onready var feelings_ui_container: HBoxContainer = %FeelingsUIContainer


func _update_feelings_ui(new_feelings_dict : Dictionary[Beastie.Feelings, int]) -> void:
	if not is_node_ready():
		await ready

	for child in feelings_ui_container.get_children():
		child.queue_free()

	if not new_feelings_dict or new_feelings_dict.is_empty():
		hide()
		return

	for feelings : Beastie.Feelings in new_feelings_dict:
		var new_scene : FeelingsUI = FEELINGS_UI_SCENE.instantiate()
		new_scene.feelings = feelings
		new_scene.stack = new_feelings_dict[feelings]
		feelings_ui_container.add_child(new_scene)

	show()
