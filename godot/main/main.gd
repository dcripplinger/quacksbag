extends Control

@onready var confirm_new_game_modal = $ConfirmNewGameModal
@onready var confirm_add_modal = $ConfirmAddModal
@onready var confirm_specified_draw_modal = $ConfirmSpecifiedDrawModal
@onready var confirm_return_modal = $ConfirmReturnToBagModal
@onready var bag_container = $LeftMarginContainer/VBoxContainer/ScrollContainer/HFlowContainer
@onready var pot_container = $RightMarginContainer/VBoxContainer/ScrollContainer/HFlowContainer
@onready var aside_container = $AsideMarginContainer/VBoxContainer/ScrollContainer/HFlowContainer
@onready var show_button = $BottomMarginContainer/HBoxContainer/ShowButton
@onready var confirm_delete_modal = $ConfirmDeleteToken
@onready var delete_or_add = $DeleteOrDrawModal
@onready var bag_or_aside_modal = $BagOrAsideModal
@onready var pot_to_aside_modal = $ConfirmPotToAside
@onready var bag_or_pot_modal = $BagOrPotModal
@onready var aside_to_bag_modal = $ConfirmAsideToBag
@onready var aside_to_pot_modal = $ConfirmAsideToPot

var save_filename = "user://savegame.save"

var potion_textures = Global.potion_textures
var potion_scene = Global.potion_scene
var bag = []
var pot = []
var aside = []

# Called when the node enters the scene tree for the first time.
func _ready():
	load_game()


func _on_new_game_button_pressed():
	confirm_new_game_modal.show()


func _on_new_game_back_button_pressed():
	confirm_new_game_modal.hide()


func _on_new_game_confirm_button_pressed():
	new_game()
	confirm_new_game_modal.hide()

func new_game():
	bag = [
		"white1",
		"white1",
		"white1",
		"white1",
		"white2",
		"white2",
		"white3",
		"green1",
		"orange1",
	]
	pot = []
	aside = []
	set_potion_nodes()
	
func delete_potion_by_index(index):
	bag.pop_at(index)
	set_potion_nodes()
	
func set_potion_nodes():
	bag.sort()
	for n in bag_container.get_children():
		bag_container.remove_child(n)
		n.queue_free()
	for n in pot_container.get_children():
		pot_container.remove_child(n)
		n.queue_free()
	for n in aside_container.get_children():
		aside_container.remove_child(n)
		n.queue_free()
	for potion_index in range(bag.size()):
		var potion = bag[potion_index]
		var new_potion = potion_scene.instantiate()
		new_potion.set_texture_normal(potion_textures[potion if show_button.button_pressed else "hidden"])
		new_potion.set_disabled(!show_button.button_pressed)
		bag_container.add_child(new_potion)
		new_potion.pressed.connect(on_press_bag_potion.bind(potion_index))
	for potion_index in range(pot.size()):
		var potion = pot[potion_index]
		var new_potion = potion_scene.instantiate()
		new_potion.set_texture_normal(potion_textures[potion])
		pot_container.add_child(new_potion)
		new_potion.pressed.connect(on_press_pot_potion.bind(potion_index))
	for potion_index in range(aside.size()):
		var potion = aside[potion_index]
		var new_potion = potion_scene.instantiate()
		new_potion.set_texture_normal(potion_textures[potion])
		aside_container.add_child(new_potion)
		new_potion.pressed.connect(on_press_aside_potion.bind(potion_index))
	save_game()


func _on_show_button_pressed():
	var children = bag_container.get_children()
	for i in range(children.size()):
		children[i].set_texture_normal(potion_textures[bag[i] if show_button.button_pressed else "hidden"])
		children[i].set_disabled(!show_button.button_pressed)


func _on_draw_button_pressed():
	var picked_index = randi() % bag.size()
	draw_potion_by_index(picked_index)
	
func draw_potion_by_index(picked_index, destination="pot"):
	var picked_potion = bag.pop_at(picked_index)
	if destination == "pot":
		pot.append(picked_potion)
	else:
		aside.append(picked_potion)
	set_potion_nodes()

func _on_empty_pot_button_pressed():
	bag.append_array(pot)
	bag.append_array(aside)
	pot = []
	aside = []
	set_potion_nodes()


func _on_add_button_pressed():
	confirm_add_modal.show()


func _on_confirm_add_modal_potion_selected_to_add(potion):
	bag.append(potion)
	set_potion_nodes()
	
func on_press_bag_potion(potion_index):
	delete_or_add.show()
	delete_or_add.set_potion(bag[potion_index], potion_index)
	
func on_press_pot_potion(potion_index):
	bag_or_aside_modal.show()
	bag_or_aside_modal.set_potion(pot[potion_index], potion_index)
	
func on_press_aside_potion(potion_index):
	bag_or_pot_modal.show()
	bag_or_pot_modal.set_potion(aside[potion_index], potion_index)


func _on_confirm_specified_draw_modal_potion_selected_to_draw(index):
	draw_potion_by_index(index)


func _on_confirm_return_to_bag_modal_potion_selected_to_return(index):
	var returned_potion = pot.pop_at(index)
	bag.append(returned_potion)
	set_potion_nodes()


func _on_confirm_delete_token_potion_selected_to_delete(index):
	delete_potion_by_index(index)


func _on_delete_or_draw_modal_potion_selected_in_bag(potion_index, action):
	if action == "draw":
		confirm_specified_draw_modal.show()
		confirm_specified_draw_modal.set_potion(bag[potion_index], potion_index)
	elif action == "delete":
		confirm_delete_modal.show()
		confirm_delete_modal.set_potion(bag[potion_index], potion_index)

func _on_draw_aside_button_pressed():
	var picked_index = randi() % bag.size()
	draw_potion_by_index(picked_index, "aside")


func _on_bag_or_aside_modal_potion_selected_in_pot(potion_index, action):
	if action == "bag":
		confirm_return_modal.show()
		confirm_return_modal.set_potion(pot[potion_index], potion_index)
	elif action == "aside":
		pass
		pot_to_aside_modal.show()
		pot_to_aside_modal.set_potion(pot[potion_index], potion_index)


func _on_confirm_pot_to_aside_potion_selected_for_pot_to_aside(index):
	var aside_potion = pot.pop_at(index)
	aside.append(aside_potion)
	set_potion_nodes()


func _on_bag_or_pot_modal_potion_selected_in_aside(potion_index, action):
	if action == "bag":
		aside_to_bag_modal.show()
		aside_to_bag_modal.set_potion(aside[potion_index], potion_index)
	elif action == "pot":
		pass
		aside_to_pot_modal.show()
		aside_to_pot_modal.set_potion(aside[potion_index], potion_index)


func _on_confirm_aside_to_bag_potion_selected_for_aside_to_bag(index):
	var bag_potion = aside.pop_at(index)
	bag.append(bag_potion)
	set_potion_nodes()


func _on_confirm_aside_to_pot_potion_selected_for_aside_to_pot(index):
	var pot_potion = aside.pop_at(index)
	pot.append(pot_potion)
	set_potion_nodes()
	
func save_game():
	var save_game = FileAccess.open(save_filename, FileAccess.WRITE)
	var json_string = JSON.stringify({
		"bag": bag,
		"pot": pot,
		"aside": aside,
	})
	save_game.store_string(json_string)
	save_game.close()
	
func load_game():
	if not FileAccess.file_exists(save_filename):
		new_game()
	else:
		var save_game = FileAccess.open(save_filename, FileAccess.READ)
		var json_string = save_game.get_as_text()
		var parsed_result = JSON.parse_string(json_string)
		bag = parsed_result.get("bag", [])
		pot = parsed_result.get("pot", [])
		aside = parsed_result.get("aside", [])
		save_game.close()
		set_potion_nodes()
