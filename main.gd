extends Node

export (PackedScene) var playerPackedScene;

var players = {};
var localPlayer;

var Online = false;
var IsMaster = true;

func _ready():
	if OS.has_feature("server"):
		createServer()		
	pass # Replace with function body.

func createServer():
	Online = true;
	IsMaster = true;
	get_tree().connect("network_peer_connected", self, "_onPlayerConnected")
	get_tree().connect("network_peer_disconnected", self, "_onPlayerDisconnected")
	var serverPeer = NetworkedMultiplayerENet.new()
	serverPeer.create_server(8888, 128)
	get_tree().network_peer = serverPeer
	pass

func createClient(ip):
	get_tree().connect("connected_to_server", self, "_onServerConnected")
	var clientPeer = NetworkedMultiplayerENet.new()
	clientPeer.create_client(ip, 8888)
	
	get_tree().network_peer = clientPeer
	
	localPlayer = playerPackedScene.instance()
	localPlayer.set_position(Vector2(250,250))
	add_child(localPlayer)
	pass

func _onPlayerConnected(id):
	print("Player connected, id: %s", id)
	rpc("createPlayer", id)
	pass
	
func _onPlayerDisconnected(id):
	rpc("removePlayer", id)
	get_node("/root/%s" % id).queue_free()
	pass
	
func _onServerConnected():
	Online = true;
	IsMaster = false;
	var selfPeerId = get_tree().get_network_unique_id()
	localPlayer.set_network_master(selfPeerId)
	localPlayer.set_name(str(selfPeerId))
	pass
	
func connectToServer(ip):
	createClient(ip)
	pass
	
remotesync func createPlayer(id):
	if(id == get_tree().get_network_unique_id()):
		return
		
	var playerInstance = playerPackedScene.instance()
	playerInstance.init(id)
	playerInstance.set_name(str(id))
	playerInstance.set_network_master(id)
	add_child(playerInstance)
	players[id] = playerInstance
	pass
	
remote func removePlayer(id):
	players[id].queue_free()
	pass
#func _process(delta):
#	pass
