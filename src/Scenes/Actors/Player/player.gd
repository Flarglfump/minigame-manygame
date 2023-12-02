extends CharacterBody2D

@export var WALK_SPEED := 300.0
@export var RUN_SPEED := 600.0
@export var JUMP_VELOCITY := -400.0
@export var CONTROLLABLE := true

@onready var animationPlayer = $SpriteBody/AnimationPlayer
@onready var sprite = $SpriteBody

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var _global_spawnpoint: Vector2


signal death_animation_finished
signal touched_hazard

# Initialize character
func initPlayer(globalSpawnpoint: Vector2) -> void:
	freeze()
	_global_spawnpoint = globalSpawnpoint
	set_global_position(_global_spawnpoint)
	animationPlayer.play("RESET")
	unfreeze()

func _physics_process(delta: float) -> void:
	# Do not move if player is uncontrollable
	if not CONTROLLABLE:
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle movement calculation and animation
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		# X input pressed -> Add to velocity
		if Input.is_action_pressed("run"):
			animationPlayer.play("Run")
			velocity.x = direction * RUN_SPEED
		else:
			animationPlayer.play("Walk")
			velocity.x = direction * WALK_SPEED
	else:
		# No X input pressed -> Slow to 0 at run speed rate
		velocity.x = move_toward(velocity.x, 0, RUN_SPEED)

	# Handle direction sprite is facing
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false

	# Stop animation if player stopped
	if velocity.x == 0:
		animationPlayer.play("RESET")
		animationPlayer.stop()

	# Handle movement physics interactions
	move_and_slide()

# Player dies
func die() -> void:
	print("Player kill function called for player")
	freeze()
	animationPlayer.play("Die")

func freeze() -> void:
	CONTROLLABLE = false

func unfreeze() -> void:
	CONTROLLABLE = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Die":
		emit_signal("death_animation_finished")

func _on_player_body_entered(body: Node2D) -> void:
	if body.is_in_group("Hazard"):
		emit_signal("touched_hazard")
