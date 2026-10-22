import json

class Level:
    gridHeight = 8
    gridWidht = 8
    nbDifferentBlocks = 4
    conditions = [["chardon",1]]
    numberMovesLeft = 1
    gridEmptyTiles = []
    gridLierre = []
    gridRonce = []
    gridCollectable = []
    fixedBlocks = []

    def toDict(self):
        return {
            "conditions": self.conditions,
            "fixedBlocks": self.fixedBlocks,
            "gridEmptyTiles": self.gridEmptyTiles,
            "gridHeight": self.gridHeight,
            "gridCollectable": self.gridCollectable,
            "gridLierre": self.gridLierre,
            "gridRonce": self.gridRonce,
            "gridWidth": self.gridWidht,
            "nbDifferentBlocks": self.nbDifferentBlocks,
            "numberMovesLeft": self.numberMovesLeft
        }

    def __str__(self):
        return json.dumps(self.toDict())