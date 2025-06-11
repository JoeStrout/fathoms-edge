// This module builds the map of Fathom's Edge (the home town).

import "importUtil"
ensureImport "disp"
ensureImport "mapTools"
ensureImport "zone"
ensureImport "status"
ensureImport "conversation"
ensureImport "commonItems"
ensureImport "commonMobs"

palettePath = "/usr/data/mapElements.tsv"
zonePath = "/usr/data/grotto.dat"


load = function
	palette = MapElement.LoadFromFile(palettePath)
	zone.current = Zone.LoadMapElems(palette, zonePath)

	Bone.Make.placeOnMap 2, 0
	
	chest = Chest.Make
	chest.placeOnMap 0, 4
	chest.contain DiamondRing.Make	
	item = Amulet.Make; item.resistance.shock = 5; chest.contain item	
	chest.contain Bread.Make	
	chest.contain Buckler.Make
	
	zone.current.connectPortal 6, 4, "town", 8, 3, "You exit the cave."
	
	player.placeOnMap 6, 4
	zone.current.activate
end function

