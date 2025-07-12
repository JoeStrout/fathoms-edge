# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## How to Run the Game

The game is written in MiniScript and runs on Mini Micro. To start the game:

```
cd src
run main
```

This is executed from the startup.ms file in the root directory.

## Architecture Overview

**Fathom's Edge** is a fantasy RPG written in MiniScript for the Mini Micro platform. The game uses a modular architecture with clear separation of concerns:

### Core Systems

- **Zone Management** (`zone.ms`): Handles map loading, zone switching, and maintains game world state. Uses a Zone class to manage 2D tile maps with width/height dimensions and element palettes.

- **Ontology System** (`ontology.ms`): Defines the class hierarchy for all game objects. Everything that can exist in the world inherits from the `Thing` base class, including items, entities, obstacles, etc. Uses a unique ID system for object tracking.

- **Display System** (`disp.ms`): Manages the visual representation of the game world, including tile displays and sprite rendering.

- **User Interface** (`ui.ms`): Handles all UI elements using bitmap fonts and styled text rendering. Includes inventory panels and game dialogs.

### Game Systems

- **Combat System** (`combat.ms`): Handles battle mechanics, damage types (Physical, Fire, Cold, Shock, Poison, Necrotic), and equipment-based combat.

- **Inventory System** (`inventory.ms`): Manages item storage, stacking, and container interactions.

- **Loadout System** (`loadout.ms`): Handles equipment slots (Primary Hand, Off Hand, Head, Body, Feet, Neck, Ring) and item equipping.

- **Status Effects** (`status.ms`): Manages temporary effects like WADING, SLOWED, HIDDEN, etc.

- **Conversation System** (`conversation.ms`): Handles NPC dialog trees and interactive conversations.

### Content Definition

- **Common Items** (`commonItems.ms`): Defines standard items, weapons, armor, and consumables available across the game.

- **Common Mobs** (`commonMobs.ms`): Defines standard monsters and NPCs that can appear in different zones.

- **Map Elements** (`mapElement.ms`): Defines tile types and their properties, loaded from `data/mapElements.tsv`.

### Zone-Specific Content

- **Town** (`town.ms`): Defines the main town zone with NPCs, shops, and quest content.

- **Grotto** (`grotto.ms`): Defines the grotto zone accessible via portal from town.

### Development Tools

- **Map Editor** (`mapEditor.ms`): Built-in level editor for creating and modifying zone maps.

- **Fatbits** (`tools/fatbits.ms`): Pixel art editor for creating game sprites.

## Key Design Patterns

1. **Module System**: Uses MiniScript's import system with `ensureImport` for dependency management.

2. **Class-Based OOP**: Extensive use of MiniScript's prototype-based inheritance system.

3. **Data-Driven Content**: Map elements defined in TSV files, with code-defined behaviors.

4. **Zone-Based World**: Game world divided into discrete zones that can be loaded/cached independently.

5. **Component-Based Entities**: Game objects have modular properties (resistance, damage, capacity, etc.).

## File Organization

- `src/`: All source code
- `data/`: Game data files (maps, element definitions)
- `pics/`: Sprite images and UI graphics
- `tools/`: Development utilities
- `lib/`: External libraries (oneBit image processing)

## Development Notes

- The game uses turn-based mechanics with a main game loop in `main.ms`
- All game objects are tracked via unique IDs in `Thing.ByID`
- Zone transfers are handled through Portal objects that can load/restore zone state
- The game supports both keyboard and mouse input through `keyboardInput.ms`
- Visual effects are managed through `visualFX.ms` for animations and decorations

## MiniScript Notes

- MiniScript is not Python.  Be careful when writing MiniScript code.  Refer to the `miniscript.md` file in the `notesForClaude` folder.
- In particular, note that MiniScript's `range` function is *inclusive* of both start and end, unlike Python's, which excludes the upper bound.  Examples:
	- `range(1, 3)` returns `[1, 2, 3]`
	- `range(3, 1)` returns `[3, 2, 1]`
	- `range(0, 0)` returns `[0]`
	- To ensure that `range` always counts up, specify `1` for the third (step) parameter.  For example, `range(0, count-1, 1)` is a safe way up to `count - 1`.
	- Similarly, specify a step of `-1` to ensure that `range` counts down, e.g. `range(count-1, 0, -1)`.
	- If you just need to iterate over the indexes of a list, use `myList.indexes`.
- Don't use unnecessary parentheses on function calls.
	- You *only* need parentheses around the arguments to a function call used as part of some larger statement, e.g.: `x = round(41.7)`
	- You don't need parentheses if there are no arguments: `x = rnd`
	- You never need empty parantheses.
	- You don't need parentheses around the arguments to a function call which is the entire statement (a "command statement"): `print 42`
