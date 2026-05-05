extends Node2D

@onready var ui : Control = $UILayer/UI

enum GameState { MAIN_MENU, GAMEPLAY, OPTIONS, PAUSE, GAME_OVER }
var current_state: GameState

@export var debug_poly_enable := false
var debug_poly := PackedVector2Array()

func gamestate_ready():
	match current_state:
		GameState.MAIN_MENU:
			ui.unload_ui_all()
			ui.load_ui("menu/menu_title")

func gamestate_set(state: GameState):
	current_state = state
	gamestate_ready()

func _ready() -> void:
	var window = get_window()

	get_viewport().transparent_bg = true
	window.transparent = true

	window.borderless = true
	window.always_on_top = true
	window.unresizable = false

	var usable_rect = DisplayServer.screen_get_usable_rect()
	window.size = usable_rect.size
	window.position = usable_rect.position
	
	gamestate_set(GameState.MAIN_MENU)
	
	_update_mouse_mask()
	queue_redraw()

func _process(_delta: float) -> void:
	_update_mouse_mask()
	queue_redraw()

func _update_mouse_mask():
	var poly = PackedVector2Array()
	var window = get_window()
	if !PolyStore.fullscreen:
		poly = PolyStore.merge_polygons()
		window.mouse_passthrough_polygon = poly
	else:
		window.mouse_passthrough_polygon = PackedVector2Array()
		
	if debug_poly_enable:
		debug_poly = poly

func _draw():
	if debug_poly.size() >= 3:
		draw_colored_polygon(debug_poly, Color(1.0, 0.0, 0.0, 0.18))

		var outline := PackedVector2Array(debug_poly)
		outline.append(debug_poly[0])
		draw_polyline(outline, Color(1.0, 0.25, 0.25, 1.0), 3.0)
