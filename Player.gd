extends Node2D

export (int) var speed = 50

var targetPos = Vector2.ZERO
var id = -1;

func _ready():
	targetPos = position
	pass

func _input(event):
	var netMaster = Online.IsMaster && Online.Online;
	if(netMaster):
		return
	
	if(event is InputEventMouseButton && event.is_action_pressed("right_click")):
		var sendPos = get_viewport().get_mouse_position()
		print("new target pos is: %s" % sendPos)
		if Online.Online:
			rpc("rpc_setTargetPos", sendPos)
			
		targetPos = sendPos
	pass

# Called when the node enters the scene tree for the first time.
func _process(delta):
	var pos = position
	var isMaster = Online.IsMaster;
	if(not Online.IsMaster):
		return
	
	var move = Vector2.ZERO
	if(position != targetPos):
		var moveDir = targetPos - position
		if(moveDir.length() < speed * delta):
			set_position(targetPos)
		else:
			translate(moveDir.normalized() * speed * delta)
	else:
		return
	
	if Online.Online:
		rpc_unreliable("rpc_sendPosition", position)
	pass

func init(id):
	self.id = id;
	targetPos = position
	pass

remote func rpc_sendPosition(position):
	set_position(position)
	print("Received position %s" % position)
	pass

remote func rpc_setTargetPos(position):
	targetPos = position
	print("Received target position  %s" % position)
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
