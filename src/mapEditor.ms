// This is a secondary main program (i.e., run this file directly)
// for editing maps.

import "disp"
import "mapElement"

tempG = new PixelDisplay
foreId = 1
backId = 0

Rect = {}
Rect.Make = function(left, bottom, width, height)
	r = new Rect
	r.left = left
	r.bottom = bottom
	r.width = width
	r.height = height
	r.right = left + width
	r.top = bottom + height
	return r
end function
Rect.contains = function(pos)
	return self.left <= pos.x < self.right and self.bottom <= pos.y < self.top
end function

drawPalette = function(left=800, bottom=80)
	globals.palPos = Rect.Make(left, bottom, 8*32, 16*32)
	for i in range(0, 255)
		row = floor(i / 8)
		col = i % 8
		x = left + col*16
		y = palPos.top - (row+1) * 16
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

handlePaletteClick = function
	if not palPos.contains(mouse) then return false
	prevIdx = -1
	shift = key.pressed("left shift") or key.pressed("right shift")
	while mouse.button
		yield
		row = floor((palPos.top - mouse.y) / 16)
		col = floor((mouse.x - palPos.left) / 16)
		idx = row * 8 + col
		if idx == prevIdx then continue
		if shift then globals.backId = idx else globals.foreId = idx
		drawSwatches
		prevIdx = idx
	end while
	return true
end function

handleMapClick = function
	
end function

drawSwatch = function(elemId, left=820, bottom=20, label="Draw to:")
	w = 32
	h = 32
	gfx.fillRect left-20, bottom-20, w+40, h+40, color.clear
	pic = null
	if elemId < mapElements.len and mapElements[elemId] then
		tempG.clear color.black, 16, 16
		mapElements[elemId].drawPaletteEntry 0, 0, tempG
		pic = tempG.getImage
	end if
	gfx.fillRect left, bottom, w, h, color.black
	if pic == null then
		gfx.line left, bottom, left+32, bottom+32, color.red
		gfx.line left+32, bottom, left, bottom+32, color.red
	else
		gfx.drawImage pic, left, bottom, w, h
	end if
	gfx.drawRect left-1, bottom-1, w+2, h+2, color.silver, 3
	gfx.print label, left + w/2 - label.len*4, bottom + h + 3, color.silver, "small"
	s = hex2(elemId) + " (" + elemId + ")"
	gfx.print s, left + w/2 - s.len*4, bottom - 18, color.silver, "small"
end function

drawSwatches = function
	drawSwatch foreId, 810, 20, "Draw:"
	drawSwatch backId, 890, 20, "Erase:"
end function

setup = function
	globals.mapElements = MapElement.LoadFromFile("/usr/data/mapElements.tsv")
	drawPalette
	drawSwatches
end function

mainLoop = function
	while true
		yield
		if mouse.button then
			handlePaletteClick
		end if
	end while
end function


if locals == globals then
	setup
	mainLoop
else
	print "Why are you importing mapEditor?  It's meant to be run directly."
end if
