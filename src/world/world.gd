extends Node2D
## World



## Refrences
const Food := preload("res://src/food/food.tscn")



## Exported Variables
export(int, 0, 1000) var food_max := 100

export(float, 0.0, 1.0) var food_rate := 0.3

export var world_size := Vector2(800, 800)

export var world_border_color := Color.white



## Private Variables
var _foods := []



## Built-In Virtual Methods
func _ready() -> void:
	update()


func _process(delta : float) -> void:
	if randf() < food_rate:
		var food := Food.instance()
		food.position = Vector2(
			randi() % world_size.x as int,
			randi() % world_size.y as int
		) - (Vector2.ONE * world_size / 2)
		food.randomize()
		add_child(food)


func _draw() -> void:
	draw_rect(
		Rect2(
			-Vector2.ONE * world_size  / 2,
			Vector2.ONE * world_size
		), world_border_color, false, 3.0
	)
