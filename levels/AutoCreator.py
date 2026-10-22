import json
import random
from Level import Level
from pathlib import Path


GRID_WIDTH = 8
GRID_HEIGHT = 8
firstLevel = 12
lastLevel = 15

def loadJson(fileName):
    p = Path(__file__).with_name(fileName)
    with open(p, "r") as f:
        return json.load(f)

def createRandomLevel():
    level = Level()
    return level

def saveLevel(level, ID):
    fileName = "level" + str(ID) + ".json"
    p = Path(__file__).with_name(fileName)
    with open(p, "w") as f:
        f.write(str(level))

for levelID in range(firstLevel, lastLevel+1):
    level = createRandomLevel()
    saveLevel(level, levelID)
