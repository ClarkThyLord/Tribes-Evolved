tool
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

export var world_size := Vector2(800, 800) setget set_world_size

export var world_margin := Vector2(35, 35) setget set_world_margin

export var world_border_color := Color.white setget set_world_border_color



## Private Variables
var _food_pool := []



## OnReady Variables
onready var spawn_view := get_node("CanvasLayer/SpawnView")



## Built-In Virtual Methods
func _ready() -> void:
	randomize()
	
	for f in range(food_max):
		_food_pool.append(Food.instance())
		_food_pool[-1].connect("eaten", self, "_on_Food_eaten")
	
	update()


func _exit_tree() -> void:
	for food in _food_pool:
		if is_instance_valid(food):
			food.queue_free()


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
		spawn.connect("selected", self, "_on_Spawn_selected")


func _draw() -> void:
	if Engine.editor_hint:
		var border = get_world_border_rect()
		draw_rect(
			border,
			Color.red,
			false,
			3.0
		)
	
	draw_rect(
		get_world_rect(),
		world_border_color,
		false,
		3.0
	)



## Public Methods
func set_world_size(value : Vector2) -> void:
	world_size = value
	update()


func set_world_margin(value : Vector2) -> void:
	world_margin = value
	update()


func set_world_border_color(value : Color) -> void:
	world_border_color = value
	update()


func get_player():
	return get_node_or_null("Player")


func get_world_rect() -> Rect2:
	return Rect2(-world_size / 2, world_size)


func get_world_border_rect() -> Rect2:
	return Rect2(
			(-world_size / 2) + world_margin,
			world_size - (world_margin * 2))


func random_world_point(margin := world_margin) -> Vector2:
	return (margin + Vector2(
			randi() % int(world_size.x - (margin.x * 2)),
			randi() % int(world_size.y - (margin.y * 2)))) - (world_size / 2)


func is_world_point(point : Vector2) -> bool:
	return get_world_rect().has_point(point)



## Private Methods
func _on_Food_eaten(food) -> void:
	_food_pool.append(food)


func _on_Spawn_selected(spawn) -> void:
	spawn_view.show_spawn(spawn)
