extends Node2D

var spacing = 128.0
var map = []

var map_size = Vector2i(10,10)

var sprite = preload("res://lil_guy.tscn")
@onready var main = $".."
var dynamic = preload("res://dynamic.tscn")
var static_guy = preload("res://static.tscn")
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# assuming a square rn
	spacing = sprite.instantiate().texture.get_width()
#	print(spacing)
	for x in range(map_size.x):
		for y in range(map_size.y):
			var instance = sprite.instantiate()
			add_child(instance)
			instance.position = Vector2(x, y) * spacing
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("next_turn"):
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
