extends Node2D

var player_ship = preload("res://Player.tscn")
var npc_ship = preload("res://NPC.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Announce ready to spawn here.
	rpc_id(1, "spawn_for")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

remote func spawn_player(p_info):
	if (p_info.id == get_tree().get_network_unique_id()):
		var ship = player_ship.instance()
		ship.name = str(get_tree().get_network_unique_id())
		ship.player_init = p_info
		ship.initialize()
		self.add_child(ship)
	else:
		var ship = npc_ship.instance()
		ship.name = str(p_info.id)
		ship.player_init = p_info
		ship.initialize()
		self.add_child(ship)