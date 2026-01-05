@tool
extends Attack

func get_attack_pow(_attacker : Beastie, _defender : Beastie) -> int: # Overwrite
	if manually_activated:
		return base_pow * 2
	return base_pow
