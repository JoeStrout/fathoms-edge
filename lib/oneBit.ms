// OneBit module -- support code for working with the
// amazing set of icons at /sys/pics/1bitTiles.png

import "qa"

oneBitImage = file.loadImage("/sys/pics/1bitTiles.png")

_indexToImageMap = {}  // key: index; value: 16x16 tile image

getTileImage = function(indexOrName)
	if indexOrName isa string then
		qa.assert _nameToIndexMap.hasIndex(indexOrName),
		  "getTileImage: """ + indexOrName + """ is not a known name"
		indexOrName = _nameToIndexMap[indexOrName]
	end if
	if not _indexToImageMap.hasIndex(indexOrName) then
		row = 31 - floor(indexOrName / 32)
		column = indexOrName % 32
		p = oneBitImage.getImage(column*16, row*16, 16, 16)
		_indexToImageMap[indexOrName] = p
	end if
	return _indexToImageMap[indexOrName]
end function

_nameToIndexMap = {}  // key: name; value: tile index
nameTile = function(index, name)
	_nameToIndexMap[name] = index
end function

nameTile 0, " "
for i in range(0, 9)
	nameTile 947+i, str(i)
end for
for i in range(0, 25)
	c = char(65 + i)  // e.g. "A"
	if c < "N" then idx = 979 + i else idx = 1011 + i-13
	nameTile idx, c
	nameTile idx, c.lower
end for
nameTile 915, "$"
nameTile 916, "¢"
nameTile 957, ":"
nameTile 958, "."
nameTile 979, "%"
nameTile 819, "!"
nameTile 821, "?"

prepareTileDisplay = function(dispIndex=4, cellSize=16, columns=null, rows=null, compact=false)
	display(dispIndex).mode = displayMode.tile
	d = display(dispIndex)
	d.tileSet = oneBitImage
	d.tileSetTileSize = 16
	if columns == null then columns = round(960/cellSize)
	if rows == null then rows = round(640/cellSize)
	d.extent = [columns, rows]
	d.cellSize = cellSize
	if compact then d.overlap = 2 else d.overlap = 0
	d.clear
	return d	
end function

_lastx = 0
_lasty = 0
print = function(s, x=null, y=null, disp=null, tint="#FFFFFF")
	if disp == null then
		for i in range(0, 7)
			if display(i).mode == displayMode.tile then
				disp = display(i)
				break
			end if
		end for
		qa.assert disp, "print: No display prepared"
	end if
	if x != null then _lastx = x
	if y != null then _lasty = y
	for c in s
		if not _nameToIndexMap.hasIndex(c) then continue
		if _lastx > disp.extent[0] then
			_lastx = 0
			_lasty -= 1
			if _lasty < 0 then _lasty = 0
		end if
		disp.setCell _lastx, _lasty, _nameToIndexMap[c]
		disp.setCellTint _lastx, _lasty, tint
		_lastx += 1
	end for	
end function	

min = function(a,b); if a < b then return a else return b; end function
max = function(a,b); if a > b then return a else return b; end function
clamp = function(v,a,b)
	if v < a then return a
	if v > b then return b
	return v
end function

_lastCol = 4; _lastRow = 27
findTile = function
	col = _lastCol; row = _lastRow
	oldLayer0 = display(0)
	disp = new PixelDisplay
	disp.install 0
	left = 100
	bottom = 32
	cs = 16*4  // cell size, on screen
	while true
		yield
		disp.clear
		c0 = max(col-4, 0)
		c1 = min(col+4, 32)
		r0 = max(row-4, 0)
		r1 = min(row+4, 32)
		subimg = oneBitImage.getImage(c0*16, r0*16,
		  (c1-c0+1)*16, (r1-r0+1)*16)
		disp.drawImage subimg, 
		  left - cs*(min(col-4, 0)), 
		  bottom - cs*(min(row-4, 0)),
		  subimg.width * 4, subimg.height * 4
		disp.color = "#AAAAFF"
		for x in range(left, left+cs*9, cs)
			disp.line x, bottom, x, bottom+cs*9
		end for
		for y in range(bottom, left+cs*9, cs)
			disp.line left, y, left+cs*9, y
		end for
		disp.drawRect left + cs*4, bottom + cs*4, cs, cs, "#FFFFAA", 3
		idx = (31 - row) * 32 + col
		disp.drawImage getTileImage(idx), 
		  left + cs*10, 320 - 64, 128, 128
		disp.drawRect left + cs*10, 320 - 64, 128, 128
		disp.print idx, 780, 320 - 100, disp.color, "large"
		s = (col)*16 + "," + row*16 + ", 16,16"
		disp.print s, 750, 320 - 140, disp.color, "small"
		if key.available then
			k = key.get.code
			if k == 10 or k == 13 or k == 27 then
				break
			else if k == 17 then
				col = max(col - 1, 0)
			else if k == 18 then
				col = min(col + 1, 31)
			else if k == 19 then
				row = min(row + 1, 31)
			else if k == 20 then
				row = max(row - 1, 0)
			end if
		else if mouse.button then
			row = clamp(row + floor((mouse.y - bottom)/cs) - 4, 0, 31)
			col = clamp(col + floor((mouse.x - left)/cs) - 4, 0, 31)
			while mouse.button; yield; end while
		end if
	end while
	outer._lastCol = col; outer._lastRow = row
	oldLayer0.install 0
	if oldLayer0.mode == 0 then display(0).mode = 0
	return idx
end function

if locals == globals then
	// When running in global space, don't clobber
	// the standard 'print' function.  
	// Call ours 'tilePrint' instead.
	tilePrint = @print
	globals.remove "print"
	clear
	prepareTileDisplay 5
	tilePrint "Use arrow keys to explore the tile set!", 4, 39, null, color.aqua
	tilePrint "Press Esc when finished.", 12, 1, null, color.silver
	findTile
	clear
	text.row = 0
end if
