@tool
extends Attack


func get_attack_pow(_attacker : Beastie, _defender : Beastie) -> int: # Overwrite
	if manually_activated:
		return ceili(base_pow * 1.5)
	return base_pow
