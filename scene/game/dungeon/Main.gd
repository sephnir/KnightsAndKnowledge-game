## Based on Procedual Dungeon Generation tutorial series by Chris Bradfield:
# http://kidscancode.org/blog/2018/12/godot3_procgen6/

extends Node2D

var room = preload("res://scene/game/dungeon/room/room.tscn");
var player = preload("res://scene/game/player/Player.tscn");
var enemy = preload("res://scene/game/enemy/Enemy.tscn");
var item = preload("res://scene/game/item/Item.tscn");

onready var global = $"/root/Global";
onready var routes = $"/root/API";

var player_inst;
var player_pos = Vector2();

var enemy_sprites = [];
var topic_size = 0;

onready var tile_size = global.DUNGEON_UNIT;
var num_rooms = 40;
var min_size = 6;
var max_size = 8;
var hspread = 20;
var room_width = 3000;
var room_height = 2000;
var cull = 0.5;

var velocity = Vector2(0,0);

onready var tile = $TM_Overworld;
var tile_solid_index = [2,3,4];
var tile_open_index = [0,1];

# A-star pathfinding
var path; 

var start_room = null
var end_room = null
var play_mode = false  

var open_tile_pos = [];
var wall_tile_pos = [];

# Called when scene is ready
func _ready():
	randomize();
	fetch_sprites();
	global.dungeon_rand.set_seed(hash(global.dungeon_seed));
	global.movement_rand.set_seed(hash(global.dungeon_seed));
	make_rooms();

# Called after room is created
func _signal_room_created():
	make_map();
	setup_player_inst();
	populate_dungeon(tile);
	clear_rooms();

# Fetch monster sprites from url in topics
func fetch_sprites():
	for topic in global.topics:
		var request_url = global.get_cdn_url(topic.sprite_path);
		$HR_SprLoader.request(request_url);

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

# Populate dungeon with enemies and chests
func populate_dungeon(tile):
	generate_items(tile);
	generate_enemies(tile);
	update_goal_pos();

# Set the goal position to the furthest from start room
func update_goal_pos():
	$Spr_Goal.position = Vector2(end_room.position.x, end_room.position.y);
	$Spr_Goal.visible = true;

# Generate item entities at random
func generate_items(tile):
	var item_count = 0;
	for r in $Room.get_children():
		if r == start_room: continue;
		
		for i in range(global.dungeon_rand.randi_range(0,1)):
			var room_shape = r.get_node("CS_Room").shape.get_extents();
			var rand_pos = Vector2(
				global.dungeon_rand.randi_range(r.position.x,room_shape.x + r.position.x - tile_size*2),
				global.dungeon_rand.randi_range(r.position.y,room_shape.y + r.position.y - tile_size*2));
				
			var item_inst = item.instance();
			item_inst.init(rand_pos);
			$Item.add_child(item_inst);
			item_count += 1;
			
# Generate enemy entities at random
func generate_enemies(tile):
	var enemies_count = 0;
	for r in $Room.get_children():
		if r == start_room: continue;
		
		for i in range(global.dungeon_rand.randi_range(0,5)):
			var room_shape = r.get_node("CS_Room").shape.get_extents();
			var rand_pos = Vector2(
				global.dungeon_rand.randi_range(r.position.x,room_shape.x + r.position.x - tile_size*2),
				global.dungeon_rand.randi_range(r.position.y,room_shape.y + r.position.y - tile_size*2));
			
			var enemy_inst = enemy.instance();
			enemy_inst.init(tile, tile_solid_index, rand_pos);
			$Enemy.add_child(enemy_inst);
			enemies_count += 1;

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
	tile.clear();
	find_start_room();
	find_end_room();
	
	# Fill TileMap with solid, then carve empty rooms
	var full_rect = Rect2()
	for room in $Room.get_children():
		var r = Rect2(room.position-room.room_size-Vector2(tile_size,tile_size),
					room.get_node("CS_Room").shape.extents*2)
		full_rect = full_rect.merge(r)
	var topleft = tile.world_to_map(full_rect.position)
	var bottomright = tile.world_to_map(full_rect.end)
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			tile.set_cellv(Vector2(x, y), tile.get_tileset().find_tile_by_name("solid"));
	
	# Carve rooms
	var corridors = []  # One corridor per connection
	for room in $Room.get_children():
		var s = (room.room_size / tile_size).floor()
		var pos = tile.world_to_map(room.position)
		var ul = (room.position / tile_size).floor() - s
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				var vec = Vector2(ul.x + x, ul.y + y);
				tile.set_cellv(vec, get_rand_floor_ind());
				open_tile_pos.append(vec);
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
		corridors.append(p);
	cull_solid_col(4, 3);
	make_wall();
	make_border();
	reapply_tile();
	path = null;

#Remove solid between 2 open-areas that are less than n and m solid apart
func cull_solid_col(n, m):
	for pos in open_tile_pos:
		var check = 0;
		for i in range(n):
			var tmp = tile.get_cellv(Vector2(pos.x, pos.y-i-1));
			if(!tmp in tile_solid_index && tmp!= -1):
				for j in range(i):
					# Replace solids
					var vec = Vector2(pos.x, pos.y-j-1);
					tile.set_cellv(vec, get_rand_floor_ind());
					open_tile_pos.append(vec);
				break;
				
		for i in range(m):
			var tmp = tile.get_cellv(Vector2(pos.x-i-1, pos.y));
			if(!tmp in tile_solid_index && tmp!= -1):
				for j in range(i):
					# Replace solids
					var vec = Vector2(pos.x-j-1, pos.y);
					tile.set_cellv(vec, get_rand_floor_ind());
					open_tile_pos.append(vec);
				break;

#Create walls when top of an open cell is solid
func make_wall():
	for pos in open_tile_pos:
		var temp_y = pos.y - 1;
		var vec = Vector2(pos.x, temp_y);
		if(tile.get_cellv(vec) in tile_solid_index):
			tile.set_cellv(vec, tile.get_tileset().find_tile_by_name("wall"));
			wall_tile_pos.append(vec);

#Make the border walls around the map
func make_border():
	for pos in (open_tile_pos + wall_tile_pos):
		for i in range(-1,2):
			for j in range(-1,2):
				var vec = Vector2(pos.x-i, pos.y-j);
				var tid = tile.get_cellv(vec);
#				if(tid == tile.get_tileset().find_tile_by_name("solid")):
				tile.set_cellv(vec, tile.get_tileset().find_tile_by_name("border"));
	tile.update_bitmask_region();
	
#Reapply walls and ground
func reapply_tile():
	for pos in tile.get_used_cells_by_id(tile.get_tileset().find_tile_by_name("solid")):
		tile.set_cellv(Vector2(pos.x, pos.y), -1);
	for pos in open_tile_pos:
		tile.set_cellv(Vector2(pos.x, pos.y), get_rand_floor_ind());
	for pos in wall_tile_pos:
		tile.set_cellv(Vector2(pos.x, pos.y), tile.get_tileset().find_tile_by_name("wall"));

#Pick a random floor index from open_tile array
func get_rand_floor_ind():
	var tile_ind = randi() % tile_open_index.size();
	return tile_open_index[tile_ind];

#Remove all rooms instances (Used after generating tiles from room layouts)
func clear_rooms():
	for n in $Room.get_children():
		n.queue_free();

#Create a path between each rooms on the tiles
func carve_path(pos1, pos2):
	# Carve a path between two points
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: 
		x_diff = pow(-1.0, global.dungeon_rand.randi() % 2);
	else: 
		global.dungeon_rand.randi();
	if y_diff == 0: 
		y_diff = pow(-1.0, global.dungeon_rand.randi() % 2);
	else: 
		global.dungeon_rand.randi();
	# choose either x/y or y/x
	var x_y = pos1;
	var y_x = pos2;
	if (global.dungeon_rand.randi() % 2) > 0:
		x_y = pos2;
		y_x = pos1;
	for x in range(pos1.x, pos2.x, x_diff):
		var temp = Vector2(x, x_y.y);
		tile.set_cellv(temp, 0);
		open_tile_pos.append(temp);
		temp = Vector2(x, x_y.y + y_diff);
		tile.set_cellv(temp, tile.get_tileset().find_tile_by_name("ground_l")); 
		open_tile_pos.append(temp);
	for y in range(pos1.y, pos2.y, y_diff):
		var temp = Vector2(y_x.x, y);
		tile.set_cellv(temp, 0);
		open_tile_pos.append(temp);
		temp = Vector2(y_x.x + x_diff, y);
		tile.set_cellv(temp, tile.get_tileset().find_tile_by_name("ground_l"));
		open_tile_pos.append(temp);

#Set the start position
func find_start_room():
	var min_x = INF
	for room in $Room.get_children():
		if room.position.x < min_x:
			start_room = room
			min_x = room.position.x

#Set the goal position
func find_end_room():
	var max_x = -INF;
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
		$Light2D.position.x = player_inst.position.x;
		$Light2D.position.y = player_inst.position.y+16;
		update_player_pos();
		
#Update in-game time when player moves to another grid
func update_player_pos():
	if(player_pos != player_inst.grid):
		player_pos = player_inst.grid;
		global.score = max(global.score-1, 0);
		check_goal();
		check_item();
		move_enemy();
		
# Update entities attribute
func update_entity_var():
	if(!$Player.get_children()):
		return;
	var p = $Player.get_children()[0];
	p.z_index = room_height/2 + p.position.y/10.0;
	for e in $Enemy.get_children():
		e.z_index = room_height/2 + e.position.y/10.0;
		e.dist_to_player = e.position.distance_to(p.position);
	for i in $Item.get_children():
		i.z_index = room_height/2 + i.position.y/10.0;
		i.dist_to_player = i.position.distance_to(p.position);

# Movement script for enemy entities
func move_enemy():
	var p = $Player.get_children()[0];
	for e in $Enemy.get_children():
		e.move_random(); 
		if(check_battle(p, e)):
			battle(e);

# Check if player landed on the same space as an enemy entity
func check_battle(player, enemy):
	var dist_x = abs(player.grid.x - enemy.grid_pos.x);
	var dist_y = abs(player.grid.y - enemy.grid_pos.y);
	return (dist_x + dist_y) <= 2;

# Check if player landed on the goal space
func check_goal():
	var player = $Player.get_children()[0];
	if (player.grid.x == floor($Spr_Goal.position.x/ tile_size) ):
		if (player.grid.y == floor($Spr_Goal.position.y/ tile_size) ):
			next_level();

# Check if player landed on the same space as an item entity
func check_item():
	var player = $Player.get_children()[0];
	for i in $Item.get_children():
		var dist_x = abs(player.grid.x - i.grid_pos.x);
		var dist_y = abs(player.grid.y - i.grid_pos.y);
		if (dist_x + dist_y) == 0:
			i.collect();

# Load the next level
func next_level():
	global.current_floor += 1;
	if(global.current_floor > global.quest.level):
		quest_complete();
	else:
		global.dungeon_seed = hash(str(global.dungeon_seed));
		get_tree().change_scene("res://scene/game/dungeon/main.tscn");

# Load the result screen
func quest_complete():
	get_tree().change_scene("res://scene/game/result/Result.tscn");

# Initiate battle scene
func battle(enemy):
	$GUI/PU_Quiz.activate(enemy, [$GUI/Control/Analog]);

#Called on every frame
func _process(delta):
	move_player();
	update_entity_var();
	update();
