-- Map validation and creation logic
local mapValidator = {}

function mapValidator.validateInput(data)
  local errors = {}
  
  -- Check required fields
  if not data.mapName or data.mapName:match("^%s*$") then
    table.insert(errors, "Map name is required")
  end
  
  -- Convert strings to numbers and validate
  local mapWidth = tonumber(data.mapWidth)
  if not mapWidth or mapWidth <= 0 then
    table.insert(errors, "Map width must be a number greater than 0")
  end
  
  local mapHeight = tonumber(data.mapHeight)
  if not mapHeight or mapHeight <= 0 then
    table.insert(errors, "Map height must be a number greater than 0")
  end
  
  local tileSize = tonumber(data.tileSize)
  if not tileSize or tileSize <= 0 then
    table.insert(errors, "Tile size must be a number greater than 0")
  end
  
  -- Tileset file is NOT required for new map creation. Tilesets are imported/selected later.
  
  return errors
end

function mapValidator.validateTilesetExists(tilesetPath)
  if not tilesetPath or tilesetPath == "" then
    return false
  end
  
  -- Check if it's an absolute path (external file)
  if tilesetPath:match("^[A-Za-z]:") or tilesetPath:match("^/") then
    -- External file - check if it exists
    local f = io.open(tilesetPath, "rb")
    if f then
      f:close()
      return true
    end
    return false
  else
    -- Local file in tileset folder
    local filename = tilesetPath:match("([^/\\]+)$") or tilesetPath
    local baseDirectory = love.filesystem.getSourceBaseDirectory()
    local fullPath = baseDirectory .. "/tileset/" .. filename
    
    local f = io.open(fullPath, "rb")
    if f then
      f:close()
      return true
    end
    return false
  end
end

function mapValidator.createMap(data)
  local errors = mapValidator.validateInput(data)
  if #errors > 0 then
    return false, errors
  end
  
  -- Create new project data with multi-tileset support
  local success, errorMsg = mapValidator.initializeMap(data)
  if not success then
    return false, {errorMsg}
  end
  
  -- Copy external tilesets to project tileset folder if needed
  mapValidator.copyExternalTilesets(data)
  
  return true, {}
end

function mapValidator.initializeMap(data)
  -- Initialize grid data
  if not _G.grid then
    return false, "Grid system not available"
  end
  
  -- Set up the project
  local success = pcall(function()
    -- Convert string inputs to numbers
    local mapWidth = tonumber(data.mapWidth)
    local mapHeight = tonumber(data.mapHeight)
    local tileSize = tonumber(data.tileSize)
    
    -- Set grid dimensions
    _G.grid.width = mapWidth
    _G.grid.height = mapHeight
    _G.grid.tileWidth = tileSize
    _G.grid.tileHeight = tileSize
    
    -- Only set tileset path if provided
    if data.tilesetPath and data.tilesetPath ~= "" then
      local tilesetPath
      if data.isExternalFile and (data.tilesetPath:match("^[A-Za-z]:") or data.tilesetPath:match("^/")) then
        tilesetPath = data.tilesetPath
      else
        tilesetPath = "tileset/" .. data.tilesetPath
      end
      _G.grid.tileSetPath = tilesetPath
    else
      _G.grid.tileSetPath = nil -- No tileset for new map
    end

    -- Update global data
    if not _G.data then _G.data = {} end
    _G.data.mapName = data.mapName
    _G.data.tilesetPath = data.tilesetPath
    _G.data.tilesetDisplayName = data.tilesetDisplayName or data.tilesetPath
    _G.data.isExternalFile = data.isExternalFile or false
    _G.data.mapWidth = mapWidth
    _G.data.mapHeight = mapHeight
    _G.data.tileSize = tileSize
    
    -- Initialize the grid map and load tileset
    _G.grid.mapLoad()
    _G.grid.load()
    
    -- Reset camera and tools
    if _G.camera and _G.camera.reset then
      _G.camera.reset()
    end
    
    if _G.tool and _G.tool.reset then
      _G.tool.reset()
    end
    
    -- Clear any existing tile data by reinitializing the map
    _G.grid.mapLoad()
  end)
  
  if not success then
  return false, "Failed to initialize map"
  end
  
  return true, nil
end

function mapValidator.sanitizeFilename(filename)
  if not filename then return "untitled" end
  
  -- Remove or replace invalid characters
  local sanitized = filename:gsub("[<>:\"/\\|?*]", "_")
  
  -- Remove leading/trailing whitespace
  sanitized = sanitized:match("^%s*(.-)%s*$")
  
  -- Ensure it's not empty
  if sanitized == "" then
    sanitized = "untitled"
  end
  
  return sanitized
end

function mapValidator.formatErrors(errors)
  if not errors or #errors == 0 then
    return ""
  end
  
  local formatted = "Please fix the following issues:\n\n"
  for i, error in ipairs(errors) do
    formatted = formatted .. "• " .. error .. "\n"
  end
  
  return formatted
end

function mapValidator.getDefaultValues()
  return {
    mapName = "New Map",
    mapWidth = "20",
    mapHeight = "15",
    tileSize = "32",
    tilesetPath = ""
  }
end

function mapValidator.cloneData(original)
  local copy = {}
  for key, value in pairs(original) do
    if type(value) == "table" then
  copy[key] = mapValidator.cloneData(value)
    else
  copy[key] = value
    end
  end
  return copy
end

function mapValidator.copyExternalTilesets(data)
  local baseDirectory = love.filesystem.getSourceBaseDirectory()
  local tilesetDir = baseDirectory .. "/tileset/"
  
  -- Copy primary tileset if it's external
  if data.isExternalFile and data.tilesetPath then
    mapValidator.copyTilesetFile(data.tilesetPath, data.tilesetDisplayName, tilesetDir)
  end
  
  -- Copy additional tilesets
  if data.additionalTilesets then
    for i, tileset in ipairs(data.additionalTilesets) do
      if tileset.isExternal and tileset.path then
  mapValidator.copyTilesetFile(tileset.path, tileset.displayName, tilesetDir)
      end
    end
  end
end

function mapValidator.copyTilesetFile(sourcePath, displayName, targetDir)
  -- Read source file
  local sourceFile = io.open(sourcePath, "rb")
  if not sourceFile then
  love.window.showMessageBox("Copy Error", "Could not read tileset: " .. sourcePath, "error")
    return false
  end
  
  local data = sourceFile:read("*all")
  sourceFile:close()
  
  -- Write to target directory
  local targetPath = targetDir .. displayName
  local targetFile = io.open(targetPath, "wb")
  if not targetFile then
  love.window.showMessageBox("Copy Error", "Could not write tileset to: " .. targetPath, "error")
    return false
  end
  
  targetFile:write(data)
  targetFile:close()
  
  return true
end

return mapValidator