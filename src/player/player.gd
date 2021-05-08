extends Camera2D
## Player



## Exported Variables
export(float, 0.0, 100.0) var speed := 10.0

export(float, 0.0, 100.0) var speed_pan := 30.0

export(float, 0.0, 10.0) var speed_boost := 0.75

export var world : NodePath setget set_world



## Private Variables
var _world

var _dragging := false

var _selected := []



## Built-In Virtual Methods
func _process(delta : float) -> void:
	var direction := Vector2()
	if Input.is_action_pressed("move_up"):
		direction += Vector2.UP
	if Input.is_action_pressed("move_right"):
		direction += Vector2.RIGHT
	if Input.is_action_pressed("move_down"):
		direction += Vector2.DOWN
	if Input.is_action_pressed("move_left"):
		direction += Vector2.LEFT
	
	if Input.is_action_pressed("move_boost"):
		direction += direction * speed_boost
	
	translate(direction * speed)
	if is_instance_valid(_world):
		var world_rect : Rect2 = _world.get_world_rect()
		position.x = position.x if position.x > world_rect.position.x else world_rect.position.x
		position.x = position.x if position.x < world_rect.end.x else world_rect.end.x
		position.y = position.y if position.y > world_rect.position.y else world_rect.position.y
		position.y = position.y if position.y < world_rect.end.y else world_rect.end.y


func _input(event : InputEvent) -> void:
	if Engine.editor_hint:
		return
	
	if event is InputEventMouseButton:
			match event.button_index:
				BUTTON_LEFT:
					_dragging = event.pressed
				BUTTON_WHEEL_UP:
					if zoom.x > 0.1:
						self.zoom += -Vector2.ONE * 0.1
						get_tree().set_input_as_handled()
				BUTTON_WHEEL_DOWN:
					if zoom.x < 3:
						self.zoom += Vector2.ONE * 0.1
						get_tree().set_input_as_handled()
	elif event is InputEventMouseMotion:
		if _dragging:
			translate(-event.relative.normalized() * speed_pan * zoom)
			get_tree().set_input_as_handled()



## Public Methods
func set_world(node_path : NodePath) -> void:
	world = node_path
	if is_inside_tree() and not world.is_empty():
		_world = get_node_or_null(world)


func select(entity) -> void:
	_selected.append(entity)


func unselect(entity) -> void:
	_selected.erase(entity)


func unselect_all() -> void:
	_selected.clear()
