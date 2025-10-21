class_name Utils
extends Container

static func getSlideDirection(slideBeginCoords: Vector2, slideEndCoords: Vector2) -> Vector2:
	var xDif : float = slideEndCoords.x - slideBeginCoords.x
	var yDif : float = slideEndCoords.y - slideBeginCoords.y
	var ratio = abs(xDif/yDif)
	if (ratio > 2):
		if(xDif > 0):
			return Vector2(0, 1)
		else:
			return Vector2(0, -1)
	if(ratio < 0.5):
		if(yDif>0):
			return Vector2(1, 0)
		else:
			return Vector2(-1, 0)
	return Vector2(0, 0)

func getTileCoords(pos: Vector2, grid: Grid) -> Vector2:
	var xCoord: int = grid.xStart+30 + (pos.y*grid.offset)
	var yCoord: int = grid.yStart+30 + (pos.x*grid.offset)
	return Vector2(xCoord,yCoord)
