extends Node
class_name ScreenConsole

var _messages_array : Array[Label]
var _messages_on_screen : int
var _last_top_position : int = 0

var timer : Timer

var _debug_enabled : bool = false
var _messages_buffer : int
var _timeout : float
var _show_timestamp : bool
var _left_offset : float
var _top_offset : float
var _vertical_space : float
var _font_color : String
var _font_size : float
var _anchor : int

var _plugin_config : ConfigFile =  ConfigFile.new()

var _config_path : String = "res://addons/screen_console/plugin.cfg"


func _ready():
	_load_config()


func _load_config():
	_plugin_config = ConfigFile.new()
	# Load data from a file.
	var err = _plugin_config.load(_config_path)

	# If the file didn't load, ignore it.
	if err != OK:
		return

	_debug_enabled = bool(_plugin_config.get_value("config", "debug_enabled"))
	_messages_buffer = int(_plugin_config.get_value("config", "buffer"))
	_timeout = float(_plugin_config.get_value("config", "timeout"))
	_show_timestamp = bool(_plugin_config.get_value("config", "show_timestamp"))
	_left_offset = float(_plugin_config.get_value("config", "left_offset"))
	_top_offset = float(_plugin_config.get_value("config", "top_offset"))
	_vertical_space = float(_plugin_config.get_value("config", "vertical_space"))
	_font_color = _plugin_config.get_value("config", "font_color")
	_font_size = float(_plugin_config.get_value("config", "font_size"))
	_anchor = int(_plugin_config.get_value("config", "anchor"))
	

func print(message : String):
	if not _debug_enabled:
		return
	
	if _messages_on_screen > _messages_buffer:
		printerr("Messages on screen reached buffer.")
		return
	
	# Create a new Label instance.
	var label = Label.new()
	label.name = "SCONSOLE_message_%s" % len(_messages_array)

	if _show_timestamp:
		message = "%s    %s" % [_get_timestamp_formatted(), message]

	# Set the text of the label.
	label.text = message
	
	# Configure label visuals
	var label_settings = LabelSettings.new()
	label_settings.font_size = _font_size
	label_settings.font_color = Color(_font_color)
	label.label_settings = label_settings
	
	# Get the root viewport's child, which should be the main scene.
	var root = get_tree().get_root().get_child(0)

	# Adds label to the top of every other node
	label.z_index = 10

	# Add the label as a child of the root node.
	root.add_child(label)
	
	# Updates label position
	_update_position(label)
	
	_messages_array.append(label)
	_messages_on_screen += 1
	
	# Sets times to remove label
	_remove_message(_timeout)
	

func _remove_message(timeout : float):
	# Create a new Timer
	timer = Timer.new()
	
	# Add the timer as a child of this node
	add_child(timer)
	
	# Connect the timer's timeout signal to a function
	timer.connect("timeout", _on_remove_message_timeout)
	
	# Set the timer's wait time in seconds and start it
	timer.wait_time = timeout
	timer.one_shot = true # Set to true if you only want the timer to tick once
	timer.start()
	

func _on_remove_message_timeout():
	var label : Label = _messages_array.pop_front()
	_messages_on_screen -= 1
	label.queue_free()


func _update_position(label : Label):
	var top_position : int = len(_messages_array)
	if top_position < _last_top_position and len(_messages_array) > 0:
		top_position = _last_top_position + 1
	
	var x_position : float
	var y_position : float
	
	match _anchor:
		0: # Top-Left
			x_position = _left_offset
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			
			y_position = _vertical_space * top_position + _top_offset
		1: # Top-Right
			# Getting viewport size
			var viewport_size = get_tree().root.get_size()
			x_position = viewport_size.x - _left_offset - label.size.x
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			
			y_position = _vertical_space * top_position + _top_offset
		2: # Bottom-Left
			# Getting viewport size
			var viewport_size = get_tree().root.get_size()
			x_position = _left_offset
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			
			y_position = viewport_size.y - (_vertical_space * top_position + _top_offset)
			
		3: # Bottom-Right
			# Getting viewport size
			var viewport_size = get_tree().root.get_size()
			x_position = viewport_size.x - _left_offset - label.size.x
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			
			y_position = viewport_size.y - (_vertical_space * top_position + _top_offset)
	
	# Set the label's position to the top-left corner of the screen.
	label.position = Vector2(x_position, y_position)
	_last_top_position = top_position


func _get_timestamp_formatted() -> String:
	var current_date = Time.get_date_dict_from_system()
	var current_time = Time.get_time_dict_from_system()
	var timestamp_string = "%d-%02d-%02d %02d:%02d:%02d" % [
		current_date.year,
		current_date.month,
		current_date.day,
		current_time.hour,
		current_time.minute,
		current_time.second
	]	
	
	return timestamp_string
