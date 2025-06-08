// This is a secondary main program (i.e., run this file directly)
// for editing maps.

import "disp"
import "mapElement"
import "zone"
import "textUtil"
Dialog = textUtil.Dialog

tempG = new PixelDisplay
foreId = 1
backId = 0
centerCol = 13
centerRow = 11

palettePath = "/usr/data/mapElements.tsv"
zonePath = "/usr/data/town.dat"

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
		if i < zone.elemPalette.len then elem = zone.elemPalette[i] else elem = null
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
	col = disp.colForScreenX(mouse.x)
	row = disp.rowForScreenY(mouse.y)
	shift = key.pressed("left shift") or key.pressed("right shift")
	alt = key.pressed("left alt") or key.pressed("right alt")
	if shift or zone.element(col,row) == zone.elemPalette[foreId] then
		penId = backId
	else
		penId = foreId
	end if
	lastCol = -1; lastRow = -1
	while mouse.button
		yield
		col = disp.colForScreenX(mouse.x)
		row = disp.rowForScreenY(mouse.y)
		if col == lastCol and row == lastRow then continue
		lastCol = col; lastRow = row
		if alt then
			idx = zone.element(col, row).id
			if idx < 0 then continue
			if shift then globals.backId = idx else globals.foreId = idx
			drawSwatches
		else
			zone.setElement col, row, penId
			zone.elemPalette[penId].apply col, row
		end if
	end while
end function

drawSwatch = function(elemId, left=820, bottom=20, label="Draw to:")
	w = 32
	h = 32
	gfx.fillRect left-20, bottom-20, w+40, h+40, color.clear
	pic = null
	if elemId < zone.elemPalette.len and zone.elemPalette[elemId] then
		tempG.clear color.black, 16, 16
		zone.elemPalette[elemId].drawPaletteEntry 0, 0, tempG
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

drawMouseInfo = function(left = 780, bottom = 600)
	w = 960 - left - 8
	h = 640 - bottom - 8
	gfx.fillRect left, bottom, w, h, color.black
	idx = -1
	if palPos.contains(mouse) then
		row = floor((palPos.top - mouse.y) / 16)
		col = floor((mouse.x - palPos.left) / 16)
		idx = row * 8 + col
		name = "(null)"
		if idx < zone.elemPalette.len then
			elem = zone.elemPalette[idx]
			if elem then name = elem.name
		end if		
		gfx.print "MapElement:", left+2, bottom+h-16, color.silver, "small"
	else
		col = disp.colForScreenX(mouse.x)
		row = disp.rowForScreenY(mouse.y)
		elem = zone.element(col, row)
		if elem then
			idx = elem.id
			name = elem.name
			gfx.print "Pos: " + col + ", " + row, left+2, bottom+h-16, color.silver, "small"
		end if
	end if
	if idx >= 0 then
		gfx.print hex2(idx) + " (" + idx + "): " + name[:13],
		  left+2, bottom+2, color.silver, "small"
	end if
end function

handleKey = function(k)
	if k == "s" then
		zone.saveElemMap zonePath
		Dialog.make("Map Saved", zonePath).show
	else if k == "q" or k == char(27) then
		dlog = Dialog.make("Quit the map editor?", "Any unsaved changes will be lost.")
		dlog.okBtn.caption = "Quit"
		dlog.cancelBtn.visible = true
		if dlog.show == dlog.cancelBtn then return
		exit
	else if char(17) <= k <= char(20) then  // arrow: scroll
		outer.centerCol += (k == char(18)) - (k == char(17))
		outer.centerRow += (k == char(19)) - (k == char(20))
		disp.centerOn centerCol, centerRow
	end if
end function

setup = function
	zone.elemPalette = MapElement.LoadFromFile(palettePath)

	prevDir = file.curdir
	file.setdir "/usr/data"
	dlog = textUtil.FileDialog.make("Select zone (.dat) file", 64)
	dlog.title += ", or Cancel for new"
	hit = dlog.show
	file.setdir prevDir
	if hit == dlog.cancelBtn then
		name = input("Enter new zone (.dat) file name: ")
		if not name then exit
		if not name.endsWith(".dat") then name += ".dat"
		outer.zonePath = "/usr/data/" + name
		width = input("Width: ").val
		height = input("Height: ").val
		if width < 1 or height < 1 then
			print "Width and height must be at least 1."
			exit
		end if
		zone.clearToSize width, height, 0
		text.clear
	else
		outer.zonePath = dlog.selection
		zone.loadElemMap zonePath
	end if

	drawPalette
	drawSwatches
end function

mainLoop = function
	while true
		yield
		if mouse.button then
			if not handlePaletteClick then handleMapClick
		end if
		if key.available then handleKey key.get
		drawMouseInfo
	end while
end function


if locals == globals then
	setup
	mainLoop
else
	print "Why are you importing mapEditor?  It's meant to be run directly."
end if
