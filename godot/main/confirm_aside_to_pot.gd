extends Control

signal potion_selected_for_aside_to_pot(index)

@onready var potion_node = $MarginContainer/VBoxContainer/Potion

var potion_name = "white1"
var potion_index = 0
var potion_textures = Global.potion_textures

	
func set_potion(new_potion_name, new_potion_index):
	potion_name = new_potion_name
	potion_index = new_potion_index
	potion_node.set_texture_normal(potion_textures[potion_name])


func _on_back_button_pressed():
	hide()


func _on_confirm_button_pressed():
	hide()
	potion_selected_for_aside_to_pot.emit(potion_index)

