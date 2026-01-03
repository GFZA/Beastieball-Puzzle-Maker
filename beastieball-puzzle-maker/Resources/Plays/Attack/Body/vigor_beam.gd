@tool
extends Attack

func get_attack_pow(attacker : Beastie, _defender : Beastie) -> int: # Overwrite
	var bonus : int = clamp(attacker.health, 0, 100)
	return base_pow + bonus
