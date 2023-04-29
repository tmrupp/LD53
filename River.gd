extends Node2D

var spacing = 128.0
var map = []

var map_size = Vector2i(10, 10)

var sprite = preload("res://lil_guy.tscn")
@onready var main = $".."
var dynamic = preload("res://dynamic.tscn")
var stationary = preload("res://stationary.tscn")

var dynamics = {}
var stationaries = {}
var player_position = Vector2i.ZERO

func create(pos, obj):
	var instance = obj.instantiate()
	add_child(instance)
	instance.position = pos * spacing
	return instance

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
		
	# assuming a square rn
	spacing = sprite.instantiate().texture.get_width()
#	print(spacing)
	for x in range(map_size.x):
		for y in range(map_size.y):
			var v = Vector2i(x, y)
			create(v, sprite)
			
			if randi() % 20 == 0:
				dynamics[v] = create(v, dynamic)
				dynamics[v].right = randi() % 2 == 0
			elif randi() % 20 == 1:
				stationaries[v] = create(v, stationary)
	pass # Replace with function body.

var down = Vector2i(0, -1) # ???

func _input(event):
	if event.is_action_pressed("next_turn"):
		for pos in dynamics.keys():
			var new_pos = pos + down
			if stationaries.has(new_pos):
				new_pos = pos + (Vector2i(1, 0) if dynamics[pos].right else Vector2i(-1, 0))
				if stationaries.has(new_pos):
					new_pos = pos
			
			dynamics[new_pos] = dynamics[pos]
			dynamics.erase(pos)
			dynamics[new_pos].position = spacing * new_pos
				
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
