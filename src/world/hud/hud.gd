extends Control
## HUD



## OnReady Variables
onready var speed_value := get_node("Controls/VBoxContainer/Speed/Value")



## Built-In Virtual Methods
func _process(delta : float) -> void:
	visible = not get_tree().paused



## Private Methods
func _on_Speed_Value_gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_RIGHT:
				speed_value.value = 1.0
				get_tree().set_input_as_handled()


func _on_Speed_Value_value_changed(value : float):
	Engine.time_scale = value
