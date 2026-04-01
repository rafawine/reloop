# low_gravity_jump.gd
extends PlayerMechanic

@export var high_jump_force = 12.0
@export var low_gravity_multiplier = 0.4
@export var duration = 6.0 # Duración de la mecánica

func _ready() -> void:
	super._ready() # Llama al _ready del padre si lo necesitas
	# Inicia un temporizador nativo que destruirá este nodo en 6 segundos
	get_tree().create_timer(duration).timeout.connect(_on_timeout)

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity += (player.get_gravity() * low_gravity_multiplier * -1) * delta

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.velocity.y = high_jump_force

func _on_timeout() -> void:
	print("Se acabó el efecto de gravedad baja.")
	queue_free() # Se destruye a sí mismo. (El player.gd lo detectará automáticamente)