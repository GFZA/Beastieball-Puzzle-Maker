@tool
extends Trait

const MAX_DAMAGE := 50

func special_cal_formula(damage : int, _attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 attacker_team_controller : TeamController = null, \
					 defender_team_controller : TeamController = null) -> int: # Overwrite
	if need_to_be_manually_activated:
		if manually_activated and damage > MAX_DAMAGE:
			return MAX_DAMAGE
		return damage

	if not defender_team_controller:
		return damage
	var have_rally : bool = (attacker_team_controller.get_field_effect_stack(FieldEffect.Type.RALLY) > 0) or \
							(defender_team_controller.get_field_effect_stack(FieldEffect.Type.RALLY) > 0)
	var have_dread : bool = (attacker_team_controller.get_field_effect_stack(FieldEffect.Type.DREAD) > 0) or \
							(defender_team_controller.get_field_effect_stack(FieldEffect.Type.DREAD) > 0)

	if (have_rally or have_dread) and damage > MAX_DAMAGE:
		return MAX_DAMAGE

	return damage
