extends Node2D


func _process(delta):
	change_scene()

func _on_to_clift_side_body_entered(body: Node2D) -> void:
		if body.is_in_group("player"):
			Global.transition_scene = true

func _on_to_clift_side_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
			Global.transition_scene = false

func change_scene():
	if Global.transition_scene == true:
		if Global.current_scene == "world":
			get_tree().change_scene_to_file("res://scenes/clift_side.tscn")
			Global.finish_change_scenes()
		
