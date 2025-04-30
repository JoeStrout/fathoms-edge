// Utility functions and classes for creating and managing
// the game map.


import "importUtil"
ensureImport "oneBit"
ensureImport "disp"
ensureImport "listUtil"

fillTiles = function(tileDisp, indexOptions, color="#FFFFFF", fillPercent=100)
	for x in range(0, tileDisp.extent[0]-1)
		for y in range(0, tileDisp.extent[1]-1)
			if rnd * 100 > fillPercent then
				tileDisp.setCell x, y, null
				tileDisp.setCellTint x, y, "#FFFFFF"
			else
				tileDisp.setCell x, y, indexOptions.any
				tileDisp.setCellTint x, y, color
			end if
		end for
	end for
end function

demo = function
	fillTiles disp.background, [1,5,5,5], "#006600", 75
end function


if locals == globals then
	demo
end if
