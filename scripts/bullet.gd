extends Node3D

@onready var rigid_body_3d: RigidBody3D = $"."

const PLANT_AREA: PackedScene = preload("res://scenes/plant_area.tscn")

# baies, fleurs, lianes, etc...
@export var element: String = "default"

func _on_body_entered(body: Node) -> void:
	
	var is_ground: bool = body.get_collision_layer_value(1)
	
	print_debug(global_position)
	
	if element == "default":
		# PAS DE ZONE, DEGATS SIMPLE SUR MOB
		pass
	else:
		# SPAWN ZONE, DEGATS (+ EFFETS, juste zone ?) SUR MOB
		spawn_zone()
	
	queue_free()

func spawn_zone() -> void:
	var plant_area = PLANT_AREA.instantiate()
	plant_area.element = element
	get_tree().root.add_child(plant_area)
	plant_area.global_position = global_position
