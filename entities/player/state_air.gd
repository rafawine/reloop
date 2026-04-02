class_name StateAir
extends MovementState

@export var air_control: float = 2.0 # Menor control en el aire que en el suelo

func physics_update(delta: float) -> void:
    if player.is_on_floor():
        if player.current_input_dir != Vector2.ZERO:
            state_machine.transition_to(&"State_Run")
        else:
            state_machine.transition_to(&"State_Idle")
        return
        
    # Lógica de Air Strafing (Control en el aire)
    var input_dir := player.current_input_dir
    if input_dir != Vector2.ZERO:
        var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
        # Modificamos la velocidad pero con un 'lerp' mucho más lento (air_control)
        player.velocity.x = lerp(player.velocity.x, direction.x * player.speed_walk, air_control * delta)
        player.velocity.z = lerp(player.velocity.z, direction.z * player.speed_walk, air_control * delta)