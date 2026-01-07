class_name SelectUIs
extends MarginContainer


@onready var beastie_button_container: BeastieButtonContainer = %BeastieButtonContainer
@onready var show_name_check_box: CheckBox = %ShowNameCheckBox


func _ready() -> void:
	show_name_check_box.toggled.connect(func(is_toggled : bool): beastie_button_container.show_name = is_toggled)
