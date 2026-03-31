# basic_movement.gd
extends PlayerMechanic

@export var walk_speed = 5.0
@export var sprint_speed = 8.0
@export var crouch_speed = 2.5

func physics_update(_delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var current_speed = walk_speed
	
	# Lógica de agacharse
	if Input.is_action_pressed("crouch"):
		current_speed = crouch_speed
		player.collision_shape.scale.y = 0.6
	else:
		player.collision_shape.scale.y = 1.0
		# Lógica de correr
		if Input.is_action_pressed("sprint") and input_dir.y < 0:
			current_speed = sprint_speed

	# Aplicar velocidad al jugador
	if direction:
		player.velocity.x = direction.x * current_speed
		player.velocity.z = direction.z * current_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, current_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, current_speed)