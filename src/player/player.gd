extends Camera2D
## Player



## Exported Variables
export(float, 0.0, 100.0) var speed := 10.0

export(float, 0.0, 10.0) var speed_boost := 0.75



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
