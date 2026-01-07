@tool
class_name AddBeastieUI
extends HBoxContainer


signal add_beastie_requested(requested_side : Global.MySide, requested_pos : Beastie.Position, request_reset : bool)
signal beastie_menu_requested(requested_beastie : Beastie)


@export var text : String = "Serve Slot" :
	set(value):
		text = value
		if not is_node_ready():
			await ready
		front_label.text = text
@export var pos : Beastie.Position = Beastie.Position.UPPER_BACK

var side : Global.MySide = Global.MySide.LEFT

@onready var front_label: Label = %FrontLabel
@onready var swap_button_container: VBoxContainer = %SwapButtonContainer
@onready var swap_up_button: Button = %SwapUpButton
@onready var swap_down_button: Button = %SwapDownButton
@onready var beastie_button: Button = %BeastieButton
@onready var add_button: Button = %AddButton
@onready var reset_button: Button = %ResetButton


var my_beastie : Beastie = preload("uid://dr6dti4ow55uy").duplicate(true)


func _ready() -> void:
	swap_up_button.pressed.connect(func(): print("Swap up (%s) requested." % my_beastie.specie_name))
	swap_up_button.pressed.connect(func(): print("Swap down (%s) requested." % my_beastie.specie_name))
	reset_button.pressed.connect(_on_reset_button_pressed)
	add_button.pressed.connect(_on_add_button_pressed)
	beastie_button.pressed.connect(beastie_menu_requested.emit.bind(my_beastie))

	reset()


func reset() -> void:
	add_button.show()
	beastie_button.text = ""
	beastie_button.hide()
	reset_button.hide()
	swap_button_container.hide()


func _on_add_button_pressed() -> void:
	add_beastie_requested.emit.bind(side, pos, false)
	on_beastie_added(my_beastie.duplicate(true))


func _on_reset_button_pressed() -> void:
	reset()
	add_beastie_requested.emit.bind(side, pos, true)


func on_beastie_added(beastie : Beastie) -> void:
	add_button.hide()
	beastie_button.text = beastie.specie_name
	beastie_button.show()
	reset_button.show()
	swap_button_container.show()
