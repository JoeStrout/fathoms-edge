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

connectPortal = function(x, y, targetZone, targetX, targetY)
	// First, confirm that the map actually has a portal at that location
	elem = zone.element(x, y)
	tileName = elem.name
	if tileName != "caveEntrance" then
		print "OOPS!  Expected some portal at " + x + "," + y +
		  ", but found " + tileName + " (#" + elem.id + ") instead."
		exit
	end if
	// Then, add the portal to the map.
	portal = Portal.Make(targetZone, targetX, targetY, 0)
	portal.placeOnMap x, y
end function

load = function
	zone.elemPalette = MapElement.LoadFromFile(palettePath)
	zone.loadElemMap zonePath

	Bone.Make.placeOnMap 2, 0
	
	chest = Chest.Make
	chest.placeOnMap 0, 4
	chest.contain DiamondRing.Make	
	item = Amulet.Make; item.resistance.shock = 5; chest.contain item	
	chest.contain Bread.Make	
	chest.contain Buckler.Make
	
	connectPortal 6, 4, "town", 8, 3
	
	player.placeOnMap 6, 4
end function

