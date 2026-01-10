@tool
extends Trait


func get_attack_mult(_attacker : Beastie, defender : Beastie, _attack : Attack) -> float:
	if defender.is_really_at_bench:
		return damage_dealt_mult
	return 1.0
