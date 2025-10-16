# Multi-Tileset Map Format Example

## How It Works

### 1. Enhanced editor.txt Format
```
export_path
map/
tileset_count
3
tileset_0
tileset/ground.png
tileset_1  
tileset/buildings.png
tileset_2
tileset/decorations.png
tile_width
32
tile_height
32
grid_width
50
grid_height
50
```

### 2. Map File Format (.txt)

**Current (Single Tileset):**
```
1,1,1,5,1,1,1
1,45,13,13,13,13,13
```

**New (Multi-Tileset):**
```
0:1,0:1,0:1,0:5,0:1,0:1,0:1
0:1,1:45,0:13,0:13,0:13,0:13,0:13
2:7,2:8,2:9,1:22,1:23,1:24,0:1
```

Format: `tilesetIndex:tileId`
- `0:1` = Tileset 0 (ground.png), Tile ID 1
- `1:45` = Tileset 1 (buildings.png), Tile ID 45  
- `2:7` = Tileset 2 (decorations.png), Tile ID 7

### 3. Features Implemented

✅ **Multi-Tileset Project Creation**
- Add multiple tilesets in project form
- Browse and select additional PNG files
- Automatic copying to tileset folder

✅ **Enhanced File Format**
- Backward compatible with existing projects
- New format supports unlimited tilesets
- Automatic detection of format type

✅ **Grid System Updates**  
- Multi-tileset loading and rendering
- Proper texture management per tileset
- Seamless integration with existing tools

✅ **Import/Export System**
- Export maps in new `tileset:tile` format
- Auto-detect format on import (backward compatible)
- Convert between single and multi-tileset formats

✅ **File Management**
- Auto-copy external files to project
- Native file browser integration
- Drag & drop support

### 5. Usage Instructions

1. **Create New Project**: Use File > New Project
2. **Add Primary Tileset**: Browse or drag & drop PNG file
3. **Add Additional Tilesets**: Click "Add Tileset" button
4. **Project Generation**: Creates enhanced editor.txt format
5. **Map Editing**: Use tile IDs as normal (system handles multi-tileset automatically)
6. **Export Maps**: Use Export > Export TXT to save in new `tileset:tile` format
7. **Import Maps**: System auto-detects format (old single or new multi-tileset)

### 5. Future Export Options

The system can export to various formats:
- **JSON**: `{"x": 0, "y": 0, "tileset": "ground", "tile": 1}`
- **XML**: `<tile x="0" y="0" tileset="0" id="1"/>`
- **Custom Game Formats**: Easy to adapt tile mapping

### 6. Performance Benefits

- **Organized Assets**: Keep ground, buildings, decorations separate
- **Smaller Files**: Only load needed tilesets
- **Easier Editing**: Logical tile grouping
- **Modular Design**: Add/remove tileset themes easily