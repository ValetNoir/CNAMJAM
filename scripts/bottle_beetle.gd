extends RigidBody3D
class_name Mob


@onready var hitbox: Area3D = $Hitbox
@onready var damage_cooldown: Timer = $TimerDealDamage

var player_in_zone: Player = null

var pv = 100
var max_pv = 100


func _ready():
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.body_exited.connect(_on_hitbox_body_exited)
	damage_cooldown.timeout.connect(_on_damage_cooldown_timeout)
	max_pv = pv

func _on_hitbox_body_entered(body: Node) -> void:
	if body is Player:
		player_in_zone = body # Ne faire des dégâts seulement si le joueur est dans la zone
		if damage_cooldown.is_stopped(): # Ne faire des dégâts que si le timer est arrêté
			_deal_damage()

func _on_hitbox_body_exited(body: Node) -> void:
	if body == player_in_zone:
		player_in_zone = null

func _on_damage_cooldown_timeout() -> void:
	# Relancer les dégâts seulement si le joueur est toujours dans la zone
	if player_in_zone:
		_deal_damage()

func _deal_damage():
	if player_in_zone:
		$"bottle beetle/AnimationPlayer".play("DashAttack")
		player_in_zone.hurted()
		damage_cooldown.start()

func hurted(element: String):
	if element == "epine":
		pv -= 5
		print("-5")
	elif element == "lierre":
		pv -= 10
		print("-10")
	elif element == "ronce":
		pv -= 15
		print("-15")
	if pv <= 0:
		queue_free()
