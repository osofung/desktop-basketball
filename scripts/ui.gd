extends Control

var ui_instances: Array[Control] = []

func _ready():
	pass

func unload_ui(ui_inst):
	if ui_inst in ui_instances:
		if is_instance_valid(ui_inst):
			PolyStore.remove_polygon(ui_inst)
			ui_inst.queue_free()
		ui_instances.erase(ui_inst)

func unload_ui_all():
	for ui_inst in ui_instances.duplicate():
		unload_ui(ui_inst)

func load_ui(ui_name: String):
	var path = "res://scenes/%s.tscn" % ui_name
	var resource = load(path)
	if resource:
		var instance = resource.instantiate()
		add_child(instance)
		ui_instances.append(instance)
