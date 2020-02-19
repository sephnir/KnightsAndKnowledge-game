extends Node

# Constants
#const HOSTNAME = "www.mocky.io/v2/5dbe8ce1330000ce20a0e3ec";
#const HOSTNAME = "127.0.0.1";
const HOSTNAME = "192.168.1.72";
const PORT = 8000;

const CONNECTION_TIMEOUT = 500;

const DUNGEON_UNIT = 32;

const AUTH_PATH = "user://auth.data";
const GUILD_PATH = "user://guild.data";

# Global variables
var token = "";

## Guild
var guild_name = "";
var guild_token = "";

## Character
var character = -1;
var character_name = "";

## Quest
var quest = null;

## Topic
var topics = null;

var dungeon_rand = RandomNumberGenerator.new();
var movement_rand = RandomNumberGenerator.new();

## Quest instance variables
var current_floor = 0;
var dungeon_seed = "";

func save_auth(auth):
	_save_file(AUTH_PATH, auth);

func load_auth():
	return _load_file(AUTH_PATH);
	
func save_guild():
	var guilds = _load_file(GUILD_PATH);
	var exist = false;
	if(guilds):
		for guild in guilds:
			if(guild.has('chara')&&guild.has('name')&&guild.has('token')):
				if(guild.chara == character):
					guild.name = guild_name;
					guild.token = guild_token;
					exist = true;
					break;
	else:
		guilds = [];
	
	if(!exist):
		guilds.append({'chara': character, 'name': guild_name, 'token': guild_token});
		
	_save_file(GUILD_PATH, guilds);
	
func load_guild():
	var guilds = _load_file(GUILD_PATH);
	if(guilds):
		for guild in guilds:
			if(guild.chara == character):
				guild_name = guild.name;
				guild_token = guild.token;

func _save_file(path, obj):
	var f = File.new();
	f.open_encrypted_with_pass(path, File.WRITE, OS.get_unique_id());
#	f.open(path, File.WRITE);
	f.store_var(obj);
	f.close();
	
func _load_file(path):
	var f = File.new();
	if f.file_exists(path):
		f.open_encrypted_with_pass(path, File.READ, OS.get_unique_id());
#		f.open(path, File.READ);
		var obj = f.get_var();
		f.close();
		return obj;
	return null;

# Form a request url
func get_request_url(route):
	if(PORT == 80 || PORT == 0):
		return str("http://", HOSTNAME, "/api/", route);
	else:
		return str("http://", HOSTNAME, ":", PORT, "/api/", route);

# Form authorization strings for request header
func get_bearer():
	return "Authorization: Bearer " + token;

