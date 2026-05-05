extends StaticBody2D

@onready var top_wall: CollisionShape2D = get_node_or_null("Top")
@onready var bottom_wall: CollisionShape2D = get_node_or_null("Bottom")
@onready var left_wall: CollisionShape2D = get_node_or_null("Left")
@onready var right_wall: CollisionShape2D = get_node_or_null("Right")

var wall_thickness := 500.0

func _ready():
	if not top_wall or not bottom_wall or not left_wall or not right_wall:
		push_error("One or more wall CollisionShape2D nodes were not found.")
		return

	var usable_rect = DisplayServer.screen_get_usable_rect()
	var s: Vector2 = Vector2(usable_rect.size)
	var t: float = wall_thickness

	_make_wall(top_wall, Vector2(s.x + t*2, t))
	_make_wall(bottom_wall, Vector2(s.x + t*2, t))
	_make_wall(left_wall, Vector2(t, s.y + t*2))
	_make_wall(right_wall, Vector2(t, s.y + t*2))

	top_wall.position = Vector2(s.x / 2.0, -t / 2.0)
	bottom_wall.position = Vector2(s.x / 2.0, s.y + t / 2.0)
	left_wall.position = Vector2(-t / 2.0, s.y / 2.0)
	right_wall.position = Vector2(s.x + t / 2.0, s.y / 2.0)

func _make_wall(collision_shape: CollisionShape2D, rect_size: Vector2) -> void:
	var rect := RectangleShape2D.new()
	rect.size = rect_size
	collision_shape.shape = rect
