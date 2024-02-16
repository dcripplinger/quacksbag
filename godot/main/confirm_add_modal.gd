extends Control

@onready var potion_container = $MarginContainer/VBoxContainer/MarginContainer/HFlowContainer

signal potion_selected_to_add(potion)

var potion_textures = Global.potion_textures
var potion_scene = Global.potion_scene

var all_potions = [
	"white1",
	"white2",
	"white3",
	"red1",
	"red2",
	"red4",
	"green1",
	"green2",
	"green4",
	"blue1",
	"blue2",
	"blue4",
	"yellow1",
	"yellow2",
	"yellow4",
	"black1",
	"purple1",
	"orange1",
	"orange6",
	"locoweed",
]

# Called when the node enters the scene tree for the first time.
func _ready():
	all_potions.sort()
	for potion in all_potions:
		var new_potion = potion_scene.instantiate()
		new_potion.set_texture_normal(potion_textures[potion])
		new_potion.pressed.connect(on_press_potion.bind(potion))
		potion_container.add_child(new_potion)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_back_button_pressed():
	hide()
	
func on_press_potion(potion):
	hide()
	potion_selected_to_add.emit(potion)
