// Inventory panel: shows what you're carrying and allows you
// to use/equip/drop stuff, etc.

import "importUtil"

width = 300
rowHeight = 18

init = function
	outer.boldFont = ui.smallPrinter.boldFont
	outer.thinFont = ui.smallPrinter.font
	outer.textColor = ui.textColor
	outer.Button = ui.Button
end function

// Helper method: draw the inventory box, and return
// the set of buttons that go with the selected item.
draw = function(h, items, title, selItemIdx = -1)
	left = 480 - width/2
	xIcon = left + 12
	xName = left + 30
	xSize = left + width - 50
	xValue = left + width - 12

	bottom = 320 - h/2
	gfx.fillRect left, bottom, width, h, "#000000"
	gfx.drawRect left+3, bottom+3, width-6, h-6, "#FFFFFF", 5
	y = bottom + h - 20
	
	boldFont.print title, xIcon, y, 1, textColor
	gfx.line xIcon, y-2, xIcon + boldFont.width(title), y-2, textColor
	
	headColor = "#CCCCCC"
	y -= rowHeight*1.5
	thinFont.printRight "Size", xSize, y+rowHeight, 1, headColor
	boldFont.printRight "$", xValue, y+rowHeight, 1, headColor

	buttons = []
	yButton = bottom + 24
	drop = @outer.drop
	use = @outer.use
	for i in items.indexes
		item = items[i]
		if i == selItemIdx then
			gfx.fillRect left+6, y-4, width-12, 18, "#4444AA"
			btn = Button.Make("Drop", left + 100, yButton)
			btn.item = item
			btn.action = function; drop self.item; end function
			buttons.push btn
			if item.usable then
				btn = Button.Make("Use", left + width - 100, yButton)
				btn.item = item
				btn.action = function; use self.item; end function
				buttons.push btn
			end if
		end if
		item.drawIcon gfx, xIcon, y - 2
		boldFont.print item.name, xName, y, 1, textColor
		boldFont.printRight item.size, xSize, y, 1, textColor
		boldFont.printRight item.value, xValue, y, 1, textColor
		y -= rowHeight
	end for
	return buttons
end function

show = function(container, title="Inventory")
	outer.container = container
	outer.agent = container
	while agent != null and not agent isa Agent
		outer.agent = agent.container
	end while
	
	if not outer.hasIndex("boldFont") then init
	items = container.contents
	if items == null then items = []
	h = rowHeight * (container.contents.len + 3) + 32
	
	selItemIdx = -1
	outer.refresh = true
	while true
		if refresh then
			btns = draw(h, items, title, selItemIdx)
			for btn in btns; btn.draw; end for
			outer.refresh = false
		end if
		if key.available then
			k = key.get.code
			if k == 19 then  // up
				selItemIdx = (selItemIdx + items.len - 1) % items.len
			else if k == 20 then // down
				selItemIdx = (selItemIdx + 1) % items.len
			else if k == 27 then // esc
				break
			end if
			outer.refresh = true
		end if
		for btn in btns; btn.update; end for			
	end while
	
	gfx.fillRect 480 - width/2, 320 - h/2, width, h, color.clear
end function

drop = function(item)
	item.placeOnMap agent.x, agent.y
	outer.refresh = true
	itemName = item.nameWithArticle
	agent.note "Dropped {itemName}.".fill(locals)
	ui.update
end function

use = function(item)
	item.useBy agent
	item.destroy
	outer.refresh = true
	used = item.usedVerb.capitalized
	itemName = item.nameWithArticle
	agent.note "{used} {itemName}.".fill(locals)
	ui.update
end function


test = function
	ensureImport "ui"
	ensureImport "disp"
	ensureImport "ontology"
	init
	disp.init
	globals.player = Player.Make
	player.contain Item.Make("Thingy")
	
	bone = Item.Make("bone")
	bone.iconIdx = 784
	bone.color = "#CCCCCC"
	player.contain bone
	
	apple = Food.Make("apple")
	apple.iconIdx = 943
	apple.color = "#FF4444"
	player.contain apple
	
	shroom = Food.Make("shroom")
	shroom.image = file.loadImage("/usr/pics/shroom.png")
	shroom.color = color.brown
	player.contain shroom

	staff = Item.Make("Staff of Wizardry")
	staff.icon = 834
	staff.color = color.yellow
	staff.size = 3
	staff.value = 123
	player.contain staff

	show player
end function


if locals == globals then test
