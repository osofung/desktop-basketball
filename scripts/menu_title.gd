extends Control

@onready var container = $MarginContainer


func get_mask_polygon() -> PackedVector2Array:
	var p1 = position + Vector2(container.size.x, container.size.y)
	var p2 = position + Vector2(container.size.x, 0)
	var p3 = position + Vector2(0, 0)
	var p4 = position + Vector2(0, container.size.y)

	return PackedVector2Array([p1, p2, p3, p4])

func _ready():
	var poly = get_mask_polygon()
	PolyStore.set_polygon(get_instance_id(), poly, global_position, false)
