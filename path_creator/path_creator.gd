tool
extends EditorPlugin

var marker = preload("res://addons/path_creator/Position2DMarker.tscn")

func _enter_tree():
	add_custom_type("PathCreator2D", "Node2D", preload("res://PathCreator.gd"), preload("res://addons/path_creator/icons/PathCreator.png"))
	
func get_nearest_child_within(node: Node2D, pos: Vector2, dist: float) -> Node:
	var o: Node
	var D := {}
	for c in node.get_children():
		var c_dist = pos.distance_to(c.position)
		if c_dist <= dist:
			D[c_dist] = c
	var k = D.keys()
	if k.size() > 0:
		k.sort()
		o = D[k[0]]
	return o

func forward_canvas_gui_input(ev: InputEvent) -> bool:
	var consume = false
	var selected = get_editor_interface().get_selection().get_selected_nodes()
	if selected.size() != 1: return consume
	else:
		selected = selected[0]
	if not (selected is PathCreator2D): return consume
	if ev is InputEventMouseButton and ev.is_pressed():
		var mpos = (selected as PathCreator2D).get_local_mouse_position()
		match ev.button_index:
			BUTTON_LEFT:
				var p = marker.instance()
				p.global_position = mpos
				selected.add_child(p)
				consume = true
			BUTTON_RIGHT:
				var pos2dnode = get_nearest_child_within(selected, mpos, 50)
				if pos2dnode is Position2DMarker: pos2dnode.queue_free()
				consume = true
			BUTTON_MIDDLE: 
				consume = false
	return consume
	
func handles(object) -> bool:
	return object is PathCreator2D

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Always remember to remove it from the engine when deactivated.
	remove_custom_type("PathCreator2D")
