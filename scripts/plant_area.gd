extends Area3D

const PLANT_AREA: PackedScene = preload("res://scenes/plant_area.tscn")
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var timer: Timer = $TimerDespawn
@onready var damage_cooldown: Timer = $TimerDealDamage

@export_group("Models")
@export var epine_mesh: Mesh
@export var lierre_mesh: Mesh
@export var ronce_mesh: Mesh

# baies, fleurs, lianes, etc...
var element: String = "default"

var should_handle = true

var mob_in_zone: Mob = null


func _on_area_entered(area: Area3D) -> void:
	if not should_handle : return
	
	var is_plant: bool = area.get_collision_layer_value(4)
	
	# Fusion
	if is_plant:
		var fusion = get_fusion(element, area.element)
		if fusion != "default":
			area.should_handle = false
			var plant_area = PLANT_AREA.instantiate()
			plant_area.element = fusion
			get_tree().root.add_child(plant_area)
			plant_area.global_position = (global_position + area.global_position) / 2
			
			area.queue_free()
			queue_free()

func get_fusion(element1: String, element2: String) -> String:
	var elements = [element1, element2]
	if elements.has("lierre") && elements.has("epine") : return "ronce"
	if elements.has("lierre") && elements.has("champignon") : return "mycellium"
	if elements.has("lierre") && elements.has("baie") : return "ortie"
	if elements.has("lierre") && elements.has("fleur") : return ""
	if elements.has("epine") && elements.has("champignon") : return "oursin"
	if elements.has("epine") && elements.has("baie") : return "houx"
	if elements.has("epine") && elements.has("fleur") : return "carnivore"
	if elements.has("champignon") && elements.has("baie") : return "moisissure"
	if elements.has("champignon") && elements.has("fleur") : return ""
	if elements.has("baie") && elements.has("fleur") : return "fraisier"
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



func _on_hitbox_body_entered(body: Node) -> void:
	if body is Mob:
		mob_in_zone = body
		if damage_cooldown.is_stopped(): # Ne faire des dégâts que si le timer est arrêté
			_deal_damage()

func _on_hitbox_body_exited(body: Node3D) -> void:
	if body == mob_in_zone:
		mob_in_zone = null

func _on_damage_cooldown_timeout() -> void:
	if mob_in_zone:
		_deal_damage()

func _deal_damage():
	if mob_in_zone:
		mob_in_zone.hurted()
		damage_cooldown.start()
