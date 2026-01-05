@tool
extends Node


#@export_group("Board States")  ADD THIS LATERRRRRRRRRRR
#@export var cheerleader : bool = false
#@export var friendship : bool = false
#@export var rally : bool = false


func get_damage(attacker : Beastie, defender : Beastie, attack : Attack) -> int: # ADD BOARD STATE LATERRRR

	var attack_name : String = attack.name.to_lower()

	#region Special attacks (early returns)

	if attack_name == "grinder":
		return max(1, ceili(float(defender.health) / 2.0))

	if attack_name == "precision strike":
		return 30

	#endregion

	#region Set up vars

	var base_pow : int = attack.get_attack_pow(attacker, defender)
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
	if attack_name == "contest":
		stats_type_defense = defender.get_highest_def_type()
	if attack_name == "snipe":
		stats_type_defense = defender.get_lowest_def_type()

	var total_attack_stat : int = attacker.get_total_stats_value(stats_type_attack) # Will get +5 from being lv.50 in calculation
	var total_defense_stat : int = defender.get_total_stats_value(stats_type_defense)

	var attacker_at_net : bool = attacker.check_if_net()
	var attack_boosts : int = attacker.get_boosts(stats_type_attack)
	var jazzed : bool = (attacker.get_feeling_stack(Beastie.Feelings.JAZZED) > 0) or (attack_name == "thriller") # TODO cancel thriller effect when dread here
	var attacker_weepy : bool = (attacker.get_feeling_stack(Beastie.Feelings.WEEPY) > 0)

	var defender_at_net : bool = defender.check_if_net()
	var defender_is_stacked : bool = defender.check_if_stack()
	var defense_boosts : int = defender.get_boosts(stats_type_defense)
	var tough : bool = (defender.get_feeling_stack(Beastie.Feelings.TOUGH) > 0)
	var tender : bool = (defender.get_feeling_stack(Beastie.Feelings.TENDER) > 0)
	var defender_weepy : bool = (defender.get_feeling_stack(Beastie.Feelings.WEEPY) > 0)
	#endregion

	#region Get boost counts and damage mults
	# --- POW boosts ---
	var total_attack_boost : int = 0
	var attack_boosts_to_add : int = attack_boosts
	if attacker_weepy or defender.my_trait.name.to_lower() == "foggy":
		attack_boosts_to_add = min(0, attack_boosts) # so it counts deboosts
	total_attack_boost += attack_boosts_to_add

	if jazzed:
		if signi(total_attack_boost) == -1:
			total_attack_boost = 0
		total_attack_boost += 1

	if attacker.my_trait.name.to_lower() == "shy":
		total_attack_boost += int(not attacker_at_net)
	else:
		total_attack_boost += int(attacker_at_net)
	total_attack_boost += attacker.my_trait.get_starter_trait_boost_stack(attacker, stats_type_attack)

	# --- DEF boosts ---
	var total_defense_boost : int = 0
	var def_boosts_to_add : int = defense_boosts
	if defender_weepy or attacker.my_trait.name.to_lower() == "foggy" or attack_name == "raw fury":
		def_boosts_to_add = min(0, defense_boosts) # so it counts deboosts
	total_defense_boost += def_boosts_to_add

	if jazzed:
		total_defense_boost = mini(0, total_defense_boost)

	var defender_is_shy : bool = (defender.my_trait.name.to_lower() == "shy") and (not attack_name == "true strike")
	var is_rocket : bool = attack_name == "rocket"
	if defender_is_shy != is_rocket: # Only swap row bonus when both are true or both are false (XOR condition)
		total_defense_boost += int(defender_at_net)
	else:
		total_defense_boost += int(not defender_at_net) + int(defender_is_stacked)

	if not attacker.my_trait:
		push_error("Attacker %s doesn't have trait assigned!" % attacker.specie_name)
		return 0
	if not defender.my_trait:
		push_error("Defender %s doesn't have trait assigned!" % defender.specie_name)
		return 0

	var attacker_trait_mult : float = attacker.my_trait.get_attack_mult(attacker, defender, attack)
	var defender_trait_mult : float = 1.0
	if not attack_name == "true strike":
		defender_trait_mult = defender.my_trait.get_defense_mult(attacker, defender, attack)

	var blocked_stack : float = 0.0
	if not attack_name == "roll shot":
		blocked_stack = attacker.get_feeling_stack(Beastie.Feelings.BLOCKED)
	var blocked_mult : float = 2.0 / (2.0 + blocked_stack)
	var tough_mult : float = 1.0 / 4.0 if tough and (not attack_name == "raw fury") else 1.0
	var tender_mult : float = 2.0 if tender else 1.0
	#var friendship_mult : float = 3.0 / 4.0 if friendship else 1.0 # TODO
	var friendship_mult : float = 1.0
	var all_damage_mults : float = (attacker_trait_mult / defender_trait_mult) \
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
	#if cheerleader: # TODO
		#final_damage += 10
	final_damage = attacker.my_trait.special_cal_formula(final_damage, attacker, defender, attack)
	if not attack_name == "true strike":
		final_damage = defender.my_trait.special_cal_formula(final_damage, attacker, defender, attack)
	#endregion

	return final_damage
