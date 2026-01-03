@tool
extends Attack

func get_attack_pow(attacker : Beastie, _defender : Beastie) -> int: # Overwrite
	var up_boost_count : int = 0
	for boost in attacker.current_boosts:
		up_boost_count += attacker.current_boosts[boost]
	up_boost_count = min(10, up_boost_count)
	return base_pow + (up_boost_count * 10)
