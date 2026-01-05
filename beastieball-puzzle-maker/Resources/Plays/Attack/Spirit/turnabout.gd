@tool
extends Attack


func get_attack_pow(attacker : Beastie, _defender : Beastie) -> int: # Overwrite
	if attacker.health < 34:
		return base_pow * 2
	return base_pow
