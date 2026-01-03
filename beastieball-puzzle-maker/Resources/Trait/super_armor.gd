@tool
extends Trait


func get_defense_mult(_attacker : Beastie, defender : Beastie, _attack : Attack) -> float: # Overwrite
	if defender.health >= 75:
		return damage_taken_mult
	return 1.0
