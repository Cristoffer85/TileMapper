local grid = {}
grid.map = {}
grid.width = 50
grid.height = 50
grid.tileWidth = 32
grid.tileHeight = 32
grid.tileTexture = {}
grid.tileSetPath = "assets/tileset/tileset.png"

-- Multi-tileset support
grid.tilesets = {}
grid.tilesetPaths = {}
grid.multiTilesetMode = false

function grid.loadExternalImage()
  local path
  -- Check if it's an absolute path (external file)
  if grid.tileSetPath:match("^[A-Za-z]:") or grid.tileSetPath:match("^/") then
    path = grid.tileSetPath
  else
    path = love.filesystem.getSourceBaseDirectory().."/"..grid.tileSetPath
  end
  local file = io.open(path, "rb")
  if file == nil then
    -- Tileset not found - return false but don't crash
    grid.tileSet = nil
    return false
  end
  local data = file:read("*all")
  file:close()
  local fileData = love.filesystem.newFileData(data, "tileset")
  local imgData = love.image.newImageData(fileData)
  grid.tileSet = love.graphics.newImage(imgData)
  return true
end

function grid.load()
  -- Quick auto-detect tilesets (fast check only)
  if not grid.multiTilesetMode then
    grid.autoDetectTilesets()
  end
  
  -- Load tilesets - prioritize fast startup
  if grid.multiTilesetMode and #grid.tilesetPaths > 0 then
    grid.loadMultipleTilesets()
  elseif grid.tileSetPath and grid.tileSetPath ~= "" then
    grid.loadSingleTileset()
  else
    -- No tilesets available - create empty state
    grid.tileTexture = {}
    grid.tilesets = {}
    grid.tileSet = nil
  end

  grid.mapLoad()
end

function grid.loadSingleTileset()
  -- Try to load tileset, but don't crash if it fails
  local success = grid.loadExternalImage()
  if not success or not grid.tileSet then
    grid.tileTexture = {}
    return
  end

  local id = 1
  local nbColumn = grid.tileSet:getWidth() / grid.tileWidth
  local nbLine = grid.tileSet:getHeight() / grid.tileHeight
  for l = 1, nbLine do
    for c = 1, nbColumn do
      grid.tileTexture[id] = love.graphics.newQuad(
        (c-1)*grid.tileWidth,
        (l-1)*grid.tileHeight,
        grid.tileWidth,
        grid.tileHeight,
        grid.tileSet:getWidth(),
        grid.tileSet:getHeight())

      id = id + 1
    end
  end
end

function grid.loadMultipleTilesets()
  -- Clear existing data
  grid.tileTexture = {}
  grid.tilesets = {}
  
  -- Load saved collapsed states, then initialize defaults for new tilesets
  local tilesetScroll = require("panel.rightpanel.tilesetScroll")
  tilesetScroll.loadFromFile()  -- Load saved states first
  tilesetScroll.initializeCollapsedStates(grid.tilesetPaths)  -- Set defaults for any new ones
  
  local totalTileId = 1
  
  for tilesetIndex, tilesetPath in ipairs(grid.tilesetPaths) do
    local tileset = grid.loadTilesetImage(tilesetPath)
    if tileset then
      grid.tilesets[tilesetIndex] = {
        image = tileset,
        path = tilesetPath,
        startTileId = totalTileId
      }
      
      local nbColumn = math.floor(tileset:getWidth() / grid.tileWidth)
      local nbLine = math.floor(tileset:getHeight() / grid.tileHeight)
      
      -- Pre-calculate quad data for faster rendering
      for l = 1, nbLine do
        for c = 1, nbColumn do
          grid.tileTexture[totalTileId] = {
            quad = love.graphics.newQuad(
              (c-1)*grid.tileWidth,
              (l-1)*grid.tileHeight,
              grid.tileWidth,
              grid.tileHeight,
              tileset:getWidth(),
              tileset:getHeight()),
            tilesetIndex = tilesetIndex,
            image = tileset
          }
          totalTileId = totalTileId + 1
        end
      end
    end
  end
end

function grid.loadTilesetImage(tilesetPath)
  print("[DEBUG] Loading tileset: " .. tostring(tilesetPath))
  if not love.filesystem.getInfo(tilesetPath) then
    print("[ERROR] Tileset not found: " .. tostring(tilesetPath))
    return nil
  end
  local img = love.graphics.newImage(tilesetPath)
  print("[DEBUG] Loaded tileset: " .. tostring(tilesetPath))
  return img
end

function grid.mapLoad()
  grid.map = {}
  for l = 1, grid.height do
    grid.map[l] = {}
    for c = 1, grid.width do
      grid.map[l][c] = 0
    end
  end
end


function grid.draw()
  love.graphics.setColor(1, 1, 1, 1)
  for l = 1, grid.height do
    local gridLine = grid.map[l]
    if gridLine ~= nil then
      for c = 1, grid.width do
        local gridPos = gridLine[c]
        if gridPos ~= nil and gridPos ~= 0 then
          local x = (c-1)*grid.tileWidth
          local y = (l-1)*grid.tileHeight
          
          if grid.multiTilesetMode and grid.tileTexture[gridPos] then
            -- Multi-tileset mode: use tileset-specific image
            local tileData = grid.tileTexture[gridPos]
            if type(tileData) == "table" then
              if tileData.quad == nil then
                print("[ERROR] Nil quad for tile index " .. tostring(gridPos) .. " in multi-tileset mode.")
              else
                love.graphics.draw(tileData.image, tileData.quad, x, y)
              end
            end
          else
            -- Single tileset mode: use original method
            if grid.tileTexture[gridPos] == nil then
              print("[ERROR] Nil quad for tile index " .. tostring(gridPos) .. " in single-tileset mode.")
            else
              love.graphics.draw(grid.tileSet, grid.tileTexture[gridPos], x, y)
            end
          end
        end
      end
    end
  end

  love.graphics.setColor(180/255, 180/255, 180/255, 100/255)

  if action.grid.value == true then
    for i = 1, grid.height+1 do
      love.graphics.line(0, (i-1)*grid.tileHeight, grid.width*grid.tileWidth,(i-1)*grid.tileHeight)
    end
    for i = 1, grid.width+1 do
      love.graphics.line((i-1)*grid.tileWidth, 0, (i-1)*grid.tileWidth, grid.height*grid.tileHeight)
    end
  else
    love.graphics.line(0, 0, grid.width*grid.tileWidth, 0)
    love.graphics.line(0, grid.height*grid.tileHeight, grid.width*grid.tileWidth,grid.height*grid.tileHeight)
    love.graphics.line( 0, 0, 0, grid.height*grid.tileHeight)
    love.graphics.line(grid.width*grid.tileWidth, 0, grid.width*grid.tileWidth, grid.height*grid.tileHeight)
  end
end

function grid.autoDetectTilesets()
  local tilesetFiles = {}
  local items = love.filesystem.getDirectoryItems("assets/tileset")
  local count = 0
  print("[DEBUG] Found tileset files:")
  for _, file in ipairs(items) do
    if file:lower():match("%.png$") then
      print("[DEBUG]  " .. file)
      table.insert(tilesetFiles, "assets/tileset/" .. file)
      count = count + 1
      if count >= 20 then break end -- Limit for fast startup
    end
  end
  
  -- If we found multiple PNG files, enable multi-tileset mode
  if #tilesetFiles > 1 then
    grid.multiTilesetMode = true
    grid.tilesetPaths = tilesetFiles
    
    -- Sort files alphabetically for consistent ordering
    table.sort(grid.tilesetPaths)
    
    -- Silent activation - no popup message
  elseif #tilesetFiles == 1 then
    -- Single tileset found, use it
    grid.tileSetPath = tilesetFiles[1]
  end
end

-- Fast function to add a single new tileset without full reload
function grid.addSingleTileset(tilesetPath)
  -- Ensure we're in multi-tileset mode
  if not grid.multiTilesetMode then
    grid.multiTilesetMode = true
    grid.tilesetPaths = grid.tilesetPaths or {}
    grid.tilesets = grid.tilesets or {}
    grid.tileTexture = grid.tileTexture or {}
  end
  
  -- Check if tileset already exists
  local relativePath = "src/assets/tileset/" .. tilesetPath:match("([^/\\]+)$")
  for _, existingPath in ipairs(grid.tilesetPaths) do
    if existingPath == relativePath then
      return -- Already exists, no need to add
    end
  end
  
  -- Add to paths list
  table.insert(grid.tilesetPaths, relativePath)
  table.sort(grid.tilesetPaths) -- Keep sorted
  
  -- Load the new tileset image
  local tileset = grid.loadTilesetImage(relativePath)
  if not tileset then
    return false
  end
  
  -- Find the next available tile ID
  local nextTileId = #grid.tileTexture + 1
  
  -- Add tileset to the list
  local tilesetIndex = #grid.tilesets + 1
  grid.tilesets[tilesetIndex] = {
    image = tileset,
    path = relativePath,
    startTileId = nextTileId
  }
  
  -- Set new tileset as collapsed by default and save the state
  local tilesetScroll = require("panel.rightpanel.tilesetScroll")
  tilesetScroll.setTilesetCollapsed(tilesetIndex, true)
  tilesetScroll.saveToFile()  -- Save updated states
  
  -- Generate quads only for the new tileset
  local nbColumn = math.floor(tileset:getWidth() / grid.tileWidth)
  local nbLine = math.floor(tileset:getHeight() / grid.tileHeight)
  
  for l = 1, nbLine do
    for c = 1, nbColumn do
      grid.tileTexture[nextTileId] = {
        quad = love.graphics.newQuad(
          (c-1)*grid.tileWidth,
          (l-1)*grid.tileHeight,
          grid.tileWidth,
          grid.tileHeight,
          tileset:getWidth(),
          tileset:getHeight()),
        tilesetIndex = tilesetIndex,
        image = tileset
      }
      nextTileId = nextTileId + 1
    end
  end
  
  return true
end

return grid