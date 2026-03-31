# player.gd
extends CharacterBody3D
class_name Player

@export_group("Cámara")
@export var sensitivity = 0.003

@onready var camera_pivot = $CameraPivot
@onready var collision_shape = $CollisionShape3D

# Lista dinámica de mecánicas
var mechanics: Array[PlayerMechanic] = []

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_mechanics_list()

# Esta función actualiza la lista de mecánicas (útil si agregas o quitas una en medio del juego)
func update_mechanics_list() -> void:
	mechanics.clear()
	for child in get_children():
		if child is PlayerMechanic:
			mechanics.append(child)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	for mechanic in mechanics:
		# ¡LA SOLUCIÓN! Verificamos si el nodo sigue existiendo en memoria
		if is_instance_valid(mechanic) and mechanic.is_active:
			mechanic.physics_update(delta)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera_pivot.rotate_x(-event.relative.y * sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	for mechanic in mechanics:
		# Aquí también aplicamos la misma protección
		if is_instance_valid(mechanic) and mechanic.is_active:
			mechanic.handle_input(event)