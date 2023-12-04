extends Sprite2D

@onready var animationPlayer := $AnimationPlayer

var _broken: bool
var _overlapping_bodies: Array[Node2D]

signal mirror_touched

func _physics_process(_delta: float) -> void:
	for _body in _overlapping_bodies:
		if _body.is_in_group("Player"):
			var body_radius = _body.get_node("CollisionShape2D").shape.radius
			var body_height = _body.get_node("CollisionShape2D").shape.height
			var area_extents = $Area2D.get_node("CollisionShape2D").shape.extents
			var body_rect = Rect2(Vector2(_body.global_position.x - body_radius, _body.global_position.y - body_height/2), Vector2(body_radius * 2, body_height))
			var area_rect = Rect2($Area2D.global_position - area_extents, area_extents * 2)

			if area_rect.encloses(body_rect) and Input.is_action_pressed("move_up") and not _broken:
				print("Emitting Signal")
				emit_signal("mirror_touched")

func _on_area_2d_body_entered(body: Node2D) -> void:
	_overlapping_bodies.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	var i := _overlapping_bodies.find(body)
	if (i != -1):
		_overlapping_bodies.remove_at(i)

func mend() -> void:
	animationPlayer.play("RESET")
	_broken = false

func shatter() -> void:
	if not _broken:
		animationPlayer.play("Shatter")
	_broken = true

func initBrokenState(broken: bool) -> void:
	if (broken):
		_broken = true
		frame = 3
	else:
		_broken = false
		frame = 0
