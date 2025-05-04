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
	
	Shroom = new Item
	Shroom.name = "shroom"
	Shroom.image = file.loadImage("/usr/pics/shroom.png")
	Shroom.Colors = [color.red, color.green, color.brown, color.yellow,
	  "#CCCCFF", "#CCCCCC", "#CCCCAA"]
	
	for i in range(5)
		shroom = new Shroom
		shroom.color = Shroom.Colors.any
		shroom.placeOnMap floor(40*rnd), floor(30*rnd)
	end for
	
	player.placeOnMap 15, 10
end function

