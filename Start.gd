extends Button

var main_scene:Node

func _pressed():
	get_tree().change_scene_to_file("res://main.tscn")
