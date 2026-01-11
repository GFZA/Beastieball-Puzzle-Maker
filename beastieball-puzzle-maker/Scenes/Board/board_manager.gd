@tool
class_name BoardManager
extends Node2D

signal data_saved
signal data_loaded
signal board_resetted

@export_tool_button("Save Board") var save_board_var := save_board_data
@export var load_data : BoardData = null :
	set(value):
		load_board_data(value)
		load_data = null # Read then done

@export_group("Reset Board NO UNDO!")
@export_tool_button("Reset Board") var reset_board_var := reset_board

@export_group("Team Controllers")
@export var left_team_controller : TeamController = null : # Assign permanently in inspector
	set(value):
		left_team_controller = value
		if not is_node_ready():
			await ready
		left_team_controller.field_updated.connect(func(pos_dict : Dictionary[Beastie.Position, Beastie]):
			left_team_position_dict = pos_dict
			update_all_damage_indicator()
		)

@export var right_team_controller : TeamController = null : # Assign permanently in inspector
	set(value):
		right_team_controller = value
		if not is_node_ready():
			await ready
		right_team_controller.field_updated.connect(func(pos_dict : Dictionary[Beastie.Position, Beastie]):
			right_team_position_dict = pos_dict
			update_all_damage_indicator()
		)

var left_team_position_dict : Dictionary[Beastie.Position, Beastie] = {}
var right_team_position_dict : Dictionary[Beastie.Position, Beastie] = {}


func get_damage_dict_array(attacker : Beastie, attack : Attack) -> Array[Dictionary]:
	var empty_dict : Dictionary[Beastie.Position, int] = {
		Beastie.Position.UPPER_BACK : -1,
		Beastie.Position.UPPER_FRONT : -1,
		Beastie.Position.LOWER_BACK : -1,
		Beastie.Position.LOWER_FRONT : -1,
	}
	var result : Array[Dictionary] = [empty_dict.duplicate(), empty_dict.duplicate()]

	if not attack.show_in_indicator:
		return result

	# Update Field Dict then Bench Dict
	for i in 2:
		var result_dict : Dictionary[Beastie.Position, int] = empty_dict.duplicate()
		var attacker_scene : BeastieScene = find_beastie_scene(attacker) # Need to use scene to determine side because of spagetti code :(
		var attacker_is_left : bool = attacker_scene.my_side == Global.MySide.LEFT
		var attacker_team_controller : TeamController = left_team_controller if attacker_is_left else right_team_controller
		var defender_team_controller : TeamController = right_team_controller if attacker_is_left else left_team_controller

		var defense_side : Dictionary[Beastie.Position, Beastie] = TeamController.get_empty_position_dict() # Assign below
		var unfiltered_pos_dict : Dictionary[Beastie.Position, Beastie] = right_team_position_dict.duplicate() \
														if attacker_is_left else left_team_position_dict.duplicate()

		# Assign defense_side (use for cal)
		match i:
			0: # First Loop, Use Beasties currently on the Field
				unfiltered_pos_dict.erase(Beastie.Position.BENCH_1)
				unfiltered_pos_dict.erase(Beastie.Position.BENCH_2)
			1: # Second Loop, Use Beasties currently on the Bench and pretend they're on the field
				var bench_1 : Beastie = unfiltered_pos_dict.get(Beastie.Position.BENCH_1)
				var bench_2 : Beastie = unfiltered_pos_dict.get(Beastie.Position.BENCH_2)
				if bench_1:
					bench_1.my_field_position = Beastie.Position.UPPER_BACK
					bench_1.is_really_at_bench = true
				if bench_2:
					bench_2.my_field_position = Beastie.Position.LOWER_BACK
					bench_2.is_really_at_bench = true
				unfiltered_pos_dict = TeamController.get_empty_position_dict()
				unfiltered_pos_dict[Beastie.Position.UPPER_BACK] = bench_1
				unfiltered_pos_dict[Beastie.Position.LOWER_BACK] = bench_2
				unfiltered_pos_dict.erase(Beastie.Position.BENCH_1)
				unfiltered_pos_dict.erase(Beastie.Position.BENCH_2)
		defense_side = unfiltered_pos_dict

		if defense_side.is_empty():
			result[i] = result_dict
			continue

		for pos : Beastie.Position in result_dict:
			if (attack.target == Attack.Target.FRONT_ONLY and (pos in [Beastie.Position.UPPER_BACK, Beastie.Position.LOWER_BACK])) \
			or (attack.target == Attack.Target.BACK_ONLY and (pos in [Beastie.Position.UPPER_FRONT, Beastie.Position.LOWER_FRONT])):
				result_dict[pos] = -1
				continue

			var attacker_for_cal : Beastie = attacker.duplicate(true)
			var original_pos : Beastie.Position = attacker.my_field_position
			if original_pos in [Beastie.Position.BENCH_1, Beastie.Position.BENCH_2]:
				original_pos = Beastie.Position.UPPER_BACK # Upper or Lower doesn't matter here
			attacker_for_cal.my_field_position = original_pos

			match attack.use_condition:
				Attack.UseCondition.FRONT_ONLY: # If at back, move front for cal
					attacker_for_cal.my_field_position = Beastie.Position.UPPER_FRONT # Upper or Lower doesn't matter here
				Attack.UseCondition.BACK_ONLY: # If at front, move back for cal
					attacker_for_cal.my_field_position = Beastie.Position.UPPER_BACK # Upper or Lower doesn't matter here

			if defense_side[pos] != null:
				result_dict[pos] = DamageCalculator.get_damage(attacker_for_cal, defense_side[pos], attack, attacker_team_controller, defender_team_controller)
				continue

			# If defense_side[position] == null, we need to create new temporary beastie that will
			# move up / down to fill that space and cal the damage on that position.
			# this will also ignore positions where the indicator doesn't show like in-game
			# ex. not showing damage in the lane that oppose to beastie stacking

				# For some reason, is_really_at_bench will get disable after even .duplicate(true)
				# so we reassgin this stupid var again.
				# the code is super messy now and I can't be bothered anymore
				# I spent almost an hour fixing this, fuck this shit...

			if pos == Beastie.Position.UPPER_BACK and defense_side[Beastie.Position.UPPER_FRONT] != null:
				var beastie_move_back : Beastie = defense_side[Beastie.Position.UPPER_FRONT].duplicate(true)
				beastie_move_back.my_field_position = Beastie.Position.UPPER_BACK
				beastie_move_back.is_really_at_bench = defense_side[Beastie.Position.UPPER_FRONT].is_really_at_bench
				result_dict[pos] = DamageCalculator.get_damage(attacker_for_cal, beastie_move_back, attack, attacker_team_controller, defender_team_controller)

			if pos == Beastie.Position.UPPER_FRONT and defense_side[Beastie.Position.UPPER_BACK] != null:
				var beastie_move_front : Beastie = defense_side[Beastie.Position.UPPER_BACK].duplicate(true)
				beastie_move_front.my_field_position = Beastie.Position.UPPER_FRONT
				beastie_move_front.is_really_at_bench = defense_side[Beastie.Position.UPPER_BACK].is_really_at_bench
				result_dict[pos] = DamageCalculator.get_damage(attacker_for_cal, beastie_move_front, attack, attacker_team_controller, defender_team_controller)

			if pos == Beastie.Position.LOWER_BACK and defense_side[Beastie.Position.LOWER_FRONT] != null:
				var beastie_move_back : Beastie = defense_side[Beastie.Position.LOWER_FRONT].duplicate(true)
				beastie_move_back.my_field_position = Beastie.Position.LOWER_BACK
				beastie_move_back.is_really_at_bench = defense_side[Beastie.Position.LOWER_FRONT].is_really_at_bench
				result_dict[pos] = DamageCalculator.get_damage(attacker_for_cal, beastie_move_back, attack, attacker_team_controller, defender_team_controller)

			if pos == Beastie.Position.LOWER_FRONT and defense_side[Beastie.Position.LOWER_BACK] != null:
				var beastie_move_front : Beastie = defense_side[Beastie.Position.LOWER_BACK].duplicate(true)
				beastie_move_front.my_field_position = Beastie.Position.LOWER_FRONT
				beastie_move_front.is_really_at_bench = defense_side[Beastie.Position.LOWER_BACK].is_really_at_bench
				result_dict[pos] = DamageCalculator.get_damage(attacker_for_cal, beastie_move_front, attack, attacker_team_controller, defender_team_controller)

		result[i] = result_dict

	return result


func update_all_damage_indicator() -> void:
	var all_plays_ui : Array[Node] = get_tree().get_nodes_in_group("plays_ui_container")
	for plays_ui : PlaysUIContainer in all_plays_ui:
		var first_slot : Plays = plays_ui.beastie.my_plays[0]
		if first_slot and first_slot.type in [Plays.Type.ATTACK_BODY, Plays.Type.ATTACK_SPIRIT, Plays.Type.ATTACK_MIND]:
			plays_ui.damage_indicator.damage_dict_array = get_damage_dict_array(plays_ui.beastie, first_slot)


func find_beastie_scene(beastie : Beastie) -> BeastieScene:
	var all_scene : Array[Node] = get_tree().get_nodes_in_group("beastie_scene")
	for scene : BeastieScene in all_scene:
		if scene.beastie == beastie:
			return scene
	return null


# Behold the worse ssavd/load system ever

func save_board_data() -> void:
	var board_data := BoardData.new()
	board_data.data = [
		left_team_controller.get_data_to_save(),
		right_team_controller.get_data_to_save()
	]
	var save_name : String = "board_%s" % (DirAccess.get_files_at("res://Resources/BoardData").size() - 1)
	ResourceSaver.save(board_data, "res://Resources/BoardData/" + save_name + ".res")
	await get_tree().process_frame
	data_saved.emit()


func load_board_data(board_data : BoardData) -> void:
	reset_board()
	if not board_data:
		await get_tree().process_frame
		data_loaded.emit()
		return

	left_team_controller.load_data_from_save(board_data.data[0])
	right_team_controller.load_data_from_save(board_data.data[1])
	await get_tree().process_frame
	data_loaded.emit()


func reset_board() -> void:
	left_team_controller.reset_team()
	right_team_controller.reset_team()
	await get_tree().process_frame
	board_resetted.emit()
