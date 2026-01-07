class_name SelectUIs
extends MarginContainer

var callable_to_call_after_select : Callable = do_nothing

@onready var beastie_select_ui: BeastieSelectUI = %BeastieSelectUI


func _ready() -> void:
	beastie_select_ui.beastie_selected.connect(_on_beastie_selected)
	reset_and_hide()


func _on_beastie_selected(beastie : Beastie) -> void:
	callable_to_call_after_select.call(beastie)
	reset_and_hide()


func reset_and_hide() -> void:
	callable_to_call_after_select = do_nothing
	beastie_select_ui.reset()
	beastie_select_ui.hide()
	hide()


func hide_all_ui() -> void:
	beastie_select_ui.hide()
	#play_select_ui.hide()
	#trait_select_ui.hide()


func show_beastie_select_ui(new_callable : Callable) -> void:
	show()
	hide_all_ui()
	beastie_select_ui.show()
	callable_to_call_after_select = new_callable


func do_nothing() -> void:
	return
