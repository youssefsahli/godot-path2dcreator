tool
extends Node2D

class_name PathCreator2D

export (Array) var path_points = [Vector2.ZERO]
var editor_line : = Line2D.new()

func _ready():
	editor_line.width = 2
	add_child(editor_line)

func update_line():
	editor_line.points = path_points

func add_point(node: Node2D):
	var pos = node.position
	if not path_points.has(pos):
		path_points.append(pos)
	update_line()

func remove_point(node: Node2D):
	path_points.erase(node.position)
	update_line()

func get_path_points():
	return path_points
