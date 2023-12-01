extends Node2D
@onready var packedPlayer := preload("res://Scenes/Actors/Player/player.tscn")
@onready var spawnPoint1 = $SpawnMarker1.get_global_position()
@onready var endDoor := $EndDoor

var _playersToClear : int
var _do_reset : bool

signal level_complete

# Spawn player at initial spawnpoint
func _ready() -> void:
	endDoor.connect("door_entered", _on_end_door_entered)
	init_level()
	
# Watch for reset or pause inputs
func _process(_delta: float) -> void:
	# Handle Reset Event
	if Input.is_action_just_pressed("reset"):
		_on_reset_pressed()

	# Handle Jump Event
	if Input.is_action_just_pressed("jump"):
		_spawn_player(spawnPoint1)

# Spawn player, initialize, and append to player list
func _spawn_player(globalSpawnpoint: Vector2) -> void:
	var newPlayer := packedPlayer.instantiate()
	self.add_child(newPlayer)
	newPlayer.initPlayer(globalSpawnpoint)
	newPlayer.add_to_group("ActivePlayers")
	newPlayer.connect("death_animation_finished", _on_player_death_animation_finished.bind(newPlayer))

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
