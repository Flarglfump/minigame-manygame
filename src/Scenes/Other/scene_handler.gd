extends Node

func _ready() -> void:
	get_node("MainMenu/MarginContainer/HBox/VBoxButtons/ButtonPlay").connect("pressed", _on_play_pressed.bind())
	get_node("MainMenu/MarginContainer/HBox/VBoxButtons/ButtonQuit").connect("pressed", _on_quit_pressed.bind())
	pass

func _on_play_pressed() -> void:
	print("Hello")
	get_node("MainMenu").queue_free()
	var gameScene = load("res://Scenes/Levels/level_1.tscn").instantiate()
	add_child(gameScene)
	pass

func _on_quit_pressed() -> void:
	print("Goodbye :(")
	get_tree().quit(0)
	pass
