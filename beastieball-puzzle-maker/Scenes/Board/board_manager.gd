@tool
class_name BoardManager
extends Node2D


@export var left_team_controller : TeamController = null : # Assign permanently in inspector
	set(value):
		left_team_controller = value
		if not is_node_ready():
			await ready
		left_team_controller.field_updated.connect(func(pos_dict : Dictionary[Beastie.Position, Beastie]):
			left_team_position_dict = pos_dict
			update_all_damage_indicator()
		)

@export var right_team_controller : TeamController = null : # Assign permanently in inspector
	set(value):
		right_team_controller = value
		if not is_node_ready():
			await ready
		right_team_controller.field_updated.connect(func(pos_dict : Dictionary[Beastie.Position, Beastie]):
			right_team_position_dict = pos_dict
			update_all_damage_indicator()
		)

var left_team_position_dict : Dictionary[Beastie.Position, Beastie] = {}
var right_team_position_dict : Dictionary[Beastie.Position, Beastie] = {}


func get_damage_dict(attacker : Beastie, attack : Attack) -> Dictionary[Beastie.Position, int]:
	var result : Dictionary[Beastie.Position, int] = {
		Beastie.Position.UPPER_BACK : -1,
		Beastie.Position.UPPER_FRONT : -1,
		Beastie.Position.LOWER_BACK : -1,
		Beastie.Position.LOWER_FRONT : -1,
	}

	var defense_side : Dictionary[Beastie.Position, Beastie] = right_team_position_dict \
										if attacker.my_side == Global.MySide.LEFT else left_team_position_dict
	if defense_side.is_empty():
		return result

	for pos : Beastie.Position in result:
		if (attack.target == Attack.Target.FRONT_ONLY and (pos in [Beastie.Position.UPPER_BACK, Beastie.Position.LOWER_BACK])) \
		or (attack.target == Attack.Target.BACK_ONLY and (pos in [Beastie.Position.UPPER_FRONT, Beastie.Position.LOWER_FRONT])):
			result[pos] = -1
			continue

		if defense_side[pos] != null:
			result[pos] = DamageCalculator.get_damage(attacker, defense_side[pos], attack)
			continue

		# If defense_side[position] == null, we need to create new temporary beastie that will
		# move up / down to fill that space and cal the damage on that position.
		# this will also ignore positions where the indicator doesn't show like in-game
		# ex. not showing damage in the lane that oppose to beastie stacking

		if pos == Beastie.Position.UPPER_BACK and defense_side[Beastie.Position.UPPER_FRONT] != null:
			var beastie_move_back : Beastie = defense_side[Beastie.Position.UPPER_FRONT].duplicate(true)
			beastie_move_back.my_field_position = Beastie.Position.UPPER_BACK
			#print("MOVE " + beastie_move_back.specie_name + " from UPPER_FRONT (1) to " + str(beastie_move_back.my_field_position))
			result[pos] = DamageCalculator.get_damage(attacker, beastie_move_back, attack)

		if pos == Beastie.Position.UPPER_FRONT and defense_side[Beastie.Position.UPPER_BACK] != null:
			var beastie_move_front : Beastie = defense_side[Beastie.Position.UPPER_BACK].duplicate(true)
			beastie_move_front.my_field_position = Beastie.Position.UPPER_FRONT
			#print("MOVE " + beastie_move_front.specie_name + " from UPPER_BACK (0) to " + str(beastie_move_front.my_field_position))
			result[pos] = DamageCalculator.get_damage(attacker, beastie_move_front, attack)

		if pos == Beastie.Position.LOWER_BACK and defense_side[Beastie.Position.LOWER_FRONT] != null:
			var beastie_move_back : Beastie = defense_side[Beastie.Position.LOWER_FRONT].duplicate(true)
			beastie_move_back.my_field_position = Beastie.Position.LOWER_BACK
			#print("MOVE " + beastie_move_back.specie_name + " from LOWER_FRONT (3) to " + str(beastie_move_back.my_field_position))
			result[pos] = DamageCalculator.get_damage(attacker, beastie_move_back, attack)

		if pos == Beastie.Position.LOWER_FRONT and defense_side[Beastie.Position.LOWER_BACK] != null:
			var beastie_move_front : Beastie = defense_side[Beastie.Position.LOWER_BACK].duplicate(true)
			beastie_move_front.my_field_position = Beastie.Position.LOWER_FRONT
			#print("MOVE " + beastie_move_front.specie_name + " from LOWER_BACK (2) to " + str(beastie_move_front.my_field_position))
			result[pos] = DamageCalculator.get_damage(attacker, beastie_move_front, attack)

	return result


func _get_damage_dict_for_signal(attacker : Beastie, attack : Attack, send_result_to : DamageIndicator) -> void:
	send_result_to.damage_dict = get_damage_dict(attacker, attack)


func update_all_damage_indicator() -> void:
	var all_plays_ui : Array[Node] = get_tree().get_nodes_in_group("plays_ui_container")
	for plays_ui : PlaysUIContainer in all_plays_ui:
		var first_slot : Plays = plays_ui.beastie.my_plays[0]
		if first_slot and first_slot.type in [Plays.Type.ATTACK_BODY, Plays.Type.ATTACK_SPIRIT, Plays.Type.ATTACK_MIND]:
			plays_ui.damage_indicator.damage_dict = get_damage_dict(plays_ui.beastie, first_slot)
