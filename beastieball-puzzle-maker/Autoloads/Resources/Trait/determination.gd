@tool
extends Trait


func get_attack_mult(attacker : Beastie, _defender : Beastie, _attack : Attack) -> float:
	for feelings in attacker.current_feelings:
		if (attacker.get_feeling_stack(Beastie.Feelings.SWEATY) > 0) or \
			(attacker.get_feeling_stack(Beastie.Feelings.NERVOUS) > 0) or \
			(attacker.get_feeling_stack(Beastie.Feelings.TENDER) > 0) or \
			(attacker.get_feeling_stack(Beastie.Feelings.WEEPY) > 0):
			return damage_dealt_mult
	return 1.0
