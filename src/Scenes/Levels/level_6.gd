extends Node2D
@onready var packedPlayer := preload("res://Scenes/Actors/Player/player.tscn")
@onready var spawnPoint1 = $SpawnMarker1.get_global_position()
@onready var endDoor := $EndDoor
@onready var pauseMenu = $PauseMenu

@onready var mirror1 := $Mirror1
@onready var mirror2 := $Mirror2

var _playersToClear : int
var _do_reset : bool
var _paused : bool

signal level_complete
signal level_quit

# Spawn player at initial spawnpoint
func _ready() -> void:
	endDoor.connect("door_entered", _on_end_door_entered)
	mirror1.connect("mirror_touched", _on_mirror_touched.bind(mirror1))
	mirror2.connect("mirror_touched", _on_mirror_touched.bind(mirror2))
	_init_pause_menu()

	init_level()

# Watch for reset or pause inputs
func _process(_delta: float) -> void:
	# Handle Reset Event
	if Input.is_action_just_pressed("pause"):
		_on_pause_pressed()

	if _paused:
		return

	if Input.is_action_just_pressed("reset"):
		_on_reset_pressed()

# Spawn player, initialize, and append to player list
func _spawn_player(globalSpawnpoint: Vector2, reverse_controls := false) -> void:
	var newPlayer := packedPlayer.instantiate()
	self.add_child(newPlayer)
	newPlayer.initPlayer(globalSpawnpoint, reverse_controls)
	newPlayer.add_to_group("ActivePlayers")
	newPlayer.connect("death_animation_finished", _on_player_death_animation_finished.bind(newPlayer))
	newPlayer.connect("touched_hazard", _on_hazard_touched.bind(newPlayer))

func _on_reset_pressed() -> void:
	_playersToClear = _get_player_count()
	_do_reset = true

	for player in get_tree().get_nodes_in_group("ActivePlayers"):
		player.die()

# Reset level
func _reset_level() -> void:

	init_level()

func _get_player_count() -> int:
	return get_tree().get_nodes_in_group("ActivePlayers").size()

func kill_all_players() -> void:
	for player in get_tree().get_nodes_in_group("ActivePlayers"):
		player.die()

func init_level() -> void:
	_do_reset = false
	_spawn_player(spawnPoint1)
	endDoor.initLockState(false)
	mirror1.initBrokenState(false)
	mirror2.initBrokenState(false)
	_unfreeze_players()

func _on_end_door_entered() -> void:
	emit_signal("level_complete")

func _on_player_death_animation_finished(sender: CharacterBody2D) -> void:
	if not sender.is_in_group("Player"):
		return

	sender.remove_from_group("ActivePlayers")
	_playersToClear -= 1
	await get_tree().create_timer(0.5).timeout
	sender.queue_free()
	if _playersToClear == 0 and _do_reset:
		_reset_level()

func _on_pause_pressed():
	if _paused:
		pauseMenu.hide()
		_unfreeze_players()
		Engine.time_scale = 1
	else:
		pauseMenu.show()
		_freeze_players()
		Engine.time_scale = 0
	_paused = !_paused

func _on_quit_pressed():
	_on_pause_pressed()
	emit_signal("level_quit")

func _init_pause_menu():
	_paused = false
	pauseMenu.hide()
	pauseMenu.connect("quit_pressed", _on_quit_pressed)
	pauseMenu.connect("resume_pressed", _on_pause_pressed)

func _freeze_players():
	for player in get_tree().get_nodes_in_group("ActivePlayers"):
		player.freeze()

func _unfreeze_players():
	for player in get_tree().get_nodes_in_group("ActivePlayers"):
		player.unfreeze()

func _on_hazard_touched(player : CharacterBody2D):
	_playersToClear += 1
	if (_playersToClear == get_tree().get_nodes_in_group("ActivePlayers").size()):
		_do_reset = true
	player.die()

func _on_mirror_touched(sender : Sprite2D):
	for mirror in get_tree().get_nodes_in_group("Mirror"):
		mirror.shatter()
		if mirror != sender:
			var newSpawnPoint = mirror.get_global_position()
			print("New Spawn Point: ", newSpawnPoint)
			_spawn_player(newSpawnPoint, true)
