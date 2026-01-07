@tool
extends Attack


func get_attack_pow(attacker : Beastie, _defender : Beastie) -> int: # Overwrite
	if not attacker.current_feelings.is_empty():
		return ceili(base_pow * 0.75)
	return base_pow
