extends Node2D

var player_init = {}
var p_name = "Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	$PlayerBoat/Turret1.connect("spawn_projectile", self, "_spawn_projectile")
	$PlayerBoat/Turret2.connect("spawn_projectile", self, "_spawn_projectile")
	$PlayerBoat/Turret3.connect("spawn_projectile", self, "_spawn_projectile")

func initialize():
	p_name = player_init.name
	$PlayerBoat.position.x = player_init.position.x
	$PlayerBoat.position.y = player_init.position.y

func _spawn_projectile(projectile, _position, _direction):
	var proj = projectile.instance()
	add_child(proj)
	proj.start(_position, _direction)

func _physics_process(delta):
	print($PlayerBoat.position.x)
	var packet = {
		'mouse_pos': get_global_mouse_position(),
		'position': {
			'x': $PlayerBoat.position.x,
			'y': $PlayerBoat.position.y
		},
		'rotation': $PlayerBoat.rotation,
		'acceleration': $PlayerBoat.acceleration,
		'velocity': $PlayerBoat.velocity
	}
	rpc_unreliable_id(1, "update_position", packet)