# TileMapper

Built from a fork from mDerams 2DMapEditor https://github.com/mDeram/2DMapEditor
But almost completely remade, almost nothing remain of nor old logic nor visuality hence why license now stands under myself for this.

Multi-layer 2D map editor (Windows only currently) with support of importing .png tilesets directly using native dialogue.

Features map 
	- resizing, 
	- drawing, 
	- erasing, 
	- filling

Export maps to txt, json or lua format.

## Preview

## Features

- Edition:
	- Resize
	- Draw
	- Erase
	- Fill
	- Tile Picker
	- Clear
- Movement:
	- Move
	- Zoom
- Display:
	- Toggle grid
	- Reset
- Import:
	- .txt
	- .json
	- .lua
- Export:
	- .txt
	- .json
	- .lua
- Set settings from editor.txt
- Tiles display as drawing palette

---

## Usage Instructions

### Get started

- Linux/MacOS install [love2d v11](https://love2d.org).
- Download the map editor.
- Unzip it.
- Run the map editor (on Linux/MacOS either double click on the .love file or use `$ love 2d_map_editor.love` from the command prompt).
- Add whatever tilesets (.png) you'd like to righthand panel.
- Create a new map with values of choosing from menubar, and start drawing your map.
- Export map to local destination of choosing. An accompanied tilesetIndex.txt will follow so your game will now what tileset have which index from exported .txt, lua or json file.

### Shortcuts

| Keys 	| Description |
|---	|---
| <kbd>D</kbd>	|	Draw	|
| <kbd>E</kbd>	|	Erase	|
| <kbd>F</kbd>	|	Fill	|
| <kbd>Alt</kbd>	|	Tile picker	|
| Mouse Right	|	Tile picker	|
| <kbd>←</kbd><kbd>↑</kbd><kbd>→</kbd><kbd>↓</kbd>	|	Move	|
| <kbd>Spacebar</kbd> + Mouse Left	|	Move	|
| Mouse Wheel	| Zoom	|

---

## Input/Output Format

## Importing a Map to Your Project

### With Lua (5.1)

### Without Lua

## Building

## Project Status

## Why this Project