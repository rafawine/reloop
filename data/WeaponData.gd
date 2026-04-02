class_name WeaponData
extends Resource

## Define las estadísticas y referencias visuales de un arma.

@export_category("Visuals")
@export var weapon_name: String = "Assault Rifle"
@export var model_scene: PackedScene
@export var crosshair_texture: Texture2D

@export_category("Combat Stats")
@export var base_damage: float = 25.0
@export var fire_rate: float = 0.1 # Tiempo en segundos entre disparos
@export var max_ammo: int = 30
@export var reload_time: float = 1.5
@export var is_hitscan: bool = true

@export_category("Recoil & Dispersion")
@export var base_spread: float = 1.2
@export var recoil_kick: Vector2 = Vector2(0.5, 1.0)