extends Node

class ProcDunjSorter:
	static func sort_by_size_varied(a: Rect2, b: Rect2):
		if !a.intersects(b):
			return true
		return false

func GenerateDungeon(room_count, max_width, max_height, radius, seed_i, min_width = 0, min_height = 0) -> Array:
	# Setup random seed, were aiming for repeatable results given a seed
	seed(seed_i)
	
	var rooms : Array
	
	CreateRooms(rooms, room_count, max_width, max_height, radius, min_width, min_height)
	SeparateRooms(rooms)
	
	
	return rooms


func RandomPointInCircle(radius) -> Vector2:
	var Theta : float = 2 * PI * randf()
	var point_radius : float = radius * sqrt(randf())
	var point = Vector2(SnapPointOnGrid(point_radius * cos(Theta), Globals.TILE_SIZE),
						SnapPointOnGrid(point_radius * sin(Theta), Globals.TILE_SIZE))
	return point.floor()

func SnapPointOnGrid(n, m) -> int: # Returns the increment of m clostest to n (even 0) 
	return floor(((n + m - 1)/m))*m

func CreateRooms(rooms: Array, room_count: int, max_width, max_height, radius, min_width, min_height) -> void:
	for i in room_count:
		var room = Rect2()
		while room.size.length() == 0 || room.size.y / room.size.x <= 0.5 || room.size.x / room.size.y <= 0.5 || \
		room.size.x < min_width || room.size.y / room.size.x == 1 || room.size.y < min_height:
			room.size = Vector2(max(min_width,SnapPointOnGrid(randi() % max_width, Globals.TILE_SIZE)), max(min_height,SnapPointOnGrid(randi() % max_height, Globals.TILE_SIZE))) ## May need to revert to units from pixels
		room.position = RandomPointInCircle(radius)
		rooms.push_back(room)

func SeparateRooms(rooms: Array) -> void:
	var were_good = false
	rooms.sort_custom(ProcDunjSorter, "sort_by_size_varied")
	while !were_good:
		for i in range(0, rooms.size()):
			var v_dir = Vector2.ZERO
			var neighbors_ct : int
			var neighbor_radius = rooms[i].size.length() * 2
			var neighbor_box = Rect2(rooms[i].position - Vector2(neighbor_radius,neighbor_radius), Vector2(neighbor_radius,neighbor_radius) * 2)
			var l : float
			for j in range(0,rooms.size()):
				if j != i:
					if neighbor_box.intersects(rooms[j]):
						neighbors_ct += 1
						v_dir += rooms[j].abs().position - rooms[i].abs().position
						if rooms[j].intersects(rooms[i]):
							l = max(l, rooms[j].clip(rooms[i]).size.length())
			v_dir /= -neighbors_ct
			v_dir = v_dir.normalized() * l
			
			rooms[i].position.x = SnapPointOnGrid(rooms[i].position.x + v_dir.x, Globals.TILE_SIZE)
			rooms[i].position.y = SnapPointOnGrid(rooms[i].position.y + v_dir.y, Globals.TILE_SIZE)
			print(rooms[i].size)
		
		were_good = true
		
		for i in range(0, rooms.size()):
			for j in range(0,rooms.size()):
				if i != j:
					if rooms[i].intersects(rooms[j]):
						were_good = false
		
#	var average_avoidance = Vector2(-1,-1)
#	while average_avoidance != Vector2.ZERO:
#		average_avoidance = Vector2.ZERO
#		for j in range(rooms.size()):
#			var i = 0
#			for room in rooms:
#				var mostThreatening = findMostThreateningObstacle(rooms, i)
#				var avoidance : Vector2 = Vector2.ZERO
#
#				var room_rect = Rect2(room.position, room.size)
#				var ob_rect = Rect2(mostThreatening.position, mostThreatening.size)
#				avoidance = room_rect.clip(ob_rect).size * Vector2(-sign(mostThreatening.abs().position.x - room.abs().position.x), -sign(mostThreatening.abs().position.y - room.abs().position.y))
#
#				average_avoidance += avoidance
#
#				room.position.x = SnapPointOnGrid(room.position.x + avoidance.x, Globals.TILE_SIZE)
#				room.position.y = SnapPointOnGrid(room.position.y + avoidance.y, Globals.TILE_SIZE)
#				i += 1

func findMostThreateningObstacle(rooms, i) -> Rect2:
	var mostThreatening : Rect2
	
	var room : Rect2 = rooms[i]
	
	for j in range(i + 1, rooms.size()):
		
		var obstacle : Rect2 = rooms[j]
		var collision : bool = obstacle.intersects(room)
		
		if (collision && (mostThreatening == null || room.position.distance_to(obstacle.position) < room.position.distance_to(mostThreatening.position))):
			mostThreatening = obstacle

	return mostThreatening
