extends Node

# Constants
#const HOSTNAME = "www.mocky.io/v2/5dbe8ce1330000ce20a0e3ec";
const HOSTNAME = "127.0.0.1";
#const HOSTNAME = "192.168.1.72";
const PORT = 8000;

const CONNECTION_TIMEOUT = 500;

const DUNGEON_UNIT = 32;

const AUTH_PATH = "user://auth.data";
const GUILD_PATH = "user://guild.data";

# Global variables
var token = "";
var guild = "";

var character = -1;
var dungeon_rand = RandomNumberGenerator.new();
var movement_rand = RandomNumberGenerator.new();


func save_auth(auth):
	_save_file(AUTH_PATH, auth);

func load_auth():
	return _load_file(AUTH_PATH);

func _save_file(path, auth):
	var f = File.new();
	f.open_encrypted_with_pass(path, File.WRITE, OS.get_unique_id());
	f.store_string(auth);
	f.close();

func _load_file(path):
	var f = File.new();
	if f.file_exists(path):
		f.open_encrypted_with_pass(path, File.READ, OS.get_unique_id());
		var auth = f.get_as_text();
		f.close();
		return auth;
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

