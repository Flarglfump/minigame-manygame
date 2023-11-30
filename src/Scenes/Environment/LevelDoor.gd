extends Sprite2D

var _body_overlapping: bool
var _body: Node2D

var locked: bool

func _ready() -> void:
	lock()
	_body_overlapping = false

func _physics_process(_delta: float) -> void:
	if _body_overlapping and _body.is_in_group("Player"):
		print("Body Overlapping Door!")
		var body_radius = _body.get_node("CollisionShape2D").shape.radius
		var body_height = _body.get_node("CollisionShape2D").shape.height
		var area_extents = $Area2D.get_node("CollisionShape2D").shape.extents
		var body_rect = Rect2(Vector2(_body.global_position.x - body_radius, _body.global_position.y - body_height/2), Vector2(body_radius * 2, body_height))
		var area_rect = Rect2($Area2D.global_position - area_extents, area_extents * 2)
		if area_rect.encloses(body_rect):
			print("Player is fully inside door area!")
		else:
			print("Player is not fully inside door area!")

func _on_area_2d_body_entered(body: Node2D) -> void:
	_body_overlapping = true
	_body = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	_body_overlapping = false
	_body = body

func lock():
	locked = true
	frame = 1

func unlock():
	locked = false
	frame = 0
