# player.gd
extends CharacterBody3D
class_name Player

@export_group("Cámara y Visión")
@export var sensitivity = 0.003
@export var cam_lerp_speed = 12.0 # Qué tan rápido transiciona la cámara

# Valores objetivo para los diferentes estados
@export var normal_fov = 75.0
@export var aim_fov = 50.0 # Más bajo = más zoom
@export var normal_spring_length = 3.0
@export var aim_spring_length = 1.2 # Se acerca al hombro al apuntar
@export var normal_pivot_y = 1.0
@export var crouch_pivot_y = 0.5 # Baja la cámara al agacharse

@onready var camera_pivot = $CameraPivot
@onready var spring_arm = $CameraPivot/SpringArm3D
@onready var camera = $CameraPivot/SpringArm3D/Camera3D
@onready var collision_shape = $CollisionShape3D
@onready var inventory = $Inventory
@onready var interact_raycast = $CameraPivot/SpringArm3D/Camera3D/RayCast3D

# Lista dinámica de mecánicas
var mechanics: Array[PlayerMechanic] = []

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_mechanics_list()
	child_entered_tree.connect(_on_child_changed)
	child_exiting_tree.connect(_on_child_changed)

# Esta función actualiza la lista de mecánicas (útil si agregas o quitas una en medio del juego)
func update_mechanics_list() -> void:
	mechanics.clear()
	for child in get_children():
		# Reemplazamos el 'is PlayerMechanic' por 'has_method'
		if child.has_method("physics_update"):
			mechanics.append(child)

func _on_child_changed(_node: Node) -> void:
	call_deferred("update_mechanics_list")

# NUEVO: Usamos _process (ligado a los FPS visuales) para mover la cámara súper suave
func _process(delta: float) -> void:
	handle_camera_states(delta)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	for mechanic in mechanics:
		# ¡LA SOLUCIÓN! Verificamos si el nodo sigue existiendo en memoria
		if is_instance_valid(mechanic) and mechanic.is_active:
			mechanic.physics_update(delta)

	move_and_slide()

# NUEVA FUNCIÓN: Lógica fluida de la cámara
func handle_camera_states(delta: float) -> void:
	# 1. Leer los inputs actuales
	var is_aiming = Input.is_action_pressed("aim")
	var is_crouching = Input.is_action_pressed("crouch")
	
	# 2. Definir cuáles son nuestras metas según los botones presionados
	var target_fov = aim_fov if is_aiming else normal_fov
	var target_length = aim_spring_length if is_aiming else normal_spring_length
	var target_pivot_y = crouch_pivot_y if is_crouching else normal_pivot_y
	
	# 3. Aplicar interpolación (lerp) para moverse suavemente hacia la meta
	camera.fov = lerp(camera.fov, target_fov, delta * cam_lerp_speed)
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_length, delta * cam_lerp_speed)
	camera_pivot.position.y = lerp(camera_pivot.position.y, target_pivot_y, delta * cam_lerp_speed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera_pivot.rotate_x(-event.relative.y * sensitivity)
		# Limitar para no romper el cuello mirando muy arriba o muy abajo
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-70), deg_to_rad(80))
	
	# 1. Seleccionar Slots (Equipar)
	if event.is_action_pressed("slot_1"): inventory.select_slot(0)
	if event.is_action_pressed("slot_2"): inventory.select_slot(1)
	if event.is_action_pressed("slot_3"): inventory.select_slot(2)
	if event.is_action_pressed("slot_4"): inventory.select_slot(3)
	if event.is_action_pressed("slot_5"): inventory.select_slot(4)

	# NUEVO: Botón para recoger objetos
	if event.is_action_pressed("interact"):
		# Verificamos si el rayo está tocando algo
		print("Presione interact")		
		if interact_raycast.is_colliding():
			print("Tocando")
			var target = interact_raycast.get_collider()
			# Verificamos si lo que toca es de la clase PickupItem que creamos
			print("Tocando: ", target)
			if target is PickupItem:
				print("Es un PickupItem")
				target.interact(self)
	
	# 2. Usar el ítem activo
	if event.is_action_pressed("fire"):
		# Comprobamos si el jugador está manteniendo presionado el botón de apuntar
		var is_aiming = Input.is_action_pressed("aim")
		
		# Le pasamos el jugador y el estado de apuntado al inventario
		inventory.execute_active_item(self, is_aiming)
	
	for mechanic in mechanics:
		# Aquí también aplicamos la misma protección
		if is_instance_valid(mechanic) and mechanic.is_active:
			mechanic.handle_input(event)
