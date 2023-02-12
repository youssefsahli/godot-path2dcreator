tool
extends EditorPlugin

var marker = preload("res://addons/path_creator/Position2DMarker.tscn")
var last_selection

func _enter_tree():
	add_custom_type("PathCreator2D", "Node2D", \
		preload("res://addons/path_creator/PathCreator.gd"), \
		preload("res://addons/path_creator/icons/PathCreator.png"))
	
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
	
func clear_markers(selected):
	for c in selected.get_children():
		if c is Position2DMarker: c.queue_free()
	
func make_visible(visible: bool):
	if not visible and last_selection: 
		last_selection.editor_line.visible = false
		clear_markers(last_selection)
		return
	var selected = get_editor_interface().get_selection().get_selected_nodes()[0]
	last_selection = selected
	selected.editor_line.visible = true
	clear_markers(selected)
	for c in (selected as PathCreator2D).get_path_points():
		var p = marker.instance()
		p.global_position = c
		selected.add_child(p)
	
	selected.update_line()
		

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
				selected.add_point(p)
				selected.add_child(p)
				get_editor_interface().inspect_object(selected)
				consume = true
			BUTTON_RIGHT:
				var pos2dnode = get_nearest_child_within(selected, mpos, 50)
				if pos2dnode is Position2DMarker: 
					pos2dnode.queue_free()
					selected.remove_point(pos2dnode)
					get_editor_interface().inspect_object(selected)
				consume = true
			BUTTON_MIDDLE: 
				consume = false
	return consume
	
func handles(object) -> bool:
	return object.get("type") == "PathCreator2D"

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Always remember to remove it from the engine when deactivated.
	remove_custom_type("PathCreator2D")
