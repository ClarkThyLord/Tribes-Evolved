extends Node2D
## World



## Refrences
const Food := preload("res://src/food/food.tscn")

const Spawn := preload("res://src/spawn/spawn.tscn")



## Exported Variables
export(int, 0, 1000) var food_max := 100

export(float, 0.0, 1.0) var food_rate := 0.3

export(int, 0, 100) var spawns_max := 10

export var world_size := Vector2(800, 800)

export(int, 0, 25) var world_border_margin := 10

export var world_border_color := Color.white



## Private Variables
var _foods := []

var _spawns := []



## Built-In Virtual Methods
func _ready() -> void:
	randomize()
	update()


func _process(delta : float) -> void:
	if randf() < food_rate:
		var food := Food.instance()
		food.position = random_world_point()
		food.randomize()
		add_child(food)
	
	if _spawns.size() < spawns_max:
		var spawn = Spawn.instance()
		spawn.parent_world = get_path()
		spawn.position = random_world_point()
		add_child(spawn)
		_spawns.append(spawn)


func _draw() -> void:
	draw_rect(
		get_world_rect(),
		world_border_color,
		false,
		3.0
	)



## Public Methods
func get_world_rect() -> Rect2:
	return Rect2(
			(-Vector2.ONE * world_size / 2) + Vector2.ONE * world_border_margin,
			(Vector2.ONE * world_size) - Vector2.ONE * world_border_margin)


func random_world_point() -> Vector2:
	return Vector2.ONE * world_border_margin + Vector2(
		randi() % (world_size.x - world_border_margin) as int,
		randi() % (world_size.y - world_border_margin) as int
	) - (Vector2.ONE * world_size / 2)


func is_world_point(point : Vector2) -> bool:
	return get_world_rect().has_point(point)
