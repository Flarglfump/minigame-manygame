extends Node

var levelDict := {
	"MainMenu" : "res://Scenes/UI/main_menu.tscn",
	"Level1" : "res://Scenes/Levels/level_1.tscn",
	"Level2" : "res://Scenes/Levels/level_2.tscn",
	"Level3" : "res://Scenes/Levels/level_3.tscn"
}

var levelList := ["MainMenu", "Level1", "Level2", "Level3"]

func _ready() -> void:
	_load_main_menu()

func _on_play_pressed() -> void:
	print("Hello")
	get_node("MainMenu").queue_free()
	_load_level("Level1")

func _on_quit_pressed() -> void:
	print("Goodbye :(")
	get_tree().quit(0)

func _on_level_complete(level : Node2D, levelName : String) -> void:
	level.queue_free()
	var nextLevel := _get_next_level(levelName)
	_load_level(nextLevel)

func _on_level_quit(level : Node2D) -> void:
	level.queue_free()
	_load_main_menu()

func _load_main_menu() -> void:
	var menu = preload("res://Scenes/UI/main_menu.tscn").instantiate()
	menu.set_name("MainMenu")
	add_child(menu)
	_link_main_menu_buttons()

func _link_main_menu_buttons() -> void:
	get_node("MainMenu/MarginContainer/HBox/VBoxButtons/ButtonPlay").connect("pressed", _on_play_pressed)
	get_node("MainMenu/MarginContainer/HBox/VBoxButtons/ButtonQuit").connect("pressed", _on_quit_pressed)

func _load_level(levelName : String) -> void:
	print("Loading Level ", levelName)
	if levelName == "MainMenu":
		_load_main_menu()
		return

	var path = levelDict[levelName]
	print("Path: ", path)
	var gameScene = await load(path).instantiate()
	gameScene.connect("level_complete", _on_level_complete.bind(gameScene, levelName))
	gameScene.connect("level_quit", _on_level_quit.bind(gameScene))
	add_child(gameScene)

func _get_next_level(levelName : String) -> String:
	var where := levelList.find(levelName)
	return levelList[(where + 1) % levelList.size()]
