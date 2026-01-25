@tool
class_name BoardData
extends Resource

# Overlay Dict
@export var overlay_dict : Dictionary = {
	"max_point" : 3,
	"your_point" : 0,
	"opponent_point" : 0,
	"current_turn" : Board.Turn.OFFENSE,
	"action_lefts" : 3,
	"title_text" : "",
	"rigth_text" : "",
	"logo" : null
}

# Team Dicts
@export var left_team_dict : Dictionary = {
	"field_effects" : {},

	"beastie_1_beastie" : null,
	"beastie_1_first_slot_manually_activated" : false,
	"beastie_1_trait_manually_activated" : false,
	"beastie_1_position" : Beastie.Position.NOT_ASSIGNED,
	"beastie_1_show_play" : false,
	"beastie_1_show_bench_damage" : false,
	"beastie_1_have_ball" : false,
	"beastie_1_ball_type" : BeastieScene.BallType.EASY_RECEIVE,
	"beastie_1_h_allign" : HORIZONTAL_ALIGNMENT_CENTER,

	"beastie_2_beastie" : null,
	"beastie_2_first_slot_manually_activated" : false,
	"beastie_2_trait_manually_activated" : false,
	"beastie_2_position" : Beastie.Position.NOT_ASSIGNED,
	"beastie_2_show_play" : false,
	"beastie_2_show_bench_damage" : false,
	"beastie_2_have_ball" : false,
	"beastie_2_ball_type" : BeastieScene.BallType.EASY_RECEIVE,
	"beastie_2_h_allign" : HORIZONTAL_ALIGNMENT_CENTER,

	"bench_beastie_1_beastie" : null,
	"bench_beastie_1_first_slot_manually_activated" : false,
	"bench_beastie_1_trait_manually_activated" : false,
	"bench_beastie_1_show_play" : false,
	"bench_beastie_1_h_allign" : HORIZONTAL_ALIGNMENT_CENTER,

	"bench_beastie_2_beastie" : null,
	"bench_beastie_2_first_slot_manually_activated" : false,
	"bench_beastie_2_trait_manually_activated" : false,
	"bench_beastie_2_show_play" : false,
	"bench_beastie_2_h_allign" : HORIZONTAL_ALIGNMENT_CENTER,
}
@export var right_team_dict : Dictionary = left_team_dict.duplicate()
