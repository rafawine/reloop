class_name HealthComponent
extends Node

## Componente modular que gestiona la vida, el escudo y la lógica de muerte.

@export_category("Estadísticas Base")
@export var max_health: float = 100.0
@export var max_shield: float = 100.0

var current_health: float
var current_shield: float
var is_dead: bool = false

@onready var entity: Node3D = owner # La entidad a la que pertenece este componente

func _ready() -> void:
    current_health = max_health
    current_shield = 0.0 # El jugador suele aparecer sin escudo, debe lootearlo

func apply_damage(amount: float, hit_part: HitboxComponent.BodyPart = HitboxComponent.BodyPart.TORSO) -> void:
    if is_dead: return
    
    # 1. Aplicar daño al escudo primero
    var shield_damage: float = min(current_shield, amount)
    current_shield -= shield_damage
    
    # 2. Calcular el desbordamiento (daño restante)
    var health_damage: float = amount - shield_damage
    current_health -= health_damage
    
    # 3. Prevenir valores negativos
    current_health = max(current_health, 0.0)
    current_shield = max(current_shield, 0.0)
    
    # 4. Notificar al EventBus global (HUD, Sonidos, Killfeed)
    var is_headshot: bool = (hit_part == HitboxComponent.BodyPart.HEAD)
    EventBus.player_health_changed.emit(entity, current_health, max_health, current_shield, is_headshot)
    
    # 5. Comprobar condición de muerte
    if current_health <= 0.0:
        _die()

func heal(amount: float) -> void:
    if is_dead: return
    current_health = min(current_health + amount, max_health)
    EventBus.player_health_changed.emit(entity, current_health, max_health, current_shield, false)

func add_shield(amount: float) -> void:
    if is_dead: return
    current_shield = min(current_shield + amount, max_shield)
    EventBus.player_health_changed.emit(entity, current_health, max_health, current_shield, false)

func _die() -> void:
    is_dead = true
    EventBus.entity_died.emit(entity)
    # Aquí se desencadena la lógica de Ragdoll, soltar loot (Drop Loot), etc.