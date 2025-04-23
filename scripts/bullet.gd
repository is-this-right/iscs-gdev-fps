extends Node3D

var SPEED = 20.0

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

signal makeExplosion(pos, dir)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if (ray_cast_3d.get_collider()):
		print("hit")
		var current_pos = self.global_position
		var current_dir = self.global_rotation
		makeExplosion.emit(current_pos, current_dir)
		var collider = ray_cast_3d.get_collider()
		if collider.is_in_group("destructible"):
			collider.health -= 1
		queue_free()
