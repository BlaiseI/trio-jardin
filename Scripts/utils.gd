extends Container

func getSlideDirection(slideBeginCoords: Vector2, slideEndCoords: Vector2) -> Vector2:
	var xDif : float = slideEndCoords.x - slideBeginCoords.x
	var yDif : float = slideEndCoords.y - slideBeginCoords.y
	var ratio = abs(xDif/yDif)
	if (ratio > 2):
		if(xDif > 0):
			return Vector2(1, 0)
		else:
			return Vector2(-1, 0)
	if(ratio < 0.5):
		if(yDif>0):
			return Vector2(0, 1)
		else:
			return Vector2(0, -1)
	return Vector2(0, 0)
	
func getTileCoordsFromPosition(position: Position, grid: Grid) -> Vector2:
	var xCoord: int = grid.xStart+30 + (position.column*grid.offset)
	var yCoord: int = grid.yStart+30 + (position.row*grid.offset)
	return Vector2(xCoord,yCoord)
	
func getPositionFromTileCoords(coords: Vector2, grid :Grid) -> Position:
	if (coords.x < grid.xStart or coords.x > grid.xStart + (grid.width*grid.offset) 
		or coords.y < grid.yStart or coords.y > grid.yStart + (grid.height*grid.offset)):
		return Position.getNull()
	return Position.new( floor((coords.y - grid.yStart)/grid.offset), floor((coords.x - grid.xStart)/grid.offset))
