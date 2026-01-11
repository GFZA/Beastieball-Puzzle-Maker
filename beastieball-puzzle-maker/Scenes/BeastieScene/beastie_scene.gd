@tool
class_name BeastieScene
extends Node2D

signal side_updated(my_side : Global.MySide)

enum BallType {BODY, SPIRIT, MIND, EASY_RECEIVE}

const PLACEHOLDER_TEXTURE : Texture2D = preload("uid://chctbds4hrdsq")
const BALL_TEXTURES : Dictionary[BallType, Texture2D] = {
	BallType.BODY : preload("uid://dfe851hg76da0"),
	BallType.SPIRIT : preload("uid://4pnldigfam75"),
	BallType.MIND : preload("uid://bj4bam8hy6bpw"),
	BallType.EASY_RECEIVE : preload("uid://78plds302l5")
}

const HEALTHBAR_SCENE : PackedScene = preload("uid://bvd7pbsfc56o0")
const FEELINGS_CLOUD_SCENE = preload("uid://bx6reuiultnkv")

const BALL_SPRITE_LEFT_OFFSET : Vector2 = Vector2(-10.0, -90.0)
const BALL_SPRITE_RIGHT_OFFSET : Vector2 = Vector2(-119.0, -90.0)

@export var beastie : Beastie = null :
	set(value):
		if not is_node_ready():
			await ready

		sprite_2d.offset.y = 0.0
		ball_sprite.hide()

		if my_healthbar:
			my_healthbar.queue_free()
			my_healthbar = null

		if my_feelings_cloud:
			my_feelings_cloud.queue_free()
			my_feelings_cloud = null

		if value == null:
			current_sprite = PLACEHOLDER_TEXTURE
			if beastie.current_feelings_updated.is_connected(_update_sprite_pose):
				beastie.current_feelings_updated.disconnect(_update_sprite_pose)
			beastie = value
			return

		beastie = value # Not duplicate so it's the same as TeamContoller's one
		beastie.current_feelings_updated.connect(_update_sprite_pose.unbind(1))
		_set_ball_anchor_position(beastie.ball_anchor_position)

		if not my_healthbar:
			var new_healthbar : Healthbar = HEALTHBAR_SCENE.instantiate()
			new_healthbar.beastie = beastie
			side_updated.connect(new_healthbar.update_side)
			new_healthbar.my_side = my_side
			new_healthbar.benched = benched
			add_child(new_healthbar)
			my_healthbar = new_healthbar

		if not my_feelings_cloud:
			var new_cloud : FeelingsCloud = FEELINGS_CLOUD_SCENE.instantiate()
			new_cloud.beastie = beastie
			new_cloud.my_side = my_side
			var anchor : Marker2D = left_feelings_anchor if my_side == Global.MySide.LEFT else right_feelings_anchor
			anchor.add_child(new_cloud)
			new_cloud.global_position = anchor.global_position
			my_feelings_cloud = new_cloud

		_update_ball()
		_update_sprite_pose()
		sprite_2d.offset.y = beastie.y_offset

@export var h_allign : HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER :
	set(value):
		h_allign = value
		if not is_node_ready():
			await ready
		if my_healthbar:
			my_healthbar.h_allign = h_allign

@export var my_side : Global.MySide = Global.MySide.LEFT :
	set(value):
		my_side = value
		_update_side(my_side)

@export var have_ball : bool = false :
	set(value):
		have_ball = value
		_update_ball()

@export var ball_type : BallType = BallType.EASY_RECEIVE :
	set(value):
		ball_type = value
		_update_ball()

@export var sprite_pose_overwrite : Beastie.Sprite = Beastie.Sprite.IDLE :
	set(value):
		sprite_pose_overwrite = value
		_overwrite_sprite_pose(sprite_pose_overwrite)

var current_sprite : Texture2D = null :
	set(value):
		current_sprite = value
		sprite_2d.texture = current_sprite

var benched : bool = false # Not use setter because only set it once and after having healthbar

var my_healthbar : Healthbar = null
#var my_plays_ui_container : PlaysUIContainer = null
var my_feelings_cloud : FeelingsCloud = null

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var left_feelings_anchor: Marker2D = %LeftFeelingsAnchor
@onready var right_feelings_anchor: Marker2D = %RightFeelingsAnchor
@onready var ball_anchor: Marker2D = %BallAnchor
@onready var ball_sprite: Sprite2D = %BallSprite


func _update_sprite_pose() -> void:
	if not is_node_ready():
		await ready

	if not beastie:
		current_sprite = PLACEHOLDER_TEXTURE
		return

	# Ball poses takes priority over feelings pose
	if have_ball:
		match ball_type:
			BallType.EASY_RECEIVE:
				current_sprite = beastie.get_sprite(Beastie.Sprite.READY)
				return
			_:
				current_sprite = beastie.get_sprite(Beastie.Sprite.VOLLEY)
				return

	# Critical bad feelings take priority over good feelings
	var current_feelings : Dictionary[Beastie.Feelings, int] = beastie.current_feelings
	for feelings in current_feelings.keys():
		if feelings in [Beastie.Feelings.WIPED, Beastie.Feelings.STRESSED, \
						Beastie.Feelings.TRIED, Beastie.Feelings.TENDER, Beastie.Feelings.SHOOK]:
			current_sprite = beastie.get_sprite(Beastie.Sprite.BAD)
			return

	for feelings in current_feelings.keys():
		if feelings in [Beastie.Feelings.JAZZED, Beastie.Feelings.NOISY, Beastie.Feelings.TOUGH]:
			current_sprite = beastie.get_sprite(Beastie.Sprite.GOOD)
			return

	# Not fitting any condition, idle
	current_sprite = beastie.get_sprite(Beastie.Sprite.IDLE)


func _overwrite_sprite_pose(new_sprite : Beastie.Sprite) -> void:
	if not is_node_ready():
		await ready
	# Ignore all logic and just replace sprite lol
	current_sprite = beastie.get_sprite(new_sprite)


func _update_side(new_side : Global.MySide) -> void:
	if not is_node_ready():
		await ready
	var is_left : bool = (new_side == Global.MySide.LEFT)
	sprite_2d.flip_h = is_left
	ball_sprite.flip_h = is_left
	_set_ball_anchor_position(beastie.ball_anchor_position)
	ball_sprite.offset = BALL_SPRITE_LEFT_OFFSET if is_left else BALL_SPRITE_RIGHT_OFFSET
	if my_feelings_cloud:
		var new_parent : Marker2D = left_feelings_anchor if is_left else right_feelings_anchor
		my_feelings_cloud.reparent(new_parent)
		my_feelings_cloud.position = Vector2.ZERO
		my_feelings_cloud.my_side = new_side
	side_updated.emit(my_side)


func _update_ball() -> void:
	if not is_node_ready():
		await ready
	ball_sprite.hide()

	if have_ball:
		ball_sprite.texture = BALL_TEXTURES.get(ball_type)
		ball_sprite.show()
	_update_sprite_pose()


func _set_ball_anchor_position(ball_anchor_position : Vector2) -> void:
	if my_side == Global.MySide.RIGHT:
		ball_anchor.position = ball_anchor_position.reflect(Vector2.UP)
	else:
		ball_anchor.position = ball_anchor_position
