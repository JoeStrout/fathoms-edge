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

## May 8, 2025

I did end up adding a unique ID to each object, but I'm still going to try to maintain a habit of matching objects by reference whenever that makes sense (i.e., they represent unique "things" in the game, rather than values or locations).

Yesterday I got melee weapons working (giving the player a two-handed sword), but didn't get to ranged attacks.  I've done that today: the player now starts with a "wand of frost" that deals 2 Cold damage up to 10 spaces away.  As a bonus, you can now do diagonal melee attacks too (via the "attack" button, K).  All seems to be working properly.

## May 9, 2025

On water: suppose water can be either "shallow" or "deep".  Upon entering shadow water, you get status WADING, which has effects similar to SLOWED or ENCUMBERED.  In deeper water, you get either SWIMMING or UNDERWATER, depending on how much weight you have on you.  You can be UNDERWATER for only three turns before you also get DROWNING, which does substantial damage (like maybe 1/3 of full health) every turn, unless you have a WATERBREATHING status from some magic.  And note that if you have WATERWALKING (again, from magic), then water tiles are treated just like smooth ground.

It occurs to me that we may have some statuses that we want to use for internal bookkeeping, but not display for the user.  We could simply define those with parentheses, like "(WATERBREATHING)", and then not draw them in the UI.  Unless we want to draw them under some circumstances but not others — in this case, maybe only when it actually has any effect, i.e., you are UNDERWATER.  That would require some special logic.  Maybe it could be generalized as: only draw *this* status when *that* status is present.  Needs more thought.

On hiding/sneaking: let's let the user manually toggle a HIDING status (key "H").  This merely indicates that they are *trying* to hide.  Then game logic will assign either HIDDEN or EXPOSED, based on hiding skill (if we have a skill system), movement, and environmental conditions including lighting.  To let the user practice/test this ability, it'd be fun to have somewhere in town where there is always a guard who will block your way unless you can sneak past him.

That reminds me, do we want a day/night cycle?  If so, 1 minute per game turn feels about right.  So it would take half an hour to walk about one screen's width (the size of a small town, when outdoors, or a mansion-sized indoor space).  I think seasons would be going way overboard, and probably week/month cycles too; even to get through a single day is 1440 turns, which is a lot (though we could allow sleeping to pass the time more quickly, perhaps by interacting with a bed or chair).  So maybe we divide the day like this: 12 hours daylight, 10 hours darkness, and 1 hour twilight each in between.  Outdoor tiles would be tinted accordingly, and it would be much easier to get HIDDEN in twilight or darkness.  We could also allow for some magic rituals that have to be performed at night, or mobs that change their behavior at night.

On monster spawning: let's not have them respawn.  The town will be (mostly) reset every time you load it; same with adventures.  Within an adventure, once you kill a mob, it stays dead until you exit and return.

On defining levels: I'm thinking we give the designer a 256-entry palette of tile IDs, so that we can store them efficiently in a RawData (and binary file) with 1 byte per tile.  But each ID will map to an extended data structure defining the actual tiles to display for background, main, and overlay; and attributes like water, obstacle, etc.  Things in the world (including items and mobs) would be stored separately, probably in a GRFON file. We should have a level editor that lets you efficiently paint with this palette, and also place/remove things.  Note that an adventure can certainly be divided into different zones (levels), with portals or edge-connections between them.  

A portal is a tile type that, when you interact with it (explicitly or implicitly by pushing into it), posts a little dialog asking whether you want to enter wherever it goes.  If you say yes, it loads the connecting level.  Edge-connections are similar but are tied to a particular edge of the map, and don't ask; you just go.

On player progression: I kinda like Oblivion's system.  You start out with stats in the 5-20 range, but every time you level up, you get 12 points to add to these, though no more than 5 per stat and adding to no more than 3 stats; and stats cap at 100.  That gives you plenty of room for character specialization, at least until you start maxing out stats.  Let's see, if we have 8 different stats, you would max them all out around level 60.  That seems reasonable; we should probably try to scale things so that most characters never reach level 30.  In fact we could just _cap_ your level at 30, and offer no more levels or stat bonuses beyond that (and have NPCs around town saying "isn't it about time you retired?").

Of course the challenge would be coming up with 8 stats that actually impact the game in a meaningful way.  One trick: separate the stat that determines how much you can carry (a hugely important quality-of-life stat) from the stat that determines how much melee damage you do (important for fighters).

Possible stats:

- Strength (STR) - Raw physical power affecting melee damage and breaking objects
- Constitution (CON) - Hardiness affecting health points and physical damage resistance
- Stamina (STA) - Affects carrying capacity, and resistance to poison and disease
- Dexderity (DEX) - Affects dodge chance, attack speed (i.e. chance of bonus attack), and stealth
- Intellect (INT) - Affects spell potency, trap detection, and crafting
- Perception (PER) - Awareness affecting detection of hidden items, critical hit chance, and ranged damage
- Willpower (WIL) - Mental fortitude affecting mana pool, resistance to mental effects, and concentration
- Charisma (CHR) - Social influence affecting NPC reactions, prices, etc.

Now, Oblivion doesn't track generic XP, but instead counts (hidden) points in specific skills, and when you level up a skill, it levels up your character, allowing you to add to stats.  But that seems too complex for this game.  So instead, maybe we just track XP, define an XP threshold for each level, and grant stat points as above; and then we derive skills from your stats.  For example, lock-picking might depend on Agility, Intellect, and Perception.

For testing purposes, we can have a character-generator that builds a Warrior, Rogue, Ranger, or Mage archetype at any given level, by putting points into the corresponding stats in various proportions.

That brings me to adventure levels.  I think it would be better if we can have our adventures try to auto-scale to the player's level, rather than recommend or restrict when players can enter.  That way, the player can play adventures in any order, they don't have to worry about advancing too quickly and missing out on some opportunities, etc.  The auto-archetype characters will be useful for testing, and we can probably also have some code to scale common monsters and items to player level.  Custom mobs/puzzles might require some extra code to scale their difficulty, or you could have some areas that require higher skills be optional side paths.  Care will be needed when it comes to special treasure; we don't want to grant a level-2 adventurer an ubersword that a level-25 warrior would use.  For such cases, either we could put a stat requirement on the item (e.g. "This item requires at least 60 MIGHT"), leading the player to store it until they are strong enough; or we just grant a weaker version of the item.

## May 10, 2025

On magic: I think we should have a proper spell system, where you learn spells (from tomes/scrolls/trainers in the world), and cast them using mana.  Perhaps pressing "M" brings up a magic list — similar to the inventory list — and you prepare a spell in your off hand (precluding use of any item in that hand).  And then cast it with "C".  Targeted spells would use the same target as a ranged attack.  Scrolls are inventory items, but go in your off hand as well, and are also triggered with "C" (this is how non-magicians do magic).

Spell power/effectiveness would scale with skill level.  Maybe we divide magic skills into three:

- Offensive Magic (INT + DEX): fire/cold/necro attack spells.
- Defensive Magic (INT + WIL): shield, healing, concealment spells.
- Alteration Magic (INT + CHR): informative, buff/curse, and other odd spells.

Perhaps like Oblivion, we'll chunk the skill into 5 levels of mastery.  So if your Offensive Magic skill is 30 (in the range 25-49), you cast Magic Missile II (and likewise level II of all other offensive spells).

At character creation, it'd be good to let the player choose a starting class, though this really only determines your starting stats, spells, and inventory; after that you can develop your character however you like.  Maybe we start you out with the key stat for your class in the range 15-20, and all other stats in the range 5-10.

To learn a new spell: find a Study Desk (an item in town, maybe in the mage guild hall) and interact with it.  It will prompt you to select a scroll (for a spell you don't already know) from your inventory.  It will then give you the odds of learning that spell (perhaps 1/6 to 5/6), based on your skill in that school.  Choose to attempt or not; the scroll is destroyed either way.

Oh, and I had an idea about the UI.  We should add keycap glyphs to the screen font, and use that to show stuff like:

- K: Sword of Mincing
- C: Heal Self

We could even use this in button captions to show the keyboard shortcut for those.  We could probably use the Unicode "circled alphanumerics" block for these... but blech, these are not in ASCII order, making them a PITA to use.  Probably better instead to just use a range in the Private Use area, U+E000 — U+F8FF.  These should be 14x14 pixels or so for the current 14-point font.


## May 12, 2025

I've been thinking we would do most of our data files in GRFON, but it occurred to me this morning that in many cases, CSV would actually be neater.

I think the most urgent priority at this point is to get a basic level editor and save/load system up and stumbling about.  This will use a palette of up to 256 "map elements", which defines the tile IDs and colors to use.  (Oh, and I think I should support background colors too; it doesn't always have to be black, though we should favor dark colors so that the light-colored things/agents on the map stand out.)

I'm going to establish a pattern for these CSV files where I name a column with a $, like "bgColor$", and this will get stored on each object that way, e.g. someEntry["bgColors$"].  But then we'll have a method without the $, which parses that original value into a list (if commas are found) or plain value, and then cache the result shadowing the method.

I'm also going to include a `basedOnId`, which identifies a lower-numbered map element to inherit from for any blank entries in this one.  This will be handy, for example, to grab the standard grass (or dirt or whatever) background for any element that only needs to define the main tile, without having to repeat that background info over and over.  It will also work in cases where we have a bunch of related items, e.g., flowers of different colors, or water parts of different edge orientations, that should nonetheless share the same behavioral attributes.

I've begun an implementation of this in mapElement.ms (with a data file at data/mapElements.csv).  Not reading from the file yet — which is where `basedOnId` will be applied — but the parsing and application of value options is working.  For tile IDs, I also support transforms; e.g. "42LF" means tile 42, left-flipped.


## May 14, 2025

I've started on the map editor (mapEditor.cs).  I'll have it draw the palette on the right side of the screen, where the game UI normally goes.  It'll follow standard paint mechanics: click to toggle between foreground and background entry, drag to do more of the same, click palette or option-click map to select the current foreground entry, and a little button (and shortcut key?) to swap foreground and background.

## May 16, 2025

Map editor is up and stumbling about.  Time to work out the file format.  I've been thinking of using RawData for the zone map, because it is fast to read and parse; I've seen text-based formats take noticeable seconds to load for a large map.

So that's easy enough, but then I also have to consider the palette of up to 256 MapElement items.  These are much harder to store in a simple binary format because their length is highly variable.  And I'm already storing them in TSV, which works nicely.  But how to associate the two files?

I guess for now I can punt, and just have a single palette that's used for all the stuff in town.  And maybe we later have just one per adventure — that doesn't seem too limiting, as 256 entries is really quite a lot.  Though I think I'll try to arrange it so that any blank spaces in the adventure palette are filled in with the town palette, and restrict my use of the town palette to the first 4 of every 8 slots, so that adventure designers can both make use of the town stuff (adding their related stuff next to it), and override the town stuff where desired.

## May 18, 2025

I'm struggling a bit to decide how I want to represent items in a zone.  There are two aspects to this problem: (1) defining the _types_ of items that can be found, and (2) defining where they are actually found.

For defining the types, in most cases it is about the same to do that in MiniScript code or in GRFON.  For example, we could say in GRFON:

```
RingOfProtection: {
	_class: Equipment
	name: Ring of Protection
	iconIdx: 907
	slot: RING
	resistance: {
		fire: 10
		cold: 10
		shock: 5
	}
}
```
...or in code:
```
	RingOfProtection = Equipment.Make("Ring of Protection", 907, loadout.RING)
	RingOfProtection.resistance.fire = 10
	RingOfProtection.resistance.cold = 10
	RingOfProtection.resistance.shock = 5
```

I have a half-dozen items defined both ways.  But I skipped the shrooms in GRFON, because I want them to have random colors and effects, and it's harder to see how to do that in GRFON.  We could of course add support for those particular randomizers, but there will always be a need, on occasion, for some custom code.  So maybe it's easier to just define all item types in code.

But we have to think about the modular adventures.  The intent is that you can bring items from one adventure to another — items defined by data, but _not_ with custom code.  So at some point, we need to be able to save at least any Item to a file and reconstitute it -- minus any custom code -- back into memory.  That will probably use GRFON or (since it's not intended to be human-editable) JSON, or perhaps even some binary format to discourage hacking (but probably not).  And this need doesn't apply to mobs, NPCs, etc., who would not be able to leave their home adventure (with the _possible_ exception of pets, but those would be a special case).

So I'm leaning towards defining the types of all things in code, even though Items will be saved/loaded when you bring them home from an adventure.  For something like Shrooms, those should be refactored so that their color and effect are set upon creation (in the adventure), and after that they're stock items.  You could put custom adventure effects when (for example) something is eaten, but that would apply only if eaten during the adventure — once you take them back to town, they are ordinary consumables.

(Note: "effect" should probably be a standard data structure, with values like `health` for how it affects your HP, deltas for each attribute, and arbitrary status effects mapped to how long those last; then we can apply these when consumables are eaten, when weapons strike a target, when equipment is worn, etc.  These sorts of effects would save/load with the item.)

Another consideration: adventures need to level with the player character.  So, sometimes you might want to spawn more mobs, or different mobs/items (i.e. adjust their stats) based on the player level.  This would be far easier to do in code.  So, maybe thing placement should be in code as well.  Hmm.


## May 25, 2025

I've created a [Road Map](roadmap.md) to help keep track of what needs to be done and in what order.  I won't be pedantic about it; this can be rearranged and I have no doubt I'll be adding stuff that I haven't yet thougth of (or have forgotten about today), but at least now when I sit down to do some work, I can always just tackle the next item on the list.  It also divides the work into "milestones," giving a more visible sense of progress.  I'm declaring version 0.1 done now, and will start on version 0.2.


## May 26, 2025

I've implemented item stacks.  Items will stack with identical items, as long as their .stackable property is true (which by default is true whenever .qty is not null).  I've tested picking up individual and multiple items, and dropping individual or multiple items, including the whole stack (shift-click the drop button, or press shift-D or X, to drop a whole stack at once).

So I think that's all working, though it might be good to get some user testing to see if there are any item duplication or destruction exploits.

Next on the to-do list is gold.  I'm inclined to treat gold as just an ordinary stackable item, with a value of 1 and a very low size (maybe 0.01).  Then we don't need so much special code; we can have gold on the map, in containers, or dropped by mobs, all for free.  We might want a bit of special code to keep gold sorted to the top of the inventory list.  Also, should we refer to it as "coins" rather than "gold"?  Hmm.  Claude says that most rougelikes use "gold", so that's what players are used to seeing.  I should probably stick with that.

Playing around with gold/coin icons:
AAAAAAPgB/AN+Bv8G/wb/Bv8G/wb/A34B/AD4AAAAAA= (single coin, standing up)
AAAD4A/4H/wf/A/4E+QMGBPkDBgT5AwYE+QMGAfwAAA= (neat stack of 5 coins)
A+AP+B/8H/wP+BPkDBgD5gYcCfIGDBn0DhgT5AwYA+A= (sloppy stack of 6 coins)
AAAAAAAAAAAAAAAAAAAAAAAAA+AO+B38HfwO+APgAAA= (single coin, lying down)

A fun idea is to have the graphic actually change to show the amount of coins, up to some limit.  Perhaps:

AAAAAAAAAAAAAAAAAAAAAAAAA+AO+B38HfwO+APgAAA= (1 coin)
AAAAAAAAAAAAAAAAAfAHfA7+Dv43fHHwdgA74A+AAAA= (2 coins)
AAAAAAAAAAAAAAHwB3wO/i7+d3x58D4ED7wAOAPgAAA= (3 coins)
AAAAAAAAA+AO+B38HfwO+BPkDBgT5AwYE+QMGAPgAAA= (4 coins)
AAAD4A74Hfwd/A74E+QMGBPkDBgT5AwYE+QMGAPgAAA= (5+ coins)

Implemented that.  Working like a charm!  I don't have any special sorting for it in the inventory list, but I'm going to wait on that until I have a stronger sense of how we want to sort that in general.  So I'm calling the "gold" feature done for now.


5/27/25
=======
Working on support for signs, which should show their sign text when you bump into them.  I'm currently approaching this by adding a `class` column to mapElements.tsv, which lets you specify some MapElement subclass to use for certain palette entries.  And that lets us overwrite a standard `bump` method with a custom one.

Trouble is, that's not really good enough for signs... because each sign generally needs unique text.  And this custom object is just a palette entry; it's the same everywhere that line appears.  Where do we get the custom data?

Maybe a sign should be a Thing instead of a custom map element.  But it'd still be nice to be able to place that via the map editor.  Perhaps the class column should indicate, not a custom MapElement subclass, but a Thing subclass to instantiate at that spot.  Or, maybe I'm not thinking big-picture enough.  Ultimately we'll want to place things on the map independent of the tile type.  The map editor should have such a facility, but that's a bigger item — probably for v0.6.  So for now, I can just place the signs in code, as I do all other items and mobs now.

So, I've now re-implemented signs as Obstacles (a type of Thing), placed in town.ms, and it seems to be working fine.  I've deleted the Sign subclass of MapElement, and the two sign lines in the palette, but for now left the MapElement subclassing code in place.  Maybe it will be useful in other situations.


5/29/25
=======
I think I've got containers implemented.  The item list for both player inventory and containers is limited to 10 rows or so, beyond which Bad Things will happen; but I can fix that in version 0.5, which I'm thinking of as the "polish" release.

Before I call it quits, I'm going to move the various object definitions I've currently got scattered around main.ms and town.ms into commonItems.ms.  I suppose to satisfy GitHub's silly "popularity" measure, I should really make a separate file for each item, but as most of them are only 3 or 4 lines long, I just can't bring myself to do that yet.

I'll make a commonMobs.ms file too.  These two files together will provide a common library of items & monsters for adventure creators to either use as-is, or to calibrate their own creations against.

