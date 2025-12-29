@tool
class_name BeastieScene
extends Node2D

signal stamina_updated(stamina : int)
signal side_updated(my_side : Global.MySide)

const PLACEHOLDER_TEXTURE : Texture2D = preload("uid://chctbds4hrdsq")
const HEALTHBAR_SCENE : PackedScene = preload("uid://bvd7pbsfc56o0")
const PLAYS_UI_CONTAINER_SCENE : PackedScene = preload("uid://dksxc3rs20kkc")

@export var beastie : Beastie = null :
	set(value):
		if not is_node_ready():
			await ready

		sprite_2d.offset.y = 0.0

		if my_healthbar:
			stamina_updated.disconnect(my_healthbar.update_lifebar)
			my_healthbar.queue_free()
			my_healthbar = null

		if my_plays_ui_container:
			my_plays_ui_container.queue_free()
			my_plays_ui_container = null

		if value == null:
			current_sprite = PLACEHOLDER_TEXTURE
			beastie = value
			return

		beastie = value # Not duplicate so it's the same as TeamContoller's one
		current_sprite = beastie.get_sprite(Beastie.Sprite.IDLE)

		if not my_healthbar:
			var new_healthbar : Healthbar = HEALTHBAR_SCENE.instantiate()
			new_healthbar.beastie = beastie
			side_updated.connect(new_healthbar.update_side)
			new_healthbar.my_side = my_side
			add_child(new_healthbar)
			my_healthbar = new_healthbar

		if not my_plays_ui_container:
			var new_container : PlaysUIContainer = PLAYS_UI_CONTAINER_SCENE.instantiate()
			new_container.beastie = beastie
			new_container.my_side = my_side
			add_child(new_container)
			my_plays_ui_container = new_container

		current_sprite = beastie.get_sprite(sprite_pose)
		sprite_2d.offset.y = beastie.y_offset

@export_range(0, 100) var stamina : int = 100 :
	set(value):
		clamp(value, 0, 100)
		stamina = value
		stamina_updated.emit(stamina)

@export var my_side : Global.MySide = Global.MySide.LEFT :
	set(value):
		my_side = value
		_update_side(my_side)

@export var sprite_pose : Beastie.Sprite = Beastie.Sprite.IDLE :
	set(value):
		if not is_node_ready():
			await ready
		if not beastie:
			sprite_pose = Beastie.Sprite.IDLE
			return
		sprite_pose = value
		current_sprite = beastie.get_sprite(sprite_pose)

@export var show_plays : bool = true :
	set(value):
		if not is_node_ready():
			await ready
		show_plays = value
		if my_plays_ui_container:
			my_plays_ui_container.visible = show_plays

var current_sprite : Texture2D = null :
	set(value):
		current_sprite = value
		sprite_2d.texture = current_sprite

var my_healthbar : Healthbar = null
var my_plays_ui_container : PlaysUIContainer = null

@onready var sprite_2d: Sprite2D = %Sprite2D


func _update_side(new_side : Global.MySide) -> void:
	if not is_node_ready():
		await ready
	sprite_2d.flip_h = (new_side == Global.MySide.LEFT)
	side_updated.emit(my_side)
