extends Node

signal polygons_changed

var polygons := {}
var polygon_static := PackedVector2Array()
var fullscreen := false

func set_polygon(id, poly: PackedVector2Array, center: Vector2, dynamic := false) -> void:
	polygons[id] = {
		"polygon": poly,
		"center": center,
		"dynamic": dynamic
	}
	polygons_changed.emit()

func remove_polygon(id) -> void:
	if polygons.has(id):
		polygons.erase(id)
		polygons_changed.emit()

func merge_polygons() -> PackedVector2Array:
	var usable_rect: Rect2i = DisplayServer.screen_get_usable_rect()
	var rect_pos := Vector2(usable_rect.position)
	var rect_size := Vector2(usable_rect.size)

	var left := rect_pos.x
	var right := rect_pos.x + rect_size.x
	var top := rect_pos.y
	var bottom := rect_pos.y + rect_size.y

	var base_poly := PackedVector2Array([
		Vector2(left, bottom),
		Vector2(left, top),
		Vector2(left + 1.0, top),
		Vector2(left + 1.0, bottom - 1.0),
		Vector2(right - 1.0, bottom - 1.0),
		Vector2(right - 1.0, top),
		Vector2(right, top),
		Vector2(right, bottom)
	])

	var merged := base_poly
	var bridge_half_width := 1.0

	for id in polygons:
		var entry = polygons[id]
		var poly: PackedVector2Array = entry["polygon"]
		var center: Vector2 = entry["center"]

		if poly.is_empty():
			continue

		var d_left = abs(center.x - left)
		var d_right = abs(right - center.x)
		var d_bottom = abs(bottom - center.y)

		var min_dist = min(d_left, d_right, d_bottom)
		var bridge: PackedVector2Array

		if min_dist == d_left:
			bridge = PackedVector2Array([
				Vector2(left, center.y - bridge_half_width),
				Vector2(center.x, center.y - bridge_half_width),
				Vector2(center.x, center.y + bridge_half_width),
				Vector2(left, center.y + bridge_half_width)
			])
		elif min_dist == d_right:
			bridge = PackedVector2Array([
				Vector2(center.x, center.y - bridge_half_width),
				Vector2(right, center.y - bridge_half_width),
				Vector2(right, center.y + bridge_half_width),
				Vector2(center.x, center.y + bridge_half_width)
			])
		else:
			bridge = PackedVector2Array([
				Vector2(center.x - bridge_half_width, center.y),
				Vector2(center.x + bridge_half_width, center.y),
				Vector2(center.x + bridge_half_width, bottom),
				Vector2(center.x - bridge_half_width, bottom)
			])

		var bridged_result = Geometry2D.merge_polygons(poly, bridge)
		if bridged_result.is_empty():
			continue

		var merge_result = Geometry2D.merge_polygons(merged, bridged_result[0])
		if not merge_result.is_empty():
			merged = merge_result[0]

	return merged
