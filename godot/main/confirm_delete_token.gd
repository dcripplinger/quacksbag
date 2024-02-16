extends Control

signal potion_selected_to_delete(index)

@onready var potion_node = $MarginContainer/VBoxContainer/Potion

var potion_name = "white1"
var potion_index = 0
var potion_textures = Global.potion_textures

	
func set_potion(deleted_potion_name, deleted_potion_index):
	potion_name = deleted_potion_name
	potion_index = deleted_potion_index
	potion_node.set_texture_normal(potion_textures[potion_name])


func _on_back_button_pressed():
	hide()


func _on_confirm_button_pressed():
	hide()
	potion_selected_to_delete.emit(potion_index)

