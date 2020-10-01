tool
extends EditorPlugin
const StateMachinePlayer = preload("src/StateMachinePlayer.gd")
const StateMachine = preload("src/states/StateMachine.gd")

const StateMachineEditor = preload("scenes/StateMachineEditor.tscn")

var state_machine_editor

var focused_object setget set_focused_object # Can be StateMachine/StateMachinePlayer
var editor_selection


func _enter_tree():
	editor_selection = get_editor_interface().get_selection()
	editor_selection.connect("selection_changed", self, "_on_EditorSelection_selection_changed")
	var editor_base_control = get_editor_interface().get_base_control()
	var node_icon = editor_base_control.get_icon("Node", "EditorIcons")
	var resource_icon = editor_base_control.get_icon("ResourcePreloader", "EditorIcons")
	add_custom_type("StateMachinePlayer", "Node", StateMachinePlayer, node_icon)
	add_custom_type("StateMachine", "Resource", StateMachine, resource_icon)

	state_machine_editor = StateMachineEditor.instance()
	state_machine_editor.connect("ready", self, "_on_StateMachineEditor_ready")

func _exit_tree():
	if state_machine_editor:
		state_machine_editor.queue_free()

func handles(object):
	if object is StateMachine:
		return true
	return false

func edit(object):
	set_focused_object(object)

func show_state_machine_editor():
	if focused_object and state_machine_editor:
		if not state_machine_editor.is_inside_tree():
			add_control_to_bottom_panel(state_machine_editor, "StateMachine")
		make_bottom_panel_item_visible(state_machine_editor)

func hide_state_machine_editor():
	if state_machine_editor.is_inside_tree():
		state_machine_editor.focused_object = null
		remove_control_from_bottom_panel(state_machine_editor)

func _on_EditorSelection_selection_changed():
	var selected_nodes = editor_selection.get_selected_nodes()
	if selected_nodes.size() == 1:
		var selected_node = selected_nodes[0]
		if selected_node is StateMachinePlayer:
			set_focused_object(selected_node)
			return
	set_focused_object(null)

func _on_focused_object_changed(new_obj):
	if new_obj:
		# Must be shown first, otherwise StateMachineEditor can't execute ui action as it is not added to scene tree
		show_state_machine_editor()
		var state_machine = focused_object
		if focused_object is StateMachinePlayer:
			state_machine = focused_object.state_machine
		state_machine_editor.focused_object = state_machine
	else:
		hide_state_machine_editor()

func _on_StateMachineEditor_ready():
	state_machine_editor.CreateStateMachine.connect("pressed", self, "_on_CreateStateMachine_pressed")

func _on_CreateStateMachine_pressed():
	if focused_object is StateMachinePlayer:
		var new_state_machine = StateMachine.new()
		focused_object.state_machine = new_state_machine
		state_machine_editor.focused_object = new_state_machine
		get_editor_interface().get_inspector().refresh()

func set_focused_object(obj):
	if focused_object != obj:
		focused_object = obj
		_on_focused_object_changed(obj)
