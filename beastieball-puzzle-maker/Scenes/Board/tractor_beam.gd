@tool
class_name TractorBeam
extends Node2D

@export var start : Vector2 = Vector2.ZERO :
	set(value):
		start = value
		if not is_node_ready():
			await ready
		tractor_beam_head_left.global_position = start

@export var end : Vector2 = Vector2.ZERO :
	set(value):
		end = value
		if not is_node_ready():
			await ready
		tractor_beam_head_right.global_position = end


@onready var tractor_beam: Line2D = %TractorBeam
@onready var tractor_beam_inner: Line2D = %TractorBeamInner
@onready var tractor_beam_head_left: Sprite2D = %TractorBeamHeadLeft
@onready var tractor_beam_head_right: Sprite2D = %TractorBeamHeadRight


func _process(_delta: float) -> void:
	if not is_node_ready():
		return

	if visible:
		tractor_beam.points = PackedVector2Array([tractor_beam_head_left.position, tractor_beam_head_right.position])
		tractor_beam_inner.points = tractor_beam.points.duplicate()
