extends SpotLight3D

@onready var flashlight: SpotLight3D = $"."


func _ready() -> void:
	flashlight.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
