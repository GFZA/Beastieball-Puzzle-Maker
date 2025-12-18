@tool
extends Node2D

enum Type {BODY, SPIRIT, MIND}

@onready var camera_2d: Camera2D = $Camera2D

func screenshot() -> void:
	if Engine.is_editor_hint():
		return
	camera_2d.get_viewport().get_texture().get_image().save_png('user:///image.png')

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("screenshot"):
		screenshot()


@export_tool_button("Calculate")
var calculate_action = print_damage

@export_group("Stats")
@export_subgroup("Attacker")
@export var type : Type = Type.MIND
@export var base_pow : int = 1
@export var base_attack_stat : int = 1 # Will get +5 from being lv.50 in calculation
@export_range(0, 30) var attacker_invest : int = 0
@export_subgroup("Defender")
@export var base_defense_stat : int = 1 # Will get +5 from being lv.50 in calculation
@export_range(0, 30) var defender_invest : int = 0

@export_group("Boosts")
@export_subgroup("Attacker")
@export var attacker_at_net : bool = false
@export var attack_boosts : int = 0
@export var jazzed : bool = false
@export_subgroup("Defender")
@export var defender_at_net : bool = false
@export var defense_boosts : int = 0
#@export var tender : bool = false

@export_group("Board States")
@export var cheerleader : bool = false
@export var friendship : bool = false
#@export var rally : bool = false
@export var weariness : int = 0

func get_final_damage() -> int:
	var final_atk : float = float(_get_final_atk())
	var final_def : float = float(_get_final_def())
	var friendship_mult : float = 3.0/4.0 if friendship else 1.0
	var final_damage : int = ceili(((floori(final_atk) * base_pow / final_def) * 0.4) * friendship_mult)
	if cheerleader:
		final_damage += 10
	if weariness > 7:
		final_damage += 10 * (weariness - 7)
	return final_damage

func print_damage() -> void:
	print(get_final_damage())


func _get_total_attack_boost() -> int: # not used yet
	var count : int = 0
	count += attack_boosts
	if jazzed:
		if signi(count) == -1:
			count = 0
		count += 1
	count += int(attacker_at_net)
	return count

func _get_total_defense_boost() -> int: # not used yet
	var count : int = 0
	count += defense_boosts
	if jazzed:
		count = mini(0, count)
	#if tender:
		# HOW THE FUCK DOES THIS SHIT WORK???
	count += int(not defender_at_net)
	return count

func _get_final_atk() -> int:
	var final_atk : float = float(base_attack_stat) + attacker_invest + 5.0
	var boost_count : int = _get_total_attack_boost()
	match signi(boost_count):
		1:
			final_atk += floori(final_atk * float(boost_count) / 2.0)
		-1:
			final_atk = floori(final_atk * 2.0 / (absf(float(boost_count)) + 2.0))
	return int(final_atk)

func _get_final_def() -> int:
	var final_def : float = float(base_defense_stat) + defender_invest + 5.0
	var boost_count : int = _get_total_defense_boost()
	match signi(boost_count):
		1:
			final_def += floori(final_def * float(boost_count) / 2.0)
		-1:
			final_def = floori(final_def * 2.0 / (absf(float(boost_count)) + 2.0))
	return int(final_def)
