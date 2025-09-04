extends Node3D

var pv = 100
var max_pv = 100

func _ready():
	max_pv = pv
	update_pv_ui()

func update_pv_ui():
	$CanvasLayer/Label.text = "vie : " + str(pv)

func player_hurted():
	pv -= 25
	update_pv_ui()
	if pv <= 0:
		print('game over')
