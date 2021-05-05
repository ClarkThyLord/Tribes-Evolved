extends Area2D
## Spawn



## Refrences
const Entity := preload("res://src/entity/entity.tscn")



## Exported Variables
export(float, 0.1, 1.0) var spawn_rate := 0.1

export(int, 0, 250) var spawn_radius := 50

export(int, 1, 250) var population_minimum := 64

export(float, 0.0, 1.0) var mutation_rate := 0.01

export(float, 0.0, 1.0) var evolution_rate := 0.75

export var world : NodePath setget set_world



## Private Variables
var _world

var _lineage := []

var _population := []

var _evolution_points := 0

var _evolution_level := 500

var _selected := false

var _draw_time := 0

var _draw_points := 0

var _draw_color := Color.white



## Built-In Virtual Methods
func _ready() -> void:
	if Engine.editor_hint:
		return
	
	self.world = world
	
	if _lineage.empty():
		_add_ancestor()
	
	_draw_points = 4 + (randi() % 18)


func _exit_tree() -> void:
	for ancestor in _lineage:
		match typeof(ancestor):
			TYPE_OBJECT:
				ancestor.queue_free()
			TYPE_ARRAY:
				for parent_ancestor in ancestor:
					parent_ancestor.queue_free()


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
func randomize() -> void:
	self.spawn_rate = 0.1 + clamp(randf() - 0.5, 0.0, 1.0) 
	self.spawn_radius = 64 + (randi() % 128)
	self.population_minimum = 10 + (randi() % 40)
	self.mutation_rate = 0.01 + clamp(randf() - 0.96, 0.0, 1.0) 
	self.evolution_rate = 0.4 + clamp(randf() - 0.4, 0.0, 1.0)


func set_world(node_path : NodePath) -> void:
	world = node_path
	if is_inside_tree() and not world.is_empty():
		_world = get_node_or_null(world)


func spawn(spawn_point : Vector2, parent_a = null, parent_b = null):
	if is_instance_valid(_world) \
			and not _lineage.empty():
		
		if (randf() < mutation_rate or _evolution_points >= _evolution_level) \
				and is_instance_valid(parent_a) \
				and is_instance_valid(parent_b):
			evolve(parent_a, parent_b)
		
		var entity = _lineage.back().duplicate()
		entity.position = spawn_point
		entity.world = world
		entity.connect("died", self, "_on_Entity_died")
		
		_evolution_points += entity.energy
		
		_population.append(entity)
		_world.add_child(entity)


func evolve(parent_a, parent_b) -> void:
	_lineage.append([
		parent_a.duplicate(),
		parent_b.duplicate()])
	_add_ancestor(parent_a, parent_b)
	_evolution_points = 0
	_evolution_level += _evolution_level * evolution_rate



## Private Methods
func _add_ancestor(parent_a = null, parent_b = null) -> void:
	var ancestor := Entity.instance()
	ancestor.randomize(parent_a, parent_b)
	_lineage.append(ancestor)


func _on_input_event(viewport : Node, event : InputEvent, shape_idx : int) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				if event.doubleclick:
					_selected = !_selected


func _on_Entity_died(entity) -> void:
	_population.erase(entity)
