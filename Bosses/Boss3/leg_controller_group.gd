extends Node2D
class_name IK_Master

func jump():
	for child in get_children():
		if child is IK_LegController:
			child.set_state(child.state.JUMP)

func land():
	for child in get_children():
		if child is IK_LegController:
			child.set_state(child.state.STATIC)
