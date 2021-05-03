tool
extends Area2D
## Food



## Signals
signal eaten(food)



## Exported Variables
export(float, 1.0, 100.0) var nutrition := 0.0 setget set_nutrition

export var nutrition_type := Color.white setget set_nutrition_type



## OnReady Variables
onready var collision_shape : CollisionShape2D = get_node("CollisionShape2D")



## Built-In Virtual Methods
func _ready() -> void:
	if is_instance_valid(collision_shape) \
			and is_instance_valid(collision_shape.shape):
				collision_shape.shape = collision_shape.shape.duplicate()
	
	update()


func _draw() -> void:
	draw_circle(
		Vector2.ZERO,
		_get_pixel_size(),
		nutrition_type
	)
	if is_instance_valid(collision_shape) \
			and is_instance_valid(collision_shape.shape):
		(collision_shape.shape as CircleShape2D).radius = _get_pixel_size()



## Public Methods
func set_nutrition(value : float) -> void:
	nutrition = value
	update()


func set_nutrition_type(color : Color) -> void:
	nutrition_type = color
	update()


func randomize() -> void:
	nutrition = randi() % 101
	nutrition_type = Color(randi())
	update()


func consumed(consumer) -> void:
	consumer.eat(self)
	get_parent().remove_child(self)
	emit_signal("eaten", self)



## Private Methods
func _get_pixel_size() -> float:
	return 2.0 + ((nutrition / 100.0) * 3.0)
