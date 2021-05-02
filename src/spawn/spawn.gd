extends Node2D
## Spawn



## Refrences
const Entity := preload("res://src/entity/entity.tscn")



## Exported Variables
export(int, 3, 256) var children_max := 20

export(float, 0.0, 1.0) var  children_rate := 0.1

export var parent_world : NodePath



## Private Variables
var _ancestor = null

var _children := []



## Built-In Virtual Methods
func _ready() -> void:
	_ancestor = Entity.instance()
	_ancestor.randomize()


func _process(delta : float) -> void:
	var world = get_node_or_null(parent_world)
	if is_instance_valid(world) \
			and randf() < children_rate \
			and _children.size() < children_max:
		var entity = _ancestor.duplicate()
		while true:
			entity.position = position + Vector2(
				32 + randi() % 100 * (1 if randf() > 0.5 else -1),
				32 + randi() % 100 * (1 if randf() > 0.5 else -1)
			)
			if world.is_world_point(entity.position):
				break
		entity.parent_world = parent_world
		world.add_child(entity)
		_children.append(entity)
