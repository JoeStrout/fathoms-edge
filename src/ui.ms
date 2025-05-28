// User interface, mostly drawn in gfx.

import "importUtil"
ensureImport "stringUtil"
ensureImport "bmfFonts"
ensureImport "styledText"
ensureImport "textUtil"
ensureImport "uiInventoryPanel"
ensureImport "gui"

Image9Slice = gui.Image9Slice

smallPrinter = new styledText.BmfPrinter
smallPrinter.font = bmfFonts.Font.load("/sys/fonts/NotoSans-14.bmf")
smallPrinter.italicFont = bmfFonts.Font.load("/sys/fonts/NotoSansItalic-14.bmf")
smallPrinter.boldFont = bmfFonts.Font.load("/sys/fonts/NotoSansBold-14.bmf")
smallPrinter.boldItalicFont = bmfFonts.Font.load("/sys/fonts/NotoSansBoldItalic-14.bmf")

button9Slice = Image9Slice.make(file.loadImage("/usr/pics/button.png"))

keyCapCode = 57344 // plus the ASCII value of the character

textColor = "#88FF88"

damColor = {
	"physical": "#AAAAAA", 
	"fire": "#AAFF00",
	"cold": "#8888FF", 
	"shock": "#FFFF00",
	"poison": "#44FF44",
	"necrotic": "#000000" }

tempG = new PixelDisplay

log = []  // list of [turn number, message] pairs

logGfx = new PixelDisplay
logGfxDirty = true

keyCap = function(asciiChar)
	return char(asciiChar.code + keyCapCode)
end function

addKeyCapGlyphs = function
	kpic = file.loadImage("/usr/pics/keyCaps.png")
	w = kpic.width / 16
	h = kpic.height / 8
	for row in range(0, 7)
		for col in range(0, 15)
			idx = row * 16 + col
			globals.charpic = kpic.getImage(col*w, (7-row)*h, w, h)
			c = char(keyCapCode + idx)
			smallPrinter.font.addChar c, charpic, 0, 3
		end for
	end for
end function
addKeyCapGlyphs

_printToImage = function(styleRuns, bgColor="#000000", width=300, printer=null)
	if printer == null then printer = smallPrinter
	tempG.clear bgColor, width, 512
	tempG.color = gfx.color
	printer.wrapTo = 8
	printer.wrapAt = width - 8
	printer.x = printer.wrapTo
	printer.y = tempG.height - printer.font.lineHeight
	oldGfx = gfx; globals.gfx = tempG
	printer.printStyleRuns styleRuns
	globals.gfx = oldGfx
	return tempG.getImage(0, printer.y, tempG.width, tempG.height - printer.y)
end function

Button = {}
Button.normalColor = "#88CC88"
Button.hoverColor = "#AAFFAA"
Button.pressedColor = "#44AA44"
Button.textColor = "#000000"
Button.x = 480
Button.y = 320
Button.width = 80
Button.height = 28
Button.caption = "Button"
Button.wasPressed = false
Button.wasHovered = false
Button.action = null
Button.shortcutKeys = null

Button.Make = function(caption="Button", x=480, y=320, keys=null)
	noob = new self
	noob.caption = caption
	noob.x = x
	noob.y = y
	if keys isa string then keys = [keys]
	if keys then noob.shortcutKeys = keys
	return noob
end function

Button.contains = function(xy)
	hw = self.width/2
	hh = self.height/2
	return self.x - hw <= xy.x <= self.x + hw and
	  self.y - hh <= xy.y <= self.y + hh
end function

Button.draw = function(hovered=false, pressed=false)
	if pressed then
		c = self.pressedColor
	else
		if hovered then c = self.hoverColor else c = self.normalColor
	end if
	button9Slice.draw gfx, self.x - self.width/2, self.y - self.height/2,
	  self.width, self.height, c
	f = smallPrinter.boldFont
	f.printCentered self.caption, self.x, self.y - f.lineHeight/2 + 2, 1, self.textColor
	self.wasPressed = pressed
	self.wasHovered = hovered
end function

Button.update = function
	hovered = self.contains(mouse)
	if hovered != self.wasHovered then self.draw hovered
	if hovered and mouse.button then
		// track until mouse-up!
		self.draw true, true
		while mouse.button
			yield
			stillOver = self.contains(mouse)
			if stillOver != self.wasPressed then self.draw false, stillOver
		end while
		if self.wasPressed then self.action
		self.draw self.contains(mouse)
	end if
end function

Button.handleKey = function(keyPressed)
	if not self.shortcutKeys then return false
	for k in self.shortcutKeys
		if k == keyPressed then
			self.draw false, true
			wait 0.1
			self.draw
			wait 0.1
			self.action
			return true
		end if
	end for
	return false
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
	dy = 20
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

	y -= dy/2
	font.print "Resistances:", x, y, 1, gfx.color
	y -= dy
	column = 0
	gotAny = false
	for type in damType.types
		r = player.resistance[type]
		if r then
			c = damColor[type]
			font.print type.capitalized + ": " + r + "%", x + 12 + 114*column, y, 1, c
			column = not column
			if column == 0 then y -= dy
			gotAny = true
		end if
	end for
	if not gotAny then font.print "None", x + 12, y, 1, gfx.color
	y -= dy

	c = "#CCCCCC"
	y -= dy; font.print keyCap("I") + " - Inventory", x, y, 1, c
	y -= dy; font.print keyCap("T") + " - Target", x, y, 1, c
	y -= dy; font.print keyCap("K") + " - Attack", x, y, 1, c
	y -= dy; font.print keyCap("C") + " - Cast", x, y, 1, c
	
	if logGfxDirty then
		oldGfx = gfx
		globals.gfx = logGfx
		gfx.clear "#222222", w-8, 200
		y = 4 - font.lineHeight
		for i in range(log.len - 1, 0, -1)
			entry = log[i]
			if entry[0] >= turn-1 then gfx.color = "#CCFFCC" else gfx.color = "#888888"
			msg = "[{0}] {1}".fill(entry)
			dy = smallPrinter.calcHeight(msg, 0, logGfx.width, 0)
			smallPrinter.print msg, 0, y + dy, logGfx.width, 0
			y += dy
		end for
		globals.gfx = oldGfx
		outer.logGfxDirty = false
	end if
	gfx.drawImage logGfx.getImage, left+4, 4
	
end function

showAlert = function(message, title="")
	runs = styledText.parseMarkup(message)
	gfx.color  = textColor
	img = _printToImage(runs)
	for scale in range(0.1, 0.9, 0.1)
		w = img.width * scale
		h = (img.height + 40) * scale
		x = 480 - w/2
		y = 320 - h/2
		gfx.drawImage img, x, y, w, h
		yield
	end for
	w = img.width
	h = img.height + 40
	x = 480 - w/2
	y = 320 - h/2
	gfx.fillRect x-8, y-8, w+16, h+16, "#000000"
	gfx.drawImage img, x, y + 40
	gfx.drawRect x-5, y-5, w+10, h+10, "#FFFFFF", 5		
	btn = Button.Make("OK", 480, y + 16, [" ", char(27), char(13), char(10)])
	btn.draw
	done = false
	btn.action = function; outer.done = true; end function
	while not done
		yield
		btn.update
		if key.available then btn.handleKey(key.get)
	end while
	gfx.fillRect x-8, y-8, w+16, h+16, color.clear
end function

addLogMessage = function(msg)
	log.push [turn, msg]
	if log.len > 10 then log.pull
	outer.logGfxDirty = true
end function

showInventory = function(container, title="Inventory")
	uiInventoryPanel.show container, title
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
	  " We can show keys like " + keyCap("A") + " or " + keyCap("?") +
	  " too.  Pretty ~~rad~~ ##useful##, amiright?"
end function

if locals == globals then
	demo
end if