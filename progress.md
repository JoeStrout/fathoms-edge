## May 6, 2025

I've made a good start on this game, but ideas are coming faster than I can implement them, so I'd better start writing them down.

*Damage types:* to make combat more interesting and give the player interesting choices, let's have several different types of damage:

- Physical - gray
- Fire - orange
- Cold - blue
- Shock (electrical) - yellow
- Poison - green
- Necrotic - black

Normal, non-magical weapons will do only Physical damage, and normal armor would provide resistance to same.  Magic spells or weapons, or certain monster/environmental attacks, would do other sorts of damage or provide specialized resistances.

Resistance could be in terms of percentage, and stack; so maybe my magic helmet provides 10% fire resistance, and armor provides 25%, for a total of 35% resistance to fire.  So any fire damage done to me is reduced by 35%.  If you get to 100% resistance, you're immune to that type of damage; higher-level monsters will often have this to specific types (ghosts 100% immune to physical damage, golems immune to Necrotic, etc.).

*Equipping Stuff:* Let's have a small number of slots, and each item can indicate which slot it can be equipped in.  When equipped we'll just draw the corresponding icon next to it in the inventory list.  Slots:

- Primary Hand (weapon)
- Off Hand (shield or secondary weapon)
- Both Hands (two-handed weapons)
- Head (helmet/hat)
- Body (armor/clothes)
- Feet (shoes/boots)
- Neck (amulet/necklace)
- Ring (allow up to 2? at once)

*Combat:* Press the Target (T) key to cycle through nearby mobs, then Attack (K) to attack with your primary weapon.  That works even for ranged attacks, and does not require an orthogonal (or diagonal) line.  For melee, you can also just try to move into the mob; this will automatically set the target and attack.

The target gets a chance to Dodge the attack -- this is a skill, and provides some % chance of dodging, capped at 75%.  Even that level should be very hard for a player to achieve; and some high-level magic could have Dodge reduction (e.g., maybe Magic Missile does low damage but has -100% Dodge for a guaranteed hit).  Heavy armor reduces your Dodge.

*Real estate:* In the home town, there should be a handful of houses you could buy, ranging from small shacks to multi-room homes.  You can drop stuff there (or place stuff in containers) and it will be safe, whereas stuff dropped in public places will get gradually cleaned up.  Perhaps you could also equip your home with potion-making gear?  Not sure how far we want to go down that rabbit hole.  But still, it's a nice reward for the player as they level up and gain gold.

*Crafting:* If we do want to go down the crafting rabbit-hole, a good way to do it would be to have basically crafting tables you can Use (either by Using them from your inventory, or if they're furniture, by pushing into them).  Using one of these would bring up your inventory list, with the ability to toggle a checkmark on each item, and some "Result:" section would show you when the selected ingredients match some recipe that type of crafting station supports.  OR, maybe you pick a recipe first, and it auto-draws the items from your inventory, or points out what you're missing.  Crafting station ideas:
	- alchemy table: brew potions
	- smelter: turn ore into ingots
	- forge: make weapons/tools
	- oven: bake bread, cookies, pies, and cakes
	

*Furniture:* Items too big to automatically pick up, like tables, chests, and crafting stations.  To move these, you would have to Use another item: _Hand Truck_.  The procedure would be: Use a Hand Truck while standing next to some furniture; it then picks up that item, keeping it next to you as you move around.  When you press a movement direction, if that's _toward_ the item (i.e. it's already in that direction), you move forward; otherwise, it just moves the item over to that side of you.  If that space is not empty, you just go bonk. You stop using it when you back directly away (or attempt to, even if that direction is blocked).  So to turn around with a hand truck, you have to have room to use the in-between direction.  All this would be mainly for arranging furniture in your house, though you could probably also use it in some dungeons to cheese a puzzle here and there.

## May 7, 2025

Implemented equipment and unarmed melee combat yesterday.  That's working well.  Today, weapons and ranged combat.

Then I should probably tackle NPCs, including shopkeepers, and start thinking about laying out the town of Fathom's Edge.

Ran into some thorny bugs today related to identical objects.  Specifically, I had slimes dropping rings of protection, all identical (and identical to the one I just placed on the ground to begin with).  The standard behavior in MiniScript is to compare objects by their contents, so things like indexOf (and removeVal) would find the first _equivalent_ object instead of the specific instance I was looking for.

I've fixed that by adding some stuff in miscUtil to find and remove objects in a list by reference, which is probably faster as well as more correct in this case.  It seems to work.  Still, I wonder if this is going to be an ongoing headache, and maybe I should just side-step it by having Thing.Make assign a unique ID to each object as it's created.  That would make them all unique, whether compared by value or by reference.
