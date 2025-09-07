extends Area3D

const PLANT_AREA: PackedScene = preload("res://scenes/plant_area.tscn")
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var timer: Timer = $Timer

@export_group("Models")
@export var epine_mesh: Mesh
@export var lierre_mesh: Mesh
@export var ronce_mesh: Mesh

# baies, fleurs, lianes, etc...
var element: String = "default"



func _on_area_entered(area: Area3D) -> void:
	var is_plant: bool = area.get_collision_layer_value(4)
	
	# Fusion
	if is_plant:
		var fusion = get_fusion(element, area.element)
		if fusion != "default":
			var plant_area = PLANT_AREA.instantiate()
			plant_area.element = fusion
			get_tree().root.add_child(plant_area)
			plant_area.global_position = (global_position + area.global_position) / 2
			
			area.queue_free()
			queue_free()

func get_fusion(element1: String, element2: String) -> String:
	var elements = [element1, element2]
	if elements.has("epine") && elements.has("lierre") : return "ronce"
	return "default"

func get_mesh(element: String) -> Mesh:
	match element:
		"lierre": return lierre_mesh
		"epine": return epine_mesh
		"ronce": return ronce_mesh
		_: return preload("res://models/new_cylinder_mesh.tres")
		
func _on_ready() -> void:
	# Set color depending on type
	var mesh : Mesh = get_mesh(element)
	mesh_instance_3d.set_mesh(mesh)


func _on_timer_timeout() -> void:
	queue_free()
