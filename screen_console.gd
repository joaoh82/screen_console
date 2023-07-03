extends Node
class_name ScreenConsole

var _messages_array : Array[Label]
var _messages_on_screen : int
var _last_top_position : int = 0

var _timer_array : Array[Timer]

var _debug_enabled : bool = false
var _messages_buffer : int
var _timeout : float
var _show_timestamp : bool
var _vertical_space : float
var _font_color : String
var _background_color : String
var _font_size : float
var _anchor : int

var _plugin_config : ConfigFile

var _config_path : String = "res://addons/screen_console/plugin.cfg"

# Create a new MarginContainer
var _top_margin_container = MarginContainer.new()
# Create a new VBoxContainer
var _log_container = VBoxContainer.new()


func _ready():
	_load_config()
	_setup()


func _exit_tree():
	# Remove the MarginContainer from the current scene
	_top_margin_container.queue_free()


func _setup():
	# Adds label to the top of every other node
	_top_margin_container.z_index = 10
	
	# Set the custom constants for the margin (left, top, right, bottom)
	var margin_value = 0
	_top_margin_container.add_theme_constant_override("margin_top", margin_value)
	_top_margin_container.add_theme_constant_override("margin_left", margin_value)
	_top_margin_container.add_theme_constant_override("margin_bottom", margin_value)
	_top_margin_container.add_theme_constant_override("margin_right", margin_value)
	
	# Setting the top margin container to the correct layout mode
#	_top_margin_container.layout_mode = 2
	
	match _anchor:
		0: # Top-Left
			_top_margin_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
		1: # Top-Right
			_top_margin_container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		2: # Bottom-Left
			_top_margin_container.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		3: # Bottom-Right
			_top_margin_container.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
			
	
	# Get the root viewport's child, which should be the main scene.
	var root = get_tree().get_root().get_node("/root/SConsole")
	
	# Add the MarginContainer to the current scene
	root.add_child(_top_margin_container)
	
	# Create a new ColorRect
	var color_rect = ColorRect.new()
	
	# Set the color of the ColorRect using a hex value
	color_rect.color = Color(_background_color)
	
	# Add the ColorRect as a child of the MarginContainer
	_top_margin_container.add_child(color_rect)
	
	# Create a new MarginContainer
	var inner_margin_container = MarginContainer.new()
	
	# Set the custom constants for the margin (left, top, right, bottom)
	margin_value = 25
	inner_margin_container.add_theme_constant_override("margin_top", margin_value)
	inner_margin_container.add_theme_constant_override("margin_left", margin_value)
	inner_margin_container.add_theme_constant_override("margin_bottom", margin_value)
	inner_margin_container.add_theme_constant_override("margin_right", margin_value)
	
	# Setting the inner margin container to the correct layout mode
#	inner_margin_container.layout_mode = 2
	
	# Add the MarginContainer to the current scene
	_top_margin_container.add_child(inner_margin_container)
	
	_log_container.add_theme_constant_override("separation", _vertical_space)
	
	# Add the VBoxContainer as a child of the MarginContainer
	inner_margin_container.add_child(_log_container)
	
	# sets visibility to false
	_top_margin_container.visible = false


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
	_vertical_space = float(_plugin_config.get_value("config", "vertical_space"))
	_font_color = _plugin_config.get_value("config", "font_color")
	_background_color = _plugin_config.get_value("config", "background_color")
	_font_size = float(_plugin_config.get_value("config", "font_size"))
	_anchor = int(_plugin_config.get_value("config", "anchor"))


func print(message : String):
	if not _debug_enabled:
		return
	
	if _messages_on_screen > _messages_buffer:
		printerr("Messages on screen reached buffer.")
		return
	
	# sets visibility to true
	_top_margin_container.visible = true
	
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
	
	_log_container.add_child(label)
	
	_messages_array.append(label)
	_messages_on_screen += 1
	
	# Sets times to remove label
	_remove_message(_timeout)
	

func _remove_message(timeout : float):
	# Create a new Timer
	var timer = Timer.new()
	
	_timer_array.append(timer)
	
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
	
	# in case there are no messages on screen, hides container
	if _messages_on_screen == 0:
		_top_margin_container.visible = false

	var timer : Timer = _timer_array.pop_front()

	timer.queue_free()


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
