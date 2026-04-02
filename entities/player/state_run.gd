class_name StateRun
extends MovementState

@export var acceleration: float = 8.0

func physics_update(delta: float) -> void:
    if not player.is_on_floor():
        state_machine.transition_to(&"State_Air")
        return
        
    if player.current_input_dir == Vector2.ZERO:
        state_machine.transition_to(&"State_Idle")
        return
        
    if player.is_jumping:
        player.velocity.y = player.jump_velocity
        state_machine.transition_to(&"State_Air")
        return
        
    if Input.is_action_pressed("sprint"): # Podría leerse del player.is_sprinting si lo agregas
        state_machine.transition_to(&"State_Sprint")
        return

    _apply_movement(player.speed_walk, acceleration, delta)

func _apply_movement(target_speed: float, accel: float, delta: float) -> void:
    # Convertir input 2D a dirección 3D basada en la rotación de la cámara/visual
    var input_dir := player.current_input_dir
    var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    player.velocity.x = lerp(player.velocity.x, direction.x * target_speed, accel * delta)
    player.velocity.z = lerp(player.velocity.z, direction.z * target_speed, accel * delta)