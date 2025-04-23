extends StaticBody3D

var health
@onready var deathAnim = $big_explosion
@onready var deathAnim2 = $big_explosion2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 5
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health <= 0:
		
		for i in self.get_children():
			if i.name == 'car_body':
				i.visible= false
			elif "CollisionShape" in i.name:
				i.disabled=true
		deathAnim.play()
		deathAnim2.play()
		


func _on_big_explosion_animation_finished() -> void:
	queue_free() # Replace with function body.
