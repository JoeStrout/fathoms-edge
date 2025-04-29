// Module to manage the display system.
//
//	7. background tiles
//	6. main tiles (obstacles etc.)
//	5. sprite
//	4. overlay tiles
//	3. gfx
//	2. text

import "importUtil"
ensureImport "oneBit"


init = function
	clear
	
	outer.background = oneBit.prepareTileDisplay(7, 32, null, null, true)
	
	outer.main = oneBit.prepareTileDisplay(6, 32, null, null, true)
	
	display(5).mode = displayMode.sprite
	outer.sprite = display(5)
	sprite.clear
	
	outer.overlay = oneBit.prepareTileDisplay(4, 32, null, null, true)
	
	display(3).mode = displayMode.pixel
	outer.gfx = display(3)
	globals.gfx = gfx
	gfx.clear
	
	display(2).mode = displayMode.text
	outer.text = display(2)
	globals.text = text
	text.clear
	
	for d in [background, main, overlay, sprite, gfx]
		d.scrollX = 0
		d.scrollY = 0
	end for
end function


init