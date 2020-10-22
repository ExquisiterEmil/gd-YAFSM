tool
extends Resource

# Reserved state name for Entry/Exit
const ENTRY_KEY = "Entry"
const EXIT_KEY = "Exit"

const META_GRAPH_OFFSET = "graph_offset" # Meta key for graph_offset

export(String) var name = "" # Name of state, unique within StateMachine

var graph_offset setget set_graph_offset, get_graph_offset # Position in GraphEdit stored as meta, for editor only


func _init(p_name=""):
	name = p_name

func is_entry():
	return name == ENTRY_KEY

func is_exit():
	return name == EXIT_KEY

func set_graph_offset(offset):
	set_meta(META_GRAPH_OFFSET, offset)

func get_graph_offset():
	return get_meta(META_GRAPH_OFFSET) if has_meta(META_GRAPH_OFFSET) else Vector2.ZERO
