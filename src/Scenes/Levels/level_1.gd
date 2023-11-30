extends Node2D
@onready var packedPlayer := preload("res://Scenes/Actors/Player/player.tscn")
@onready var spawnPoint1 = $SpawnMarker1.get_global_position()

var doCleanup

var players: Array[CharacterBody2D] # List of players active in level
var playersToClear: int
# Spawn player at initial spawnpoint
func _ready() -> void:
	_spawn_player(spawnPoint1)
	doCleanup = false
	playersToClear = 0

# Watch for reset or pause inputs
func _process(_delta: float) -> void:
	# Handle Reset Event
	if Input.is_action_just_pressed("reset"):
		_reset_level()

	# Handle Jump Event
	if Input.is_action_just_pressed("jump"):
		_spawn_player(spawnPoint1)

# Spawn player, initialize, and append to player list
func _spawn_player(globalSpawnpoint: Vector2) -> void:
	var newPlayer := packedPlayer.instantiate()
	self.add_child(newPlayer)
	newPlayer.initPlayer(globalSpawnpoint, players.size())

	players.append(newPlayer)

# Kill player and remove node from players list
func _kill_player(id: int) -> void:
	players[id].die()
	print("Awaiting death")
	await players[id].animationPlayer.animation_finished
	print ("Death finished")
	await get_tree().create_timer(0.5).timeout

# Reset ids of players in player list
func _reset_player_ids() -> void:
	var i: = 0
	for player in players:
		player.setID(i)
		i += 1

# Kill all players
func _kill_all_players() -> void:
	var i := players.size() - 1
	while i >= 0:
		players[i].die()
		if i == 0:
			await players[i].animationPlayer.animation_finished
		i -= 1
	await get_tree().create_timer(0.5).timeout
	for player in players:
		player.queue_free()
	players.clear()

# Reset level
func _reset_level() -> void:
	await _kill_all_players()
	_spawn_player(spawnPoint1)
