extends StaticBody3D

var health


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 5
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health <= 0:
		queue_free()
