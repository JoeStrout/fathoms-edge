// The Canversation class represents an NPC conversation.  This can be
// anything from a simple comment, to a rich conversation tree.

if not globals.hasIndex("ensureImport") then import "importUtil"
ensureImport "oneBit"
ensureImport "miscUtil"
base64ToImage = @miscUtil.base64ToImage

globals.ConvIcon = {}
// Icons that appear (in a speech bubble) above an NPCs head while this
// conversation is available (if the player hasn't already done it).
ConvIcon.GIVEQUEST = "GIVEQUEST"   // ?
ConvIcon.GIVEREWARD = "GIVEREWARD" // !
ConvIcon.CANCELED = "CANCELED"     // X
ConvIcon.HAPPY = "HAPPY"           // :)
ConvIcon.SAD = "SAD"               // :(
ConvIcon.HEART = "HEART"           // heart icon
ConvIcon.SKULL = "SKULL"           // skull icon

_IconImage = {}
_IconImage[ConvIcon.GIVEQUEST] = oneBit.getTileImage(822)
_IconImage[ConvIcon.GIVEREWARD] = oneBit.getTileImage(820)
_IconImage[ConvIcon.CANCELED] = oneBit.getTileImage(885)
_IconImage[ConvIcon.HAPPY] = oneBit.getTileImage(886)
_IconImage[ConvIcon.SAD] = base64ToImage("AAAAAB/4PDw4HDAMMkwwDDGMOlw8PB/4A8ABgAAAAAA=")
_IconImage[ConvIcon.HEART] = oneBit.getTileImage(883)
_IconImage[ConvIcon.SKULL] = oneBit.getTileImage(884)


responseArrow = oneBit.getTileImage(701)

// ConvNode: represents a single message, with possible responses.
globals.ConvNode = {}
ConvNode.speech = "..."
ConvNode.responses = null // list of ConvResponse
ConvNode.Make = function(speech)
	node = new ConvNode
	node.speech = speech
	node.responses = []
	return node
end function
	
ConvNode.addResponse = function(speech, callback)
	resp = new ConvResponse
	resp.speech = speech
	if @callback then resp.callback = @callback
	self.responses.push resp
	return resp
end function


// ConvResponse: a response the player can select to a ConvNode.  These
// may lead to more ConvNodes, or they may terminate the conversation.
globals.ConvResponse = {}
ConvResponse.speech = "Yes."
ConvResponse.next = null      // ConvNode, or null
ConvResponse.callback = null  // function invoked when this response is selected

// Conversation: wraps up a whole ConvNode tree.
globals.Conversation = {}
Conversation.icon = null  // one of the ConvIcon constants above
Conversation.done = false // true after the player has been through it
Conversation.top = null   // ConvNode object

Conversation.Make = function(speech, icon="HAPPY")
	conv = new Conversation
	conv.icon = icon
	conv.top = ConvNode.Make(speech)
	return conv
end function

Conversation.iconImage = function
	if self.done then return null
	return _IconImage[self.icon]
end function

Conversation.addResponse = function(speech, callback)
	return self.top.addResponse(speech, callback)
end function

Conversation.drawResponses = function(left, bottom, width, height, node, curChoice=0)
	gfx.fillRect left, bottom, width, height, "#000000"
	printer = ui.smallPrinter
	printer.y = bottom + height - 20
	respX = left + 80
	msgRight = left + width - 40
	
	for i in node.responses.indexes
		resp = node.responses[i]
		if i == curChoice then
			gfx.drawImage responseArrow, respX - 40, printer.y - 10, 32, 32, 
			  0, 0, -1, -1, "#FFFF99"
			gfx.color = color.white
		else
			gfx.color = "#CCCCCC"
		end if
		printer.print resp.speech, respX, null, msgRight, respX
		printer.y -= 10
	end for
end function

Conversation.doOneNodeUI = function(npc, node)
	width = 600
	left = 480 - width/2
	msgLeft = left + 80
	msgRight = left + width - 40
	printer = ui.bigPrinter
	msgH = printer.calcHeight(node.speech, msgLeft, msgRight, msgLeft)
	totalH = msgH + 40

	responsesH = 10
	respX = msgLeft
	for resp in node.responses
		responsesH += ui.smallPrinter.calcHeight(resp.speech, respX, msgRight, respX) + 10
	end for
	totalH += responsesH + 24

	top = 320 + floor(totalH/2)
	bottom = 320 - ceil(totalH/2)
	globals.gfx = disp.dialog
	gfx.color = color.white
	gfx.fillRect left, bottom, width, totalH, "#000000"
	gfx.drawRect left-2, bottom-2, width+4, totalH+4, "#FFFFFF", 5
	gfx.drawImage npc.image, left+16, top-16-48, 48, 48, 0, 0, -1, -1,
	  npc.color
	printer.y = top - 40
	printer.print node.speech, msgLeft, null, msgRight, msgLeft
	
	if node.responses then
		curChoice = 0
		responsesTop = printer.y - 20
		self.drawResponses left+2, bottom+22, width-4, responsesH, node, curChoice
	else
		ui.smallPrinter.font.printRight "(Press Return.)", left+width-40, bottom+8
		curChoice = null
	end if
	
	key.clear
	while true
		k = key.get.code
		if k == 19 or (k == 9 and key.shiftPressed) then
			curChoice = (curChoice + node.responses.len + 1) % node.responses.len
		else if k == 20 or k == 9 then
			curChoice = (curChoice + 1) % node.responses.len
		else if k == 10 or k == 13 or k == 3 or k == 32 then
			break
		end if
		self.drawResponses left+2, bottom+22, width-4, responsesH, node, curChoice		
	end while

	disp.dialog.clear
	globals.gfx = disp.gfx
	return curChoice
end function

Conversation.doUI = function(npc)
	node = self.top
	while node
		choice = self.doOneNodeUI(npc, node)
		if choice != null then
			node.responses[choice].callback
			node = node.responses[choice].next
		else
			node = null
		end if
	end while
	self.done = true
	globals.gfx = disp.gfx
end function


test = function
	ensureImport "disp"
	ensureImport "ui"
	disp.init
	guy = {}
	guy.image = oneBit.getTileImage(56)
	guy.color = "#66FF66"
	globals.c = Conversation.Make("_Nice day for fishin', ain't it?_  " +
	  "...is a thing that Balen says a lot.  We are really " +
	  "stealing from VLDL here, but what can I say, I need content!")
	sayMore = c.addResponse("Tell me more.")
	sayMore.next = ConvNode.Make("I'd love to!  I have a lot " +
	  "to say, though in reality, most of it is pretty content-free.")
	youThief = c.addResponse("You're a content-thief!")
	youThief.next = ConvNode.Make("Hey, don't judge! We have limited " +
	  "time and basically no budget, here.")
	youThief.next.addResponse "I guess you're right.", function
		file.loadSound("/sys/sounds/cha-ching.wav").play
	  end function
	youThief.next.addResponse "[Chirping crickets]", function
		for i in [1,2,3]
			file.loadSound("/sys/sounds/chirp.wav").play
			wait 0.5
		end for
	  end function
	
	c.doUI guy
end function

if locals == globals then test