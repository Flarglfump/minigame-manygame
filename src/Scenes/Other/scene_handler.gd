extends Node

func _ready() -> void:
	_add_main_menu()
	_link_main_menu_buttons()

func _on_play_pressed() -> void:
	print("Hello")
	get_node("MainMenu").queue_free()
	var gameScene = load("res://Scenes/Levels/level_1.tscn").instantiate()
	gameScene.connect("level_complete", _on_level_complete.bind(gameScene))
	add_child(gameScene)

func _on_quit_pressed() -> void:
	print("Goodbye :(")
	get_tree().quit(0)

func _on_level_complete(level: Node2D):
	level.queue_free()
	_add_main_menu()
	_link_main_menu_buttons()

func _add_main_menu():
	var menu = preload("res://Scenes/UI/main_menu.tscn").instantiate()
	menu.set_name("MainMenu")
	add_child(menu)
	
func _link_main_menu_buttons():
	get_node("MainMenu/MarginContainer/HBox/VBoxButtons/ButtonPlay").connect("pressed", _on_play_pressed)
	get_node("MainMenu/MarginContainer/HBox/VBoxButtons/ButtonQuit").connect("pressed", _on_quit_pressed)
