@tool
extends Attack


func get_attack_pow(_attacker : Beastie, defender : Beastie) -> int: # Overwrite
	if defender.is_really_at_bench:
		return base_pow * 2
	return base_pow
