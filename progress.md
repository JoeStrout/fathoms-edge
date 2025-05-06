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

