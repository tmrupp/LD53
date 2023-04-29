extends Sprite2D

var right:bool = true
var dynamic:bool = true
var moved:bool = false

func setup(right=true, dynamic=true):
	moved = false
	self.right = right
	self.dynamic = dynamic
	
	if dynamic:
		self_modulate = Color.RED
	else:
		self_modulate = Color.GREEN

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
