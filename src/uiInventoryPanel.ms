// Inventory panel: shows what you're carrying and allows you
// to use/equip/drop stuff, etc.

import "importUtil"
ensureImport "miscUtil"
ensureImport "ui"

width = 300
rowHeight = 18

RETURN = char(10)

init = function
	outer.boldFont = ui.smallPrinter.boldFont
	outer.thinFont = ui.smallPrinter.font
	outer.textColor = ui.textColor
	outer.Button = ui.Button
end function

// Helper method: draw the inventory box, and return
// the set of buttons that go with the selected item.
// If toLeft is true or false, then this will be drawn
// off-center, to the left (true) or right (false).
draw = function(items, loadout, title, selItemIdx = -1, toLeft=null)
	h = 300 // fixed height
	left = 480 - width/2
	if toLeft == true then left -= width/2 + 4
	if toLeft == false then left += width/2 + 4
	xUse = left + 24  // (center point)
	xIcon = left + 38 // (left point)
	xName = left + 56 // (left point)
	xSize = left + width - 56  // (right point)
	xValue = left + width - 12 // (right point)

	bottom = 320 - h/2
	globals.gfx = disp.dialog
	gfx.fillRect left, bottom, width, h, "#000000"
	gfx.drawRect left+3, bottom+3, width-6, h-6, "#FFFFFF", 5
	y = bottom + h - 20
	
	boldFont.print title, xIcon, y, 1, textColor
	gfx.line xIcon, y-2, xIcon + boldFont.width(title), y-2, textColor
	
	headColor = "#CCCCCC"
	y -= rowHeight*1.5
	thinFont.printRight "Size", xSize, y+rowHeight, 1, headColor
	
	gfx.drawImage coinImg, xValue - 16, y+rowHeight-4

	buttons = []
	yButton = bottom + 24
	
	drop = @outer.drop
	use = @outer.use
	unequip = @outer.unequip
	putInContainer = @outer.putInContainer
	takeFromContainer = @outer.takeFromContainer
	
	selling = toLeft and outer.container isa Agent
	buying = not toLeft and outer.container isa Agent
	
	for i in items.indexes
		item = items[i]
		unitPrice = item.value
		if selling then unitPrice = container.getBuyPrice(item)
		if buying then unitPrice = container.getSalePrice(item)

		if i == selItemIdx then
			gfx.fillRect left+6, y-4, width-12, 18, "#4444AA"
			if toLeft != false then  // (i.e., not the container/chest)
				btn = Button.Make("Drop", left + 100, yButton, ["d", "D", "x", "X"])
				btn.item = item
				btn.action = function; drop self.item; end function
				buttons.push btn
			end if
			if loadout != null and loadout.slotOfItem(item) then
				btn = Button.Make("Remove", left + width - 100, yButton, ["u","r",RETURN])
				btn.item = item
				btn.action = function; unequip self.item; end function
				buttons.push btn
			else if item.usable and not buying then
				btn = Button.Make("Use", left + width - 100, yButton, ["u", RETURN])
				btn.item = item
				if toLeft == false then // i.e., is in container
					btn.action = function
						takeFromContainer self.item
						use self.item
					end function
				else
					btn.action = function; use self.item; end function
				end if
				buttons.push btn
			end if
			if toLeft == true then
				buttons[0].x = left + 60
				if buttons.len > 1 then buttons[1].x = left + width/2
				label = "Put -->"
				if selling then
					if unitPrice <= 0 then label = "Give -->" else label = "Sell -->"
				end if
				btn = Button.Make(label, left + width - 60, yButton, "pPtTmM".split(""))
				if selling then btn.shortcutKeys += ["s", "S", "g", "G"]
				btn.item = item
				btn.action = function; putInContainer self.item; end function
				if unitPrice != null then buttons.push btn
			else if toLeft == false then
				label = "<-- Take"
				if buying then
					label = "<-- Buy"
				end if
				btn = Button.Make(label, left + 60, yButton, "pPtTmM".split(""))
				if buying then btn.shortcutKeys += ["b", "B"]
				btn.item = item
				btn.action = function; takeFromContainer self.item; end function
				if unitPrice <= agent.gold then buttons.push btn
			end if
		end if
		if loadout != null then loadout.drawSlotIconForItem item, xUse, y
		item.drawIcon gfx, xIcon, y - 2
		name = item.name
		size = str(round(item.size, 1))
		value = str(unitPrice)
		if item.qty > 1 then
			name += " (×" + item.qty + ")"
			size += " (" + round(item.size * item.qty, 1) + ")"
			if unitPrice then value += " (" + (unitPrice * item.qty) + ")"
		end if
		boldFont.print name, xName, y, 1, textColor
		boldFont.printRight size, xSize, y, 1, textColor
		boldFont.printRight value, xValue, y, 1, textColor
		y -= rowHeight
	end for
	globals.gfx = disp.gfx
	return buttons
end function

erase = function(toLeft=null)
	h = 300 // fixed height
	left = 480 - width/2
	if toLeft == true then left -= width/2 + 4
	if toLeft == false then left += width/2 + 4
	bottom = 320 - h/2
	disp.dialog.fillRect left, bottom, width, h, color.clear
end function


show = function(agent, container)
	outer.container = container
	outer.agent = agent
	
	if not outer.hasIndex("boldFont") then init
	items = agent.contents.items
	if items == null then items = []

	if container then
		containerItems = container.contents.items
		if containerItems == null then containerItems = []
	end if
	
	selItemIdx = [-1, -1]
	selPanel = 0
	outer.refresh = true
	while true
		if refresh then
			if container == null then
				btns = draw(items, agent.loadout, "Inventory", selItemIdx[0])
			else
				btns = draw(items, agent.loadout, "Inventory", selItemIdx[0], true)
				btns += draw(containerItems, null, container.name, selItemIdx[1], false)
			end if
			for btn in btns; btn.draw; end for
			outer.refresh = false
		end if
		yield
		if key.available then
			if selPanel then itemQty = containerItems.len else itemQty = items.len
			k = key.get
			if k.code == 19 then  // up
				selItemIdx[selPanel] = (selItemIdx[selPanel] + itemQty - 1) % itemQty
			else if k.code == 20 then // down
				selItemIdx[selPanel] = (selItemIdx[selPanel] + 1) % itemQty
			else if k.code == 17 then // left
				selPanel = 0
				selItemIdx[0] = 0
				selItemIdx[1] = -1
			else if k.code == 18 then // right
				selPanel = 1
				selItemIdx[0] = -1
				selItemIdx[1] = 0
			else if k.code == 27 or k == "i" then // esc
				break
			else
				for btn in btns; btn.handleKey(k); end for
			end if
			if selItemIdx[selPanel] >= itemQty then selItemIdx[selPanel] = itemQty - 1
			outer.refresh = true
		end if
		for btn in btns; btn.update; end for			
	end while
	
	if container == null then
		erase null
	else
		erase true
		erase false
	end if
end function

drop = function(item, qty=null)
	if qty == null then
		if key.shiftPressed then qty = item.qty else qty = 1
	end if
	if item.qty != null and qty < item.qty then
		// split the stack and drop only one or some
//		print "dropping only " + qty + " of " + item.nameWithQty
		item = agent.contents.removeItem(item, qty)
	else
		// unequip/drop the whole stack
//		print "dropping whole stack (" + item.qty + ")"
		agent.loadout.unequip item
	end if
	item.placeOnMap agent.x, agent.y
	outer.refresh = true
	itemName = item.nameWithArticle
	agent.note "Dropped {itemName}.".fill(locals)
	agent.update
	ui.update
end function

use = function(item)
	item.useBy agent
	outer.refresh = true
	used = item.usedVerb.capitalized
	itemName = item.nameWithArticle("a", true)
	agent.note "{used} {itemName}.".fill(locals)
	agent.update
	ui.update
end function

unequip = function(item)
	agent.loadout.unequip item
	outer.refresh = true
	itemName = item.nameWithArticle
	agent.note "Removed {itemName}.".fill(locals)
	agent.update
	ui.update
end function

putInContainer = function(item)
	agent.loadout.unequip item
	wholeStack = key.shiftPressed
	if item.qty == null or item.qty <= 1 then wholeStack = true
	if not wholeStack then
		item = agent.contents.removeItem(item, 1)
	end if
	itemName = item.nameWithArticle
	containerName = container.nameWithArticle("the")
	message = "Placed {itemName} in {containerName}."
	if container isa Agent then
		price = container.getBuyPrice(item)
		if price > 0 then
			message = "Sold {itemName} to {containerName} for {price}¢."
			agent.addGold price
		else
			message = "Gave {itemName} to {containerName}."
		end if
	end if
	container.contain item
	outer.refresh = true
	agent.note message.fill(locals)
	agent.update
	ui.update
end function

takeFromContainer = function(item)
	wholeStack = key.shiftPressed
	if item.qty == null or item.qty <= 1 then wholeStack = true
	if container isa Agent then
		unitPrice = container.getSalePrice(item)
		buyQty = 1
		if wholeStack then
			// calculate how many we can afford!
			buyQty = floor(agent.gold / unitPrice)
			if buyQty > item.qty then buyQty = item.qty
		end if
		price = unitPrice * buyQty
		if price > agent.gold then
			agent.note "You don't have enough gold."
			agent.update
			ui.update
			return
		end if
		agent.addGold -price
		if buyQty < item.qty then
			item = container.contents.removeItem(item, buyQty)
		end if
		message = "Bought {itemName} from {containerName} for {price}¢."
	else
		if not wholeStack then
			item = container.contents.removeItem(item, 1)
		end if
		message = "Took {itemName} from {containerName}."	
	end if
	agent.contain item
	outer.refresh = true
	itemName = item.nameWithArticle
	containerName = container.nameWithArticle("the")
	agent.note message.fill(locals)
	agent.update
	ui.update
end function

test = function(withContainer=false)
	ensureImport "ui"
	ensureImport "disp"
	ensureImport "ontology"
	ensureImport "commonItems"
	
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

	staff = Equipment.Make("Staff of Wizardry")
	staff.icon = 834
	staff.color = color.yellow
	staff.size = 3
	staff.value = 123
	player.contain staff
	staff.useBy player

	if withContainer then
		chest = Container.Make("Chest")
		chest.contain Gold.Make(12)
		
		item = Equipment.Make("Diamond Ring", 910, loadout.RING)
		item.color = color.silver
		chest.contain item
		
		item = Equipment.Make("Amulet", 940, loadout.NECK)
		item.color = "#FFCC33"
		chest.contain item
		
		item = Food.Make("Bread", 911)
		item.color = color.yellow
		chest.contain item
		
		item = Food.Make("Buckler", 809)
		item.color = color.brown
		chest.contain item
		
		show player, chest
	else
		show player
	end if
end function


if locals == globals then test true
