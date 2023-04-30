extends Sprite2D

var right:bool = true
var dynamic:bool = true
var moved:bool = false
var layered:bool = false
var damage:int = 0
var damage_type_is_proportional:bool = true

func setup(right=true, dynamic=true, damage=0, damage_type_is_proportional=true):
	moved = false
	self.right = right
	self.dynamic = dynamic
	self.layered = false
	self.damage = damage
	self.damage_type_is_proportional = damage_type_is_proportional
	update()
	
func _to_string():
	return "right=" + str(right) + " moved=" + str(moved) + " dynamic=" + str(dynamic) + " layered=" + str(layered)

func update():
	if dynamic:
		if right:
			self_modulate = Color.RED
		else:
			self_modulate = Color.YELLOW
			
	else:
		self_modulate = Color.GREEN
	

# modifies player values
func deal_damage_to_player(player:Player):
	var damage_to_deal:int = 0
	
	if damage_type_is_proportional: #damage dealt is proportional to number of souls carried
		damage_to_deal = int(float(player.current_soul_count) / damage)
	else: #damage dealt is a fixed amount
		damage_to_deal = damage
	
	# deal damage to strength first
	var damage_left_to_deal = damage_to_deal
	damage_left_to_deal -= player.strength
	player.strength -= damage_to_deal
	if player.strength < 0:
		player.strength = 0
	
	# deal remaining damage to soul count
	player.current_soul_count -= damage_left_to_deal
	if player.current_soul_count < 0:
		player.current_soul_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
