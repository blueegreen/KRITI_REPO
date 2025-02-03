extends Node
class_name StateMachine

@export var controller : Node2D
@export var initial_state: State = null

@onready var state: State = (func get_initial_state() -> State: \
return initial_state if initial_state != null \
else null).call()

func _ready():
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)

func _process(delta):
	if state != null:
		state.update(delta)

func _physics_process(delta):
	if state != null:
		state.physics_update(delta)

func _unhandled_input(event):
	if state != null:
		state.handle_input(event)

func _transition_to_next_state(next_state_path: String, data: Dictionary = {}):
	if not has_node(next_state_path):
		printerr(owner.name + ": Trying to transition to state " + next_state_path + " but it does not exist.")
		return
	
	var previous_state_path = state.name
	state.exit()
	state = get_node(next_state_path)
	state.enter(previous_state_path, data)
