// This is a secondary main program (i.e., run this file directly)
// for editing maps.

import "disp"
import "mapElement"

drawPalette = function(left=800, bottom=50)
	top = bottom + 32 * 16
	for i in range(0, 255)
		row = floor(i / 8)
		col = i % 8
		x = left + col*16
		y = top - (row+1) * 16
		if col == 0 then
			gfx.print hex2(i), x - 20, y + 1, color.silver, "small"
		end if
		if i < mapElements.len then elem = mapElements[i] else elem = null
		if elem == null then
			gfx.line x, y, x+16, y+16, color.red
			gfx.line x+16, y, x, y+16, color.red			
		else
			elem.drawPaletteEntry x, y
		end if
		gfx.drawRect x, y, 17, 17, color.silver
	end for	
end function

setup = function
	globals.mapElements = MapElement.LoadFromFile("/usr/data/mapElements.tsv")
	drawPalette
end function

mainLoop = function

end function


if locals == globals then
	setup
	mainLoop
else
	print "Why are you importing mapEditor?  It's meant to be run directly."
end if
