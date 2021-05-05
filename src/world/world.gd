extends Node2D
## World



## Refrences
const Food := preload("res://src/food/food.tscn")

const Spawn := preload("res://src/spawn/spawn.tscn")



## Exported Variables
export(float, 0.0, 1.0) var food_rate := 0.3

export(int, 0, 1000) var food_max := 300

export(float, 0.0, 1.0) var spawn_rate = 0.6

export(int, 0, 100) var spawn_max := 10

export var world_size := Vector2(800, 800)

export(int, 0, 255) var world_border_margin := 100

export var world_border_color := Color.white



## Private Variables
var _food_pool := []



## Built-In Virtual Methods
func _ready() -> void:
	randomize()
	
	for f in range(food_max):
		_food_pool.append(Food.instance())
		_food_pool[-1].connect("eaten", self, "_on_Food_eaten")
	
	update()


func _exit_tree() -> void:
	for food in _food_pool:
		food.free()


func _process(delta : float) -> void:
	if Engine.editor_hint:
		return
	
	for f in range(int(_food_pool.size() * (randf() * food_rate))):
		var food : Node2D = _food_pool.pop_front()
		food.position = random_world_point()
		food.randomize()
		add_child(food)
	
	if randf() < spawn_rate and get_tree().get_nodes_in_group("spawns").size() < spawn_max:
		var spawn = Spawn.instance()
		spawn.world = get_path()
		spawn.position = random_world_point()
		add_child(spawn)


func _draw() -> void:
	draw_rect(
		get_world_rect(),
		world_border_color,
		false,
		3.0
	)



## Public Methods
func get_player():
	return get_node_or_null("Player")


func get_world_rect() -> Rect2:
	return Rect2(
			(-world_size / 2) + (Vector2.ONE * world_border_margin),
			world_size - (Vector2.ONE * world_border_margin))


func random_world_point() -> Vector2:
	return ((Vector2.ONE * world_border_margin) + Vector2(
			randi() % int(world_size.x - world_border_margin),
			randi() % int(world_size.y - world_border_margin))) - (world_size / 2)


func is_world_point(point : Vector2) -> bool:
	return get_world_rect().has_point(point)



## Private Methods
func _on_Food_eaten(food) -> void:
	_food_pool.append(food)
