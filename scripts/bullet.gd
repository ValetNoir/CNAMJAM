extends Node3D

@onready var rigid_body_3d: RigidBody3D = $"."

const PLANT_AREA: PackedScene = preload("res://scenes/plant_area.tscn")

@export var speed: float = 10.0
# baies, fleurs, lianes, etc...
@export var element: String = "default"
var direction: Vector3

func _on_body_entered(body: Node) -> void:
	
	var is_ground: bool = body.get_collision_layer_value(1)
	
	if element == "default":
		# PAS DE ZONE, DEGATS SIMPLE SUR MOB
		pass
	else:
		# SPAWN ZONE, DEGATS (+ EFFETS, juste zone ?) SUR MOB
		spawn_zone()
	
	queue_free()
	if body is Player:
		body.hurted()

func spawn_zone() -> void:
	var plant_area = PLANT_AREA.instantiate()
	plant_area.element = element
	add_child(plant_area)
