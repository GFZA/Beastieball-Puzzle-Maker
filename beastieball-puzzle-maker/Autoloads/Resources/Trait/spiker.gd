@tool
extends Trait


func get_attack_mult(attacker : Beastie, _defender : Beastie, _attack : Attack) -> float:
	if attacker.check_if_net():
		return damage_dealt_mult
	return 1.0
