class_name HitboxComponent
extends Area3D

## Sensor de impactos anclado a los huesos del esqueleto.
## Procesa el multiplicador de zona y transfiere el daño al HealthComponent.

enum BodyPart {HEAD, TORSO, LIMB, VULNERABLE_SPOT}

@export_category("Configuración de Impacto")
@export var body_part: BodyPart = BodyPart.TORSO
@export var damage_multiplier: float = 1.0

# Referencia inyectada (usualmente asignada en el _ready() del PlayerController)
var health_component: HealthComponent

func _ready() -> void:
    # Asegurarnos de que este nodo no monitoree áreas innecesariamente por rendimiento
    monitoring = false
    monitorable = true

func take_damage(base_damage: float) -> void:
    if not health_component:
        push_warning("Hitbox %s recibió daño pero no tiene un HealthComponent asignado." % name)
        return
        
    var final_damage: float = base_damage * damage_multiplier
    health_component.apply_damage(final_damage, body_part)