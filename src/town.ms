// This module builds the map of Fathom's Edge (the home town).

import "importUtil"
ensureImport "disp"
ensureImport "mapTools"
ensureImport "zone"
ensureImport "status"
ensureImport "conversation"
ensureImport "commonItems"
ensureImport "commonMobs"

palettePath = "/usr/data/mapElements.tsv"
zonePath = "/usr/data/town.dat"

load = function
	palette = MapElement.LoadFromFile(palettePath)
	zone.current = Zone.LoadMapElems(palette, zonePath)

	Bone.Make.placeOnMap 3, 8
		
	Sign.Make("Welcome to Fathom's Edge").placeOnMap 20, 20
	Sign.Make("East: Fathom's Edge; South: Fathom", 224).placeOnMap 16, 7
	
	for i in [1,2]
		apple = Apple.Make
		apple.qty = i
		apple.placeOnMap 10+i, 12
	end for
	
	for i in range(1,3)
		gold = Gold.Make(i)
		gold.placeOnMap 10+i, 8-i
	end for
	
	// ToDo: match colors to effects in some semi-random way.
	Shroom = Food.Make("shroom", file.loadImage("/usr/pics/shroom.png"))
	Shroom.Colors = [color.red, color.green, color.brown, color.yellow,
	  "#CCCCFF", "#CCCCCC", "#CCCCAA"]
	Shroom.size = 1
	Shroom.value = 1
	Shroom.healthValue = 2
	Shroom.useBy = function(agent)
		super.useBy agent
		// Add some crazy random effect!
		fx = [
		  status.POISONED,
		  status.WEAKENED,
		  status.VULNERABLE,
		  status.INVULNERABLE,
		  status.STUNNED,
		  status.SLOWED,
		  status.HASTENED,
		  status.CONFUSED,
		  status.BLIND,
		  status.DEAF,
		  status.HALLUCINATING,
		  status.BLESSED,
		  status.CURSED,
		  status.CHARMED,
		  status.ENCUMBERED,
		  status.FATIGUED,
		  status.GLOWING,
		  status.MUTE,
		  status.PANICKED,
		  status.SERENE,
		  status.TIPSY,
		  status.INTOXICATED]
		agent.statuses.apply fx.any, 5  // (lasts 5 turns)
	end function
	
//	for i in range(5)
//		shroom = new Shroom
//		shroom.color = Shroom.Colors.any
//		shroom.placeOnMap floor(40*rnd), floor(30*rnd)
//	end for

	for i in []//range(1)
		rat = Rat.Make
		rat.placeOnMap floor(40*rnd), floor(30*rnd)
	end for	
	
	for i in []//range(1)
		slime = Slime.Make
		if rnd < 0.5 then slime.contain RingOfProtection.Make
		slime.placeOnMap floor(40*rnd), floor(30*rnd)
	end for
	
	globals.Alyce = TownsFolk.Make("Alyce", 127, "#FF9999")
	Alyce.conversation = Conversation.Make(
	   "I've lost my dog Fido.  Can you help me find him?",
	   ConvIcon.GIVEQUEST)
	r1 = Alyce.conversation.addResponse("Sure, I'd be happy to!")
	r2 = Alyce.conversation.addResponse("Sorry, I'm busy.")
	r1.next = ConvNode.Make("Oh thank you!  I really hope he's OK!")
	Alyce.placeOnMap 10, 11
	
	globals.Balen = TownsFolk.Make("Balen", 95, "#CCCC00")
	Balen.conversation = Conversation.Make("Nice day for fishin', ain't it?")
	Balen.conversation.top.addResponse "Sure is!"
	Balen.conversation.top.addBuySell
	Balen.placeOnMap 16, 16
	Balen.contain RawFish.Make

	zone.current.connectPortal 8, 3, "grotto", 6, 4, "You enter the cave."
	
	player.placeOnMap 15, 10
	
	ale = Ale.Make
	ale.placeOnMap 16, 10
	
	zone.current.activate
end function

