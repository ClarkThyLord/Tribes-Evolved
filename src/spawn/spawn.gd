extends Area2D
## Spawn



## Refrences
const Entity := preload("res://src/entity/entity.tscn")



## Exported Variables
export(float, 0.0, 1.0) var spawn_rate := 0.1

export(int, 0, 250) var spawn_radius := 50

export(int, 1, 256) var population_minimum := 64

export(float, 0.0, 1.0) var mutation_rate := 0.01

export(float, 0.0, 1.0) var evolution_rate := 0.75

export var world : NodePath setget set_world



## Private Variables
var _world

var _lineage := []

var _population := []

var _evolution_points := 0

var _selected := false

var _draw_time := 0

var _draw_points := 0

var _draw_color := Color.white



## Built-In Virtual Methods
func _ready() -> void:
	if Engine.editor_hint:
		return
	
	if _lineage.empty():
		var ancestor := Entity.instance()
		ancestor.randomize()
		_lineage.append(ancestor)
	
	_draw_points = 3 + (randi() % 33)


func _process(delta : float) -> void:
	if Engine.editor_hint:
		return
	
	if is_instance_valid(_world) \
			and randf() < spawn_rate \
			and _population.size() < population_minimum:
		while true:
			var spawn_point := position + Vector2(
					(randi() % (spawn_radius * 2)) - spawn_radius,
					(randi() % (spawn_radius * 2)) - spawn_radius)
			if _world.is_world_point(spawn_point):
				spawn(spawn_point)
				break
	
	update()
	_draw_time = (_draw_time + 1) % 360


func _draw() -> void:
	draw_arc(
		Vector2.ZERO,
		32,
		deg2rad(0 + _draw_time),
		deg2rad(360 + _draw_time),
		_draw_points,
		_draw_color,
		4 if _selected else 2
	)



## Public Methods
func set_world(node_path : NodePath) -> void:
	world = node_path
	if not world.is_empty():
		_world = get_node_or_null(world)


func spawn(spawn_point : Vector2, parent_a = null, parent_b = null):
	if is_instance_valid(_world) \
			and not _lineage.empty():
		var entity = _lineage.back().duplicate()
		entity.position = spawn_point
		entity.world = world
		_world.add_child(entity)
		_population.append(entity)



## Private Methods
func _on_input_event(viewport : Node, event : InputEvent, shape_idx : int):
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				if event.doubleclick:
					_selected = !_selected
