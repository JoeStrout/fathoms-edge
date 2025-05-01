// This module builds the map of Fathom's Edge (the home town).

import "importUtil"
ensureImport "disp"
ensureImport "mapTools"
ensureImport "level"

load = function
	level.clearToSize 40, 30
	mapTools.fillTiles disp.background, [1,5,5,5], "#006600", 50
	
	bone = new Item
	bone.name = "bone"
	bone.iconIdx = 784
	bone.color = "#CCCCCC"
	bone.placeOnMap 8, 3
	
	apple = new Item
	apple.name = "apple"
	apple.iconIdx = 943
	apple.color = "#FF4444"
	apple.placeOnMap 30, 15
	
	player.placeOnMap 15, 10
end function

