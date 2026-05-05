extends Node2D

var passed_top := false
var already_scored := false

var poly := PackedVector2Array()

func get_mask_polygon() -> PackedVector2Array:
	var spr := $Hoop_back
	var tex = spr.sprite_frames.get_frame_texture(spr.animation, spr.frame)
	if tex == null:
		return PackedVector2Array()

	var size = tex.get_size()
	var center = global_position

	var p1 = center + Vector2(-size.x / 2.0, -size.y / 2.0)
	var p2 = center + Vector2( size.x / 2.0, -size.y / 2.0)
	var p3 = center + Vector2( size.x / 2.0,  size.y / 2.0)
	var p4 = center + Vector2(-size.x / 2.0,  size.y / 2.0)

	return PackedVector2Array([p1, p2, p3, p4])

func _ready():
	$ScoreTop.body_entered.connect(_on_score_top_body_entered)
	$ScoreBottom.body_entered.connect(_on_score_bottom_body_entered)
	
	poly = get_mask_polygon()
	PolyStore.set_polygon(get_instance_id(), poly, global_position, false)

func _on_score_top_body_entered(body):
	if body.name != "Ball":
		return
	if body.linear_velocity.y > 0.0:
		passed_top = true
		already_scored = false

func _on_score_bottom_body_entered(body):
	if body.name != "Ball":
		return
	if passed_top and not already_scored and body.linear_velocity.y > 0.0:
		already_scored = true
		passed_top = false
		print("SCORE")
		
