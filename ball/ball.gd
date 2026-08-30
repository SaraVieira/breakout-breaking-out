extends CharacterBody2D


const SPEED = 200
var dir = Vector2.DOWN
var is_active = true

func _ready() -> void:
	velocity = Vector2(SPEED * -1, SPEED)

func _physics_process(delta: float) -> void:
	if is_active and not GameState.paused:
		var collision = move_and_collide(velocity * delta)
		if collision:
			velocity = velocity.bounce(collision.get_normal())

			if collision.get_collider().is_in_group("brick") and collision.get_collider().has_method("hit"):
				collision.get_collider().hit(self)

			if collision.get_collider().is_in_group("bottom-wall"):
				GameState.lose_life()
				print("Life lost! Remaining lives: ", GameState.lives)


		if(velocity.y > 0 and velocity.y < 100):
			velocity.y = -200
