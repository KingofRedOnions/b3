extends Node2D

var proj = preload("res://Projectile.tscn")
var boat = preload("res://RealPlayer.tscn")

var player_name = "Player"
var boat_selected = "0"

var EProj = preload("res://RCFloatProjectile.tscn")

var proj_tick = 0

export var score = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

remote func _spawn_projectile(projectile_type, _position, _direction):
	
	var player_id = get_tree().get_rpc_sender_id()
	
	rpc_unreliable("_spawn_projectile", projectile_type, _position, _direction, player_id)

remote func _spawn_controlled_projectile(projectile_type, _position, _direction):
	
	var player_id = get_tree().get_rpc_sender_id()
	
	var proj = EProj.instance()
	proj.p_owner = player_id
	proj.name = str(proj_tick)
	proj_tick += 1
	proj.start()
	add_child(proj)
	
	rpc_unreliable("_spawn_controlled_projectile", proj.name, projectile_type, _position, _direction, player_id)

remote func update_position(packet):
	if ($PlayerBoat):
		$PlayerBoat.position.x = packet.position.x
		$PlayerBoat.position.y = packet.position.y
		$PlayerBoat.rotation = packet.rotation
		$PlayerBoat.acceleration = packet.acceleration
		$PlayerBoat.velocity = packet.velocity
		$PlayerBoat.mouse_pos = packet.mouse_pos

	var player_id = get_tree().get_rpc_sender_id()
	for player in get_node("..").players:
		if (player_id != player):
			rpc_unreliable_id(player, "set_position", packet)

remote func update_health(hp, p_owner):
	var current_health = 0
	var temp_score = 0
	if $PlayerBoat:
		current_health = $PlayerBoat.hp
	var player_id = get_tree().get_rpc_sender_id()
	print(hp)
#	if hp == null:
#		hp = 0
	if $PlayerBoat:
		$PlayerBoat.hp = hp
	if (hp > 0):
		rpc_unreliable("update_health", hp)
	elif has_node('PlayerBoat'):
		for player in get_node("..").players:
			rpc_unreliable("destroy")
		if current_health > 0:
			print(current_health, "current health")
			get_node("..").set_score(p_owner)
		$PlayerBoat.queue_free()
			
		temp_score += get_parent().leaderboard[player_id]['score']
		if current_health > 0:
			print("score was prior to update", temp_score)
			print (get_parent().leaderboard[player_id]['score'])
			if temp_score > 0:
				get_parent().leaderboard[player_id]['score'] = round(temp_score / 2)
				print (get_parent().leaderboard[player_id]['score'], " after score minus 1!!!")
		get_parent().render_leaderboard()

func send_leaderboard_info(p_owner):
	rpc_unreliable_id(int(get_node(".").name), "update_leaderboard", p_owner)

remote func update_ship_type(ship_type):
	var player_id = get_tree().get_rpc_sender_id()
	boat_selected = ship_type
	get_node("..").players[player_id].ship_type = ship_type

remote func respawn():
	var x = 0
	var y = 0
	var available_spawns = []
	for point in get_parent().get_node("Map01").get_node("Spawns").get_children():
		if point.available:
			available_spawns.append(point.position)
	var spawn = available_spawns[int(rand_range(0,(available_spawns.size())-1))]
	var rotation = 0
	var new_boat = boat.instance()
	new_boat.position.x = x
	new_boat.position.y = y
	new_boat.rotation = rotation
	add_child(new_boat)
	rpc_unreliable("respawn_player", spawn.x, spawn.y, rotation, boat_selected)



















