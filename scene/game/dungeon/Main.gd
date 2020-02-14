## Based on Procedual Dungeon Generation tutorial series by Chris Bradfield:
# http://kidscancode.org/blog/2018/12/godot3_procgen6/

extends Node2D

var room = preload("res://scene/game/dungeon/room/room.tscn");
var player = preload("res://scene/game/player/Player.tscn");
var enemy = preload("res://scene/game/enemy/Enemy.tscn");

onready var global = $"/root/Global";
onready var routes = $"/root/API";

var player_inst;
var player_pos = Vector2();

onready var tile_size = global.DUNGEON_UNIT;
var num_rooms = 20;
var min_size = 6;
var max_size = 14;
var hspread = 20;
var room_width = 2500;
var room_height = 1500;
var cull = 0.5;

var velocity = Vector2(0,0);

onready var tile = $TM_Overworld;
var tile_solid_index = [1];

# A-star pathfinding
var path; 

var start_room = null
var end_room = null
var play_mode = false  

func _ready():
	randomize();
	global.dungeon_rand.set_seed(hash(global.quest.dungeon_seed));
	global.movement_rand.set_seed(hash(global.quest.dungeon_seed));
	make_rooms();
	
func _signal_room_created():
	make_map();
	setup_player_inst();
	populate_dungeon(tile);
	clear_rooms();

#Create layout of rooms
func make_rooms():
	for t in range(num_rooms):
		var pos = Vector2(global.dungeon_rand.randf_range(-room_width/2, room_width/2),
			global.dungeon_rand.randf_range(-room_height/2, room_height/2));
		var r = room.instance();
		var w = min_size+ global.dungeon_rand.randi() % (max_size - min_size);
		var h = min_size+ global.dungeon_rand.randi() % (max_size - min_size);
		r.make_room(pos, Vector2(w, h) * tile_size);
		$Room.add_child(r);
		
	# Cull rooms
	var roompos_arr = [];
	
	for r in $Room.get_children():
		yield(get_tree(), "idle_frame");
		var size = r.get_overlapping_areas().size();
		if(r.get_overlapping_areas().size()> 0):
			$Room.remove_child(r);
			r.queue_free();
	
	for r in $Room.get_children():
		roompos_arr.append(
			Vector3(r.position.x, r.position.y, 0));

	path = find_mst(roompos_arr);
	
	_signal_room_created();

#TODO - Populate dungeon with enemies and chests
func populate_dungeon(tile):
	#generate_items(tile);
	generate_enemies(tile);

func generate_enemies(tile):
	var enemies_count = 0;
	for r in $Room.get_children():
		if r == start_room: continue;
		
		for i in range(global.dungeon_rand.randi_range(0,5)):
			var room_shape = r.get_node("CS_Room").shape.get_extents();
			var rand_pos = Vector2(
				global.dungeon_rand.randi_range(r.position.x,room_shape.x + r.position.x - tile_size),
				global.dungeon_rand.randi_range(r.position.y,room_shape.y + r.position.y - tile_size));
			
			var enemy_inst = enemy.instance();
			enemy_inst.init(tile, tile_solid_index, rand_pos);
			$Enemy.add_child(enemy_inst);
			enemies_count += 1;
	pass;
#Initialize player instance
func setup_player_inst():
	player_inst = player.instance();
	player_inst.init(start_room.position);
	$Player.add_child(player_inst);

#Generate MST from given nodes
func find_mst(nodes):
	# Find minimum spanning tree using Prim's algorithm
	# Initialize the AStar and add the first point
	var path = AStar.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	# Repeat until no more nodes remain
	while nodes:
		var min_dist = INF;  # Minimum distance so far
		var min_p = null;  # Position of that node
		var p = null;  # Current position
		# Loop through points in path
		for p1 in path.get_points():
			p1 = path.get_point_position(p1);
			# Loop through the remaining nodes
			for p2 in nodes:
				# If the node is closer, make it the closest
				if p1.distance_to(p2) < min_dist:
					min_dist = p1.distance_to(p2);
					min_p = p2;
					p = p1;
		# Insert the resulting node into the path and add
		# its connection
		var n = path.get_available_point_id();
		path.add_point(n, min_p);
		path.connect_points(path.get_closest_point(p), n);
		# Remove the node from the array so it isn't visited again
		nodes.erase(min_p);
	return path;

#Create a map of tiles
func make_map():
	# Create a TileMap from the generated rooms and path
	tile.clear()
	find_start_room()
	find_end_room()
	
	# Fill TileMap with walls, then carve empty rooms
	var full_rect = Rect2()
	for room in $Room.get_children():
		var r = Rect2(room.position-room.room_size,
					room.get_node("CS_Room").shape.extents*2)
		full_rect = full_rect.merge(r)
	var topleft = tile.world_to_map(full_rect.position)
	var bottomright = tile.world_to_map(full_rect.end)
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			tile.set_cell(x, y, 1)	
	
	# Carve rooms
	var corridors = []  # One corridor per connection
	for room in $Room.get_children():
		var s = (room.room_size / tile_size).floor()
		var pos = tile.world_to_map(room.position)
		var ul = (room.position / tile_size).floor() - s
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				tile.set_cell(ul.x + x, ul.y + y, 0)
		# Carve connecting corridor
		var p = path.get_closest_point(Vector3(room.position.x, 
											room.position.y, 0))
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = tile.world_to_map(Vector2(path.get_point_position(p).x,
													path.get_point_position(p).y))
				var end = tile.world_to_map(Vector2(path.get_point_position(conn).x,
													path.get_point_position(conn).y))									
				carve_path(start, end)
		corridors.append(p)
	path = null;

#Remove all rooms instances (Used after generating tiles from room layouts)
func clear_rooms():
	for n in $Room.get_children():
		n.queue_free();

#Create a path between each rooms on the tiles
func carve_path(pos1, pos2):
	# Carve a path between two points
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1.0, global.dungeon_rand.randi() % 2)
	else: global.dungeon_rand.randi();
	if y_diff == 0: y_diff = pow(-1.0, global.dungeon_rand.randi() % 2)
	else: global.dungeon_rand.randi();
	# choose either x/y or y/x
	var x_y = pos1
	var y_x = pos2
	if (global.dungeon_rand.randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff):
		tile.set_cell(x, x_y.y, 0)
		tile.set_cell(x, x_y.y + y_diff, 0)  # widen the corridor
	for y in range(pos1.y, pos2.y, y_diff):
		tile.set_cell(y_x.x, y, 0)
		tile.set_cell(y_x.x + x_diff, y, 0)

#Set the start position
func find_start_room():
	var min_x = INF
	for room in $Room.get_children():
		if room.position.x < min_x:
			start_room = room
			min_x = room.position.x

#Set the goal position
func find_end_room():
	var max_x = -INF
	for room in $Room.get_children():
		if room.position.x > max_x:
			end_room = room
			max_x = room.position.x

#Shape drawing from room creation (Only for debugging)
func _draw():
	return;
	for r in $Room.get_children():
		draw_rect( Rect2(r.position - r.room_size, r.room_size*2), 
			Color(10,10,100), false);
	
	if path:
		for p in path.get_points():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p);
				var cp = path.get_point_position(c);
				draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y),
						  Color(1, 1, 0), 15, true);
	

#Moves player based on analog controls input
func move_player():
	if(player_inst):
		player_inst.velocity = $GUI/Control/Analog.velocity;
		update_player_pos();
		
#Update in-game time when player moves to another grid
func update_player_pos():
	if(player_pos != player_inst.grid):
		player_pos = player_inst.grid;
		move_enemy();

func update_entity_depth():
	for e in $Enemy.get_children():
		e.z_index = room_height/2 + e.position.y/10.0;
	for p in $Player.get_children():
		p.z_index = room_height/2 + p.position.y/10.0;

func move_enemy():
	var p = $Player.get_children()[0];
	for e in $Enemy.get_children():
		e.move_random();
		if(check_battle(p, e)):
			battle(e);

func check_battle(player, enemy):
	var dist_x = abs(player.grid.x - enemy.grid_pos.x);
	var dist_y = abs(player.grid.y - enemy.grid_pos.y);
	return (dist_x + dist_y) <= 2;

func battle(enemy):
	$GUI/PU_Quiz.activate(enemy, [$GUI/Control/Analog]);

#Called on every frame
func _process(delta):
	move_player();
	update_entity_depth();
	update();
