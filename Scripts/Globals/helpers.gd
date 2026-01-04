extends Node

func sleep(time: float = 1.0):
	await get_tree().create_timer(time).timeout
