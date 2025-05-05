// This module builds the map of Fathom's Edge (the home town).

import "importUtil"
ensureImport "disp"
ensureImport "mapTools"
ensureImport "level"

load = function
	level.clearToSize 40, 30
	mapTools.fillTiles disp.background, [1,5,5,5], "#006600", 50
	
	bone = Item.Make("bone")
	bone.iconIdx = 784
	bone.color = "#CCCCCC"
	bone.size = 2
	bone.placeOnMap 8, 3
	
	apple = Food.Make("apple")
	apple.iconIdx = 943
	apple.color = "#FF4444"
	apple.value = 2
	apple.placeOnMap 10, 15
	
	Shroom = Food.Make("shroom")
	Shroom.image = file.loadImage("/usr/pics/shroom.png")
	Shroom.Colors = [color.red, color.green, color.brown, color.yellow,
	  "#CCCCFF", "#CCCCCC", "#CCCCAA"]
	Shroom.size = 1
	Shroom.value = 1
	
	for i in range(5)
		shroom = new Shroom
		shroom.color = Shroom.Colors.any
		shroom.placeOnMap floor(40*rnd), floor(30*rnd)
	end for
	
	player.placeOnMap 15, 10
end function

