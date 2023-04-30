extends CanvasLayer

@onready var coin_label = $Top/Coins
var coins = 0

@onready var player = $"../Player"
@onready var options = $UpgradeOptions
@onready var Stat = player.Stat

class Option:
	var cost
	var button
	var stat
	var shop
	
	func _init(button, stat, shop):
		self.button = button
		self.stat = stat
		self.shop = shop
		self.cost = 1
		button.pressed.connect(buy)
	
	func can_buy():
		print("button=", button)
		print("shop=", shop)
		print("cost=", cost)
		button.disabled = shop.coins < cost
		print("disabled=", button.disabled)
	
	func buy():
		shop.delta_coins(-cost)
		cost *= 2
		stat.capacity += 1
		shop.update_shop()

func _on_open_shop():
#	print("pressed")
	options.visible = !options.visible
	update_shop()
	
var strength_option
var speed_option
var souls_option

var options_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
#	delta_coins(1)
	options.visible = false
	delta_coins(100)
	$Top/OpenShop.pressed.connect(_on_open_shop)
	strength_option = Option.new($UpgradeOptions/Strength, player.strength, self)
	speed_option = Option.new($UpgradeOptions/Speed, player.speed, self)
	souls_option = Option.new($UpgradeOptions/Souls, player.souls, self)
	options_list = [strength_option, speed_option, souls_option]
	
	
	pass # Replace with function body.

func delta_coins(value:int):
	coins += value
	coin_label.text = "Coins: " + str(coins)

func update_shop():
	for option in options_list:
		option.can_buy()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
