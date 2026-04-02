class_name StateSprint
extends MovementState

@export var sprint_acceleration: float = 6.0

func physics_update(delta: float) -> void:
    if not player.is_on_floor():
        state_machine.transition_to(&"State_Air")
        return
        
    if player.current_input_dir == Vector2.ZERO:
        state_machine.transition_to(&"State_Idle")
        return
        
    if not Input.is_action_pressed("sprint"):
        state_machine.transition_to(&"State_Run")
        return
        
    if player.is_jumping:
        player.velocity.y = player.jump_velocity
        state_machine.transition_to(&"State_Air")
        return
        
    if player.is_sliding:
        state_machine.transition_to(&"State_Slide")
        return

    # Usar la función de movimiento, pero con las estadísticas de sprint
    var input_dir := player.current_input_dir
    var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    player.velocity.x = lerp(player.velocity.x, direction.x * player.speed_sprint, sprint_acceleration * delta)
    player.velocity.z = lerp(player.velocity.z, direction.z * player.speed_sprint, sprint_acceleration * delta)