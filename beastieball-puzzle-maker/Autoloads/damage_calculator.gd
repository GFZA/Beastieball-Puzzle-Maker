@tool
extends Node


#@export_group("Board States")  ADD THIS LATERRRRRRRRRRR
#@export var cheerleader : bool = false
#@export var friendship : bool = false
#@export var rally : bool = false


func get_damage(attacker : Beastie, defender : Beastie, attack : Attack) -> int: # ADD BOARD STATE LATERRRR

	#region Set up vars
	var base_pow : int = attack.base_pow
	var type : Plays.Type = attack.type
	assert(type == Plays.Type.ATTACK_BODY or type == Plays.Type.ATTACK_SPIRIT or type == Plays.Type.ATTACK_MIND,
			"Attack's type not found! Check if the attack is assigned its type correctly!")

	var stats_type_attack : int = int(type)
	var stats_type_defense : int = int(type) + 3
	# Very dirty cheese to convert one enum to another as they're in the same index
	# 0 == Plays.Type.ATTACK_BODY == Beastie.Stats.B_POW
	# 1 == Plays.Type.ATTACK_SPIRIT == Beastie.Stats.S_POW
	# 2 == Plays.Type.ATTACK_MIND == Beastie.Stats.M_POW
	# 3 == Beastie.Stats.B_DEF
	# 4 == Beastie.Stats.S_DEF
	# 5 == Beastie.Stats.M_DEF

	var total_attack_stat : int = attacker.get_total_stats_value(stats_type_attack) # Will get +5 from being lv.50 in calculation
	var total_defense_stat : int = defender.get_total_stats_value(stats_type_defense)

	var attacker_at_net : bool = attacker.check_if_net()
	print(attacker.specie_name + " is at net : " + str(attacker_at_net))
	var attack_boosts : int = attacker.get_boosts(stats_type_attack)
	var jazzed : bool = (attacker.get_feeling_stack(Beastie.Feelings.JAZZED) > 0)

	var defender_at_net : bool = defender.check_if_net()
	print(defender.specie_name + " is at net : " + str(defender_at_net))
	var defender_is_stacked : bool = defender.check_if_stack()
	print(defender.specie_name + " is stacked : " + str(defender_is_stacked))
	var defense_boosts : int = defender.get_boosts(stats_type_defense)
	var tough : bool = (defender.get_feeling_stack(Beastie.Feelings.TOUGH) > 0)
	#var tender : bool = (defender.get_feeling_stack(Beastie.Feelings.TENDER) > 0)
	#endregion

	#region Get boost counts and damage mults
	var total_attack_boost : int = 0
	total_attack_boost += attack_boosts
	if jazzed:
		if signi(total_attack_boost) == -1:
			total_attack_boost = 0
		total_attack_boost += 1
	total_attack_boost += int(attacker_at_net)

	var total_defense_boost : int = 0
	total_defense_boost += defense_boosts
	if jazzed:
		total_defense_boost = mini(0, total_defense_boost)
	#if tender:
		# HOW THE FUCK DOES THIS SHIT WORK???
	total_defense_boost += int(not defender_at_net) + int(defender_is_stacked)

	if not attacker.my_trait:
		push_error("Attacker %s doesn't have trait assigned!" % [attacker.specie_name])
		return 0
	if not defender.my_trait:
		push_error("Defender %s doesn't have trait assigned!" % defender.specie_name)
		return 0
	var blocked_mult : float = 2.0 / (2.0 + attacker.get_feeling_stack(Beastie.Feelings.BLOCKED))
	var tough_mult : float = 1.0 / 4.0 if tough else 1.0
	#var tender_mult : float = 2.0 if tender else 1.0
	var tender_mult : float = 1.0 # TODO TODO TODO or not lol
	#var friendship_mult : float = 3.0 / 4.0 if friendship else 1.0 # TODO TODO TODO or not lol
	var friendship_mult : float = 1.0
	var all_damage_mults : float = (attacker.my_trait.damage_dealt_mult / defender.my_trait.damage_taken_mult) \
									* blocked_mult * tough_mult * tender_mult * friendship_mult
	#endregion

	#region Get final stats for calculation
	var final_atk : float = float(total_attack_stat) + 5.0
	match signi(total_attack_boost):
		1:
			final_atk += floori(final_atk * float(total_attack_boost) / 2.0)
		-1:
			final_atk = floori(final_atk * 2.0 / (absf(float(total_attack_boost)) + 2.0))

	var final_def : float = float(total_defense_stat) + 5.0
	match signi(total_defense_boost):
		1:
			final_def += floori(final_def * float(total_defense_boost) / 2.0)
		-1:
			final_def = floori(final_def * 2.0 / (absf(float(total_defense_boost)) + 2.0))
	#endregion

	#region Calculate the damage + board states
	#var friendship_mult : float = 3.0/4.0 if friendship else 1.0
	var final_damage : int = max(1, ceili(((floori(final_atk) * base_pow / final_def) * 0.4) * all_damage_mults))
	#if cheerleader:
		#final_damage += 10
	#endregion

	return final_damage
