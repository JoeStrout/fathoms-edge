// User interface, mostly drawn in gfx.

import "importUtil"
ensureImport "stringUtil"
ensureImport "bmfFonts"
ensureImport "styledText"
ensureImport "textUtil"

smallPrinter = new styledText.BmfPrinter
smallPrinter.font = bmfFonts.Font.load("/sys/fonts/NotoSans-14.bmf")
smallPrinter.italicFont = bmfFonts.Font.load("/sys/fonts/NotoSansItalic-14.bmf")
smallPrinter.boldFont = bmfFonts.Font.load("/sys/fonts/NotoSansBold-14.bmf")
smallPrinter.boldItalicFont = bmfFonts.Font.load("/sys/fonts/NotoSansBoldItalic-14.bmf")

textColor = "#88FF88"

tempG = new PixelDisplay

_printToImage = function(styleRuns, bgColor="#000000", width=300, printer=null)
	if printer == null then printer = smallPrinter
	tempG.clear bgColor, width, 512
	tempG.color = gfx.color
	printer.wrapTo = 8
	printer.wrapAt = width - 8
	printer.x = printer.wrapTo
	printer.y = tempG.height - printer.font.lineHeight
	oldGfx = gfx; globals.gfx = tempG
	print "start y: " + printer.y
	printer.printStyleRuns styleRuns
	globals.gfx = oldGfx
	print "end y: " + printer.y
	return tempG.getImage(0, printer.y, tempG.width, tempG.height - printer.y)
end function

drawRightPanel = function
	// Draw the panel on the right that shows game/player info.
	w = 248
	h = 640
	left = 960 - w
	midx = left + w/2
	bottom = 0
	gfx.fillRect left, bottom, w, h, "#222222"
	gfx.drawRect left, bottom, w, h, "#CCCCCC"
	gfx.color = "#CCCCCC"
	font = smallPrinter.font
	dy = 24
	x = left + 8
	rx = left + w - 8
	y = bottom + h - 20
	c = gfx.color
	font.print "Turn: " + turn, x, y, 1, c
	font.printRight "Loc: " + player.x + ", " + player.y, rx, y, 1, c
	y -= dy
	font.print "Health: " + player.health, x, y, 1, c
	y -= dy
	for st in player.statuses.all
		font.print st, x, y, 1, c
		y -= dy
	end for
		
end function

showAlert = function(message)
	runs = styledText.parseMarkup(message)
	gfx.color  = textColor
	img = _printToImage(runs)
	for scale in range(0.1, 0.9, 0.1)
		w = img.width * scale
		h = img.height * scale
		x = 480 - w/2
		y = 320 - h/2
		gfx.drawImage img, x, y, w, h
		yield
	end for
	x = 480 - img.width/2
	y = 320 - img.height/2
	gfx.fillRect x-8, y-8, img.width+16, img.height+16, "#000000"
	gfx.drawImage img, x, y
	gfx.drawRect x-5, y-5, img.width+10, img.height+10, "#FFFFFF", 5		
end function

addLogMessage = function(msg)
	// Hacky implementation for now:
	text.row = 0
	text.color = color.gray
	print "[" + turn + "] ", ""
	text.color = color.silver
	print msg, ""
	textUtil.clearToEOL
	text.column = 0
end function

showInventory = function(container, title="Inventory")
	rowHeight = 18
	items = container.contents
	if items == null then items = []
	h = rowHeight * (items.len + 3)
	w = 300
	left = 480 - w/2
	bottom = 320 - h/2
	gfx.fillRect left, bottom, w, h, "#000000"
	gfx.drawRect left+3, bottom+3, w-6, h-6, "#FFFFFF", 5
	y = bottom + h - 20
	smallPrinter.boldFont.printCentered title, left+w/2, y, 1, textColor
	y -= rowHeight*1.5
	for item in items
		item.drawIcon gfx, left + 12, y - 2
		smallPrinter.boldFont.print "- " + item.nameWithArticle, 
		  left + 30, y, 1, textColor
		y -= rowHeight
	end for
	key.get
	gfx.fillRect left, bottom, w, h, color.clear
end function

update = function
	drawRightPanel
end function

demo = function
	clear
	gfx.clear
	display(7).color = "#4444CC"
	showAlert "This is a test of `showAlert`.  As you can see, " +
	  "it supports *bold*, _italic_, and even *_bold italic_* text!" +
	  "  Pretty ~~rad~~ ##useful##, amiright?"
end function

if locals == globals then
	demo
end if