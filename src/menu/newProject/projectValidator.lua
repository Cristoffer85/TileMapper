-- Project validation and creation logic
local projectValidator = {}

function projectValidator.validateInput(data)
  local errors = {}
  
  -- Check required fields
  if not data.projectName or data.projectName:match("^%s*$") then
    table.insert(errors, "Project name is required")
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
  
  if not data.tilesetPath or data.tilesetPath == "" then
    table.insert(errors, "Tileset file is required")
  else
    -- Validate tileset file exists
    if not projectValidator.validateTilesetExists(data.tilesetPath) then
      table.insert(errors, "Tileset file '" .. data.tilesetPath .. "' not found in /tileset folder")
    end
  end
  
  return errors
end

function projectValidator.validateTilesetExists(tilesetPath)
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

function projectValidator.createProject(data)
  local errors = projectValidator.validateInput(data)
  if #errors > 0 then
    return false, errors
  end
  
  -- Create new project data
  local success, errorMsg = projectValidator.initializeProject(data)
  if not success then
    return false, {errorMsg}
  end
  
  return true, {}
end

function projectValidator.initializeProject(data)
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
    
    -- Determine if it's an external file or local tileset
    local tilesetPath
    if data.isExternalFile and (data.tilesetPath:match("^[A-Za-z]:") or data.tilesetPath:match("^/")) then
      -- External file - use full path
      tilesetPath = data.tilesetPath
    else
      -- Local file - use relative path
      tilesetPath = "tileset/" .. data.tilesetPath
    end
    
    -- Update grid tileset path
    _G.grid.tileSetPath = tilesetPath
    
    -- Update global data
    if not _G.data then _G.data = {} end
    _G.data.projectName = data.projectName
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
    return false, "Failed to initialize project"
  end
  
  return true, nil
end

function projectValidator.sanitizeFilename(filename)
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

function projectValidator.formatErrors(errors)
  if not errors or #errors == 0 then
    return ""
  end
  
  local formatted = "Please fix the following issues:\n\n"
  for i, error in ipairs(errors) do
    formatted = formatted .. "• " .. error .. "\n"
  end
  
  return formatted
end

function projectValidator.getDefaultValues()
  return {
    projectName = "New Project",
    mapWidth = "20",
    mapHeight = "15",
    tileSize = "32",
    tilesetPath = ""
  }
end

function projectValidator.cloneData(original)
  local copy = {}
  for key, value in pairs(original) do
    if type(value) == "table" then
      copy[key] = projectValidator.cloneData(value)
    else
      copy[key] = value
    end
  end
  return copy
end

return projectValidator