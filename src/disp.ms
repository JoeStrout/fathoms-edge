// Module to manage the display system.
//
//  7. background color tiles
//	6. background tiles
//	5. main tiles (obstacles etc.)
//	4. sprite (player, mobs, things on the map)
//	3. overlay tiles
//	2. gfx (constant game UI layer)
//	1. dialogs (temporary, blocking UI layer)
//	0. text (only used for debugging)

clear
import "importUtil"
ensureImport "oneBit"

cellSize = 30

init = function
	clear
	
	outer.bgColor = oneBit.prepareTileDisplay(7, 32, null, null, true)
	bgColor.tileSet = Image.create(16, 16, color.white)
	bgColor.clear 0
	bgColor.setCellTint range(0, bgColor.extent[0]), range(0, bgColor.extent[1]), color.black
	
	outer.background = oneBit.prepareTileDisplay(6, 32, null, null, true)
	
	outer.main = oneBit.prepareTileDisplay(5, 32, null, null, true)
	outer.cellSize = main.cellSize - main.overlap
	
	display(4).mode = displayMode.sprite
	outer.sprite = display(4)
	sprite.clear
	
	outer.overlay = oneBit.prepareTileDisplay(3, 32, null, null, true)
	
	display(2).mode = displayMode.pixel
	outer.gfx = display(2)
	globals.gfx = gfx
	gfx.clear
	
	display(1).mode = displayMode.pixel
	outer.dialog = display(1)
	dialog.clear
	
	display(0).mode = displayMode.text
	outer.text = display(0)
	globals.text = text
	text.backColor = color.clear
	text.color = color.orange
	text.clear
	
	for d in [bgColor, background, main, overlay, sprite, gfx]
		d.scrollX = 0
		d.scrollY = 0
	end for
end function

positionSprite = function(sprite, column, row)
	sprite.x = cellSize * column + cellSize/2
	sprite.y = cellSize * row + cellSize/2
	sprite.z = column/1000 - row
end function

centerOn = function(column, row)
	sx = (column - 13) * cellSize
	sy = (row - 11) * cellSize
	for d in [bgColor, background, main, overlay, sprite]
		d.scrollX = sx
		d.scrollY = sy
	end for
end function

colForScreenX = function(screenX)
	return floor((screenX + main.scrollX) / cellSize)
end function

rowForScreenY = function(screenY)
	return floor((screenY + main.scrollY) / cellSize)
end function

fadeInOut = function(startAlpha, endAlpha)
	display(0).mode = displayMode.solidColor
	for alpha in range(startAlpha, endAlpha, 4*sign(endAlpha - startAlpha))
		display(0).color = color.rgba(0, 0, 0, alpha)
		yield
	end for
	if endAlpha < 1 then
		display(0).mode = displayMode.text
	end if
end function

fadeOut = function; fadeInOut 0, 255; end function
fadeIn = function; fadeInOut 255, 0; end function

init
