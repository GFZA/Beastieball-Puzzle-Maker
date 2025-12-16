@tool
class_name BeastieScene
extends Node2D

const PLACEHOLDER_TEXTURE : Texture2D = preload("uid://chctbds4hrdsq")

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var name_label: Label = %NameLabel
@onready var trait_label: Label = %TraitLabel
@onready var play_label: Label = %PlayLabel

var my_name : String = "Beastie" :
	set(value):
		my_name = value
		name_label.text = my_name

var current_sprite : Texture2D = null :
	set(value):
		current_sprite = value
		sprite_2d.texture = current_sprite

var all_my_plays : Array[Plays] = [] :
	set(value):
		all_my_plays = value
		if all_my_plays.is_empty():
			play_label.text = "MISSING PLAYS!"
			return
		var new_text = ""
		for play : Plays in all_my_plays:
			new_text += play.name
			if all_my_plays.find(play) == all_my_plays.size() - 1:
				new_text += "."
			else:
				new_text += ", "
		play_label.text = new_text

var all_my_trait: Array[Trait] = [] :
	set(value):
		all_my_trait = value
		if all_my_trait.is_empty():
			trait_label.text = "MISSING TRAITS!"
			return
		var new_text = ""
		for my_trait : Trait in all_my_trait:
			new_text += my_trait.name
			if all_my_trait.find(my_trait) == all_my_trait.size() - 1:
				new_text += "."
			else:
				new_text += ", "
		trait_label.text = new_text


@export var beastie : Beastie = null :
	set(value):
		if not is_node_ready():
			await ready
		beastie = value
		my_name = beastie.name if beastie else "THE UNKNOWN"
		current_sprite = beastie.get_sprite(Beastie.Sprite.IDLE) if beastie else PLACEHOLDER_TEXTURE
		all_my_plays = beastie.possible_plays if beastie else Beastie.get_empty_plays_array()
		all_my_trait = beastie.possible_traits if beastie else Beastie.get_empty_trait_array()
