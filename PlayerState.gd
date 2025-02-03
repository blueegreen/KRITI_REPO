extends State
class_name PlayerState

var player : Player

func _ready():
	await owner.ready
	player = owner as Player
	assert(player != null, "player state cannot be used for a non-player entity")
