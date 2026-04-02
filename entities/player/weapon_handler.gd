class_name WeaponHandlerComponent
extends Node

## Componente modular que gestiona la lógica de disparo, recarga y dispersión.

@export var current_weapon: WeaponData # Recurso definido en la Fase 1
@export var camera_rig: CameraRig # Referencia inyectada para obtener la dirección

# Variables de estado interno
var can_shoot: bool = true
var current_ammo: int = 0
var current_spread: float = 0.0
var time_since_last_shot: float = 0.0

@onready var player: CharacterBody3D = owner # Asume que el nodo raíz es el jugador

func _ready() -> void:
    if current_weapon:
        current_ammo = current_weapon.max_ammo
        current_spread = current_weapon.base_spread

func _physics_process(delta: float) -> void:
    _handle_spread_decay(delta)
    time_since_last_shot += delta
    
    # Lógica de disparo (En red, esto se procesa tras recibir el Input del cliente)
    if Input.is_action_pressed("shoot") and can_shoot and current_ammo > 0:
        if time_since_last_shot >= current_weapon.fire_rate:
            _fire_weapon()

func _handle_spread_decay(delta: float) -> void:
    if not current_weapon: return
    # Si no estamos disparando, el spread se reduce hacia la base
    if time_since_last_shot > current_weapon.fire_rate:
        current_spread = lerpf(current_spread, current_weapon.base_spread, 5.0 * delta)

func _fire_weapon() -> void:
    time_since_last_shot = 0.0
    current_ammo -= 1
    
    # Aumentar la dispersión por el retroceso
    current_spread = min(current_spread + current_weapon.recoil_kick.x, current_weapon.base_spread * 3.0)
    
    # Emitir señal al HUD (Desacoplado)
    # EventBus.player_ammo_updated.emit(current_ammo, reserve_ammo)
    
    _perform_hitscan()

func _perform_hitscan() -> void:
    # 1. Obtener el estado del espacio físico directamente del mundo 3D
    var space_state := player.get_world_3d().direct_space_state
    
    # 2. Calcular origen y dirección desde la cámara
    var camera := camera_rig.camera
    var viewport_center := get_viewport().get_visible_rect().size / 2.0
    
    var origin := camera.project_ray_origin(viewport_center)
    var base_direction := camera.project_ray_normal(viewport_center)
    
    # 3. Aplicar matemática de dispersión (simplificada para GDScript)
    var random_deviation := Vector3(
        randf_range(-current_spread, current_spread),
        randf_range(-current_spread, current_spread),
        randf_range(-current_spread, current_spread)
    ) * 0.01 # Factor de escala para mantener el ángulo pequeño
    
    var final_direction := (base_direction + random_deviation).normalized()
    var target_end := origin + (final_direction * 200.0) # Rango máximo del arma
    
    # 4. Configurar la consulta del Rayo (Query)
    var query := PhysicsRayQueryParameters3D.create(origin, target_end)
    query.exclude = [player.get_rid()] # Ignorar al propio jugador
    query.collision_mask = 4 # Asumiendo que la Capa 3 (Valor de bit 4) es la capa de Hitboxes

	# ¡ESTA LÍNEA ES OBLIGATORIA PARA QUE DETECTE NUESTROS HitboxComponent!
    query.collide_with_areas = true
    query.collide_with_bodies = false # Optimización: Ignorar la cápsula de movimiento por completo
    
    # 5. Ejecutar la intersección en el hilo de físicas
    var result := space_state.intersect_ray(query)
    
    if result:
        _handle_hit(result)

func _handle_hit(result: Dictionary) -> void:
    var collider = result.collider
    var hit_point: Vector3 = result.position
    var hit_normal: Vector3 = result.normal
    
    # Si el objeto golpeado tiene un componente de salud (Duck Typing)
    if collider.has_method("take_damage"):
        collider.take_damage(current_weapon.base_damage)
        
    # Aquí solicitaríamos al EventBus o a un Gestor de Efectos instanciar un impacto de bala en hit_point