@tool
class_name Board
extends Node2D

#region Test and screnshot stuffs

##TEMPORARY TESTING
#@export var my_attacker : Beastie = null :
	#set(value):
		#if value:
			#value = value.duplicate()
		#my_attacker = value
#
#@export var my_defender : Beastie = null :
	#set(value):
		#if value:
			#value = value.duplicate()
		#my_defender = value
#
#@export var my_attack : Attack = null :
	#set(value):
		#if value:
			#value = value.duplicate()
		#my_attack = value
#
#@export_tool_button("Calculate") var cal:= calculate_damage
#func calculate_damage() -> void:
	#if not my_attacker:
		#push_error("No attacker!!!")
		#return
	#if not my_defender:
		#push_error("No defender!!!")
		#return
	#if not my_attack:
		#push_error("No attack play!!!")
		#return
	#print(DamageCalculator.get_damage(my_attacker, my_defender, my_attack))

## TEMPORARY in-game cal button
#@onready var cal_button: Button = %CalButton
#func _ready() -> void:
	#if Engine.is_editor_hint():
		#return
	#cal_button.pressed.connect(calculate_damage)

@onready var camera_2d: Camera2D = $Camera2D

func screenshot() -> void:
	if Engine.is_editor_hint():
		return
	camera_2d.get_viewport().get_texture().get_image().save_png('user:///image.png')

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("screenshot"):
		screenshot()

#endregion


enum Turn {OFFENSE, DEFENSE, SERVE}

@export var turn : Turn = Turn.OFFENSE
