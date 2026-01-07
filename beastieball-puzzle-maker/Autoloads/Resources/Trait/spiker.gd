@tool
extends Trait


func get_attack_mult(attacker : Beastie, _defender : Beastie, _attack : Attack) -> float:
	if attacker.my_field_position in [Beastie.Position.UPPER_FRONT, Beastie.Position.LOWER_FRONT]:
		return damage_dealt_mult
	return 1.0
