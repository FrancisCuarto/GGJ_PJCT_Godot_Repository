extends Node

var estado :bool= false
var escena_auto

# Called when the node enters the scene tree for the first time.


func ejecutarEstacionamiento():
	estado = true
	var main_packed = get_node("res://main.tscn")
	var escena_main = get_tree().change_scene_to_packed(main_packed)
	escena_main
	
	print ("ejecutandose desde global est")   
	
func resetEstado():
	estado = false 
	print("estado reset")
	
	
