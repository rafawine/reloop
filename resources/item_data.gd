# item_data.gd
extends Resource
class_name ItemData

@export var name: String = "Item Desconocido"
@export var max_stack: int = 1
@export var is_consumable: bool = true # NUEVO: True para cubos, False para armas
# LA MAGIA: Esto mostrará un selector de archivos .tscn en el editor, 
# pero internamente solo guardará un texto como "res://scenes/.../mi_escena.tscn"
@export_file("*.tscn") var drop_scene_path: String
@export var mechanic_script: Script

# A futuro aquí puedes agregar:
# @export var icon: Texture2D
# @export var description: String