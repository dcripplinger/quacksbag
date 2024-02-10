extends Control

@onready var confirm_new_game_modal = $ConfirmNewGameModal
@onready var confirm_add_modal = $ConfirmAddModal
@onready var confirm_specified_draw_modal = $ConfirmSpecifiedDrawModal
@onready var confirm_return_modal = $ConfirmReturnToBagModal
@onready var bag_container = $LeftMarginContainer/VBoxContainer/ScrollContainer/HFlowContainer
@onready var pot_container = $RightMarginContainer/VBoxContainer/ScrollContainer/HFlowContainer
@onready var show_button = $BottomMarginContainer/HBoxContainer/ShowButton

var potion_textures = Global.potion_textures
var potion_scene = Global.potion_scene
var bag = []
var pot = []

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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
	bag.sort()
	pot = []
	set_potion_nodes()
	
func set_potion_nodes():
	for n in bag_container.get_children():
		bag_container.remove_child(n)
		n.queue_free()
	for n in pot_container.get_children():
		pot_container.remove_child(n)
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


func _on_show_button_pressed():
	var children = bag_container.get_children()
	for i in range(children.size()):
		children[i].set_texture_normal(potion_textures[bag[i] if show_button.button_pressed else "hidden"])
		children[i].set_disabled(!show_button.button_pressed)


func _on_draw_button_pressed():
	var picked_index = randi() % bag.size()
	draw_potion_by_index(picked_index)
	
func draw_potion_by_index(picked_index):
	var picked_potion = bag.pop_at(picked_index)
	var picked_node = bag_container.get_children()[picked_index]
	bag_container.remove_child(picked_node)
	picked_node.set_texture_normal(potion_textures[picked_potion])
	pot.append(picked_potion)
	pot_container.add_child(picked_node)
	for connection in picked_node.pressed.get_connections():
		picked_node.pressed.disconnect(connection["callable"])
	picked_node.pressed.connect(on_press_pot_potion.bind(pot.size() - 1))
	picked_node.set_disabled(false)


func _on_empty_pot_button_pressed():
	bag.append_array(pot)
	pot = []
	bag.sort()
	set_potion_nodes()


func _on_add_button_pressed():
	confirm_add_modal.show()


func _on_confirm_add_modal_potion_selected_to_add(potion):
	bag.append(potion)
	bag.sort()
	set_potion_nodes()
	
func on_press_bag_potion(potion_index):
	confirm_specified_draw_modal.show()
	confirm_specified_draw_modal.set_potion(bag[potion_index], potion_index)
	
func on_press_pot_potion(potion_index):
	confirm_return_modal.show()
	confirm_return_modal.set_potion(pot[potion_index], potion_index)


func _on_confirm_specified_draw_modal_potion_selected_to_draw(index):
	draw_potion_by_index(index)


func _on_confirm_return_to_bag_modal_potion_selected_to_return(index):
	var returned_potion = pot.pop_at(index)
	bag.append(returned_potion)
	bag.sort()
	set_potion_nodes()
