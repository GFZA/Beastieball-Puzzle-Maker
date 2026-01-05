@tool
extends Attack


func get_attack_pow(_attacker : Beastie, defender : Beastie) -> int: # Overwrite
	return ceili(float(base_pow) * float(defender.health / 100.0))
