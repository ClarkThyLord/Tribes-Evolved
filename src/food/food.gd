tool
extends Area2D
## Food



## Signals
signal eaten(food)



## Exported Variables
export var color := Color.white setget set_color

export(float, 1.0, 100.0) var energy := 0.0 setget set_energy




## OnReady Variables
onready var collision_shape : CollisionShape2D = get_node("CollisionShape2D")



## Built-In Virtual Methods
func _ready() -> void:
	update()


func _draw() -> void:
	draw_circle(
		Vector2.ZERO,
		_get_pixel_size(),
		color
	)
	if is_instance_valid(collision_shape) \
			and is_instance_valid(collision_shape.shape):
		(collision_shape.shape as CircleShape2D).radius = _get_pixel_size()



## Public Methods
func set_energy(value : float) -> void:
	energy = value
	update()


func set_color(value : Color) -> void:
	color = value
	update()


func randomize() -> void:
	energy = 1 + randi() % 100
	color = Color(randi())


func eaten(by) -> float:
	get_parent().remove_child(self)
	emit_signal("eaten", self)
	
	return energy * color[by.get_dominant_color()]



## Private Methods
func _get_pixel_size() -> float:
	return 2.0 + ((energy / 100.0) * 3.0)
