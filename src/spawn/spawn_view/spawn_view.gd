extends ColorRect
## Spawn View



## Refrences
const EvolutionStep := preload("res://src/spawn/spawn_view/evolution_step/evolution_step.tscn")

const EntityView := preload("res://src/entity/entity_view/entity_view.tscn")



## Public Variables
var spawn setget set_spawn



## OnReady Variables
onready var spawn_name : Label = get_node("VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/Name")

onready var entities : Label = get_node("VBoxContainer/MarginContainer/VBoxContainer/Stats/Entities")

onready var total_energy : Label = get_node("VBoxContainer/MarginContainer/VBoxContainer/Stats/TotalEnergy")

onready var evolution_progress : ProgressBar = get_node("VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer3/EvolutionProgress")

onready var lineage : VBoxContainer = get_node("VBoxContainer/ColorRect/ScrollContainer/MarginContainer/Lineage")



## Built-In Virtual Methods
func _ready() -> void:
	close()



## Public Methods
func set_spawn(value) -> void:
	spawn = value
	
	for node in lineage.get_children():
		lineage.remove_child(node)
		node.queue_free()
	
	if is_inside_tree() and is_instance_valid(spawn):
		spawn_name.text = spawn.spawn_name
		
		entities.text = "%s LIVING / %s DEAD / %s TOTAL" % [
			spawn.get_population_count(),
			spawn.get_total_deaths(),
			spawn.get_total_lives(),
		]
		total_energy.text = "%s   " % int(spawn.get_total_energy())
		
		evolution_progress.value = spawn.get_evolution_progress()
		
		for ancestors in spawn.get_lineage():
			var evolution_step := EvolutionStep.instance()
			for ancestor in ancestors if (typeof(ancestors) == TYPE_ARRAY) else [ancestors]:
				var entity_view := EntityView.instance()
				entity_view.texture = ancestor.get_texture()
				evolution_step.add_child(entity_view)
			lineage.add_child(evolution_step)


func show_spawn(spawn) -> void:
	self.visible = true
	self.spawn = spawn


func close() -> void:
	self.visible = false
	
	if is_instance_valid(spawn):
		spawn.unselect()
		spawn = null



## Private Methods
func _on_visibility_changed():
	get_tree().paused = visible


func _on_gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				if event.doubleclick:
					close()


func _on_Close_pressed():
	close()
