local grid = {}
grid.map = {}
grid.width = 50
grid.height = 50
grid.tileWidth = 32
grid.tileHeight = 32
grid.tileTexture = {}
grid.tileSetPath = "tileset/tileset.png"

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
    love.window.showMessageBox(
      "A tileset is required for the editor to run",
      "Make sure the path to the tileset is valid: " .. path,
      "error"
    )
    love.event.quit()
    return
  end
  local data = file:read("*all")
  file:close()
  local fileData = love.filesystem.newFileData(data, "tileset")
  local imgData = love.image.newImageData(fileData)
  grid.tileSet = love.graphics.newImage(imgData)
end

function grid.load()
  -- Auto-detect tilesets in the tileset folder if not already in multi-tileset mode
  if not grid.multiTilesetMode then
    grid.autoDetectTilesets()
  end
  
  -- Check if we're using multi-tileset mode
  if grid.multiTilesetMode and #grid.tilesetPaths > 0 then
    grid.loadMultipleTilesets()
  else
    grid.loadSingleTileset()
  end

  grid.mapLoad()
end

function grid.loadSingleTileset()
  grid.loadExternalImage()

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
  
  local totalTileId = 1
  
  for tilesetIndex, tilesetPath in ipairs(grid.tilesetPaths) do
    local tileset = grid.loadTilesetImage(tilesetPath)
    if tileset then
      grid.tilesets[tilesetIndex] = {
        image = tileset,
        path = tilesetPath,
        startTileId = totalTileId
      }
      
      local nbColumn = tileset:getWidth() / grid.tileWidth
      local nbLine = tileset:getHeight() / grid.tileHeight
      
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
  local path
  -- Check if it's an absolute path (external file)
  if tilesetPath:match("^[A-Za-z]:") or tilesetPath:match("^/") then
    path = tilesetPath
  else
    path = love.filesystem.getSourceBaseDirectory().."/"..tilesetPath
  end
  
  local file = io.open(path, "rb")
  if file == nil then
    love.window.showMessageBox(
      "Tileset not found",
      "Could not load tileset: " .. path,
      "error"
    )
    return nil
  end
  
  local data = file:read("*all")
  file:close()
  local fileData = love.filesystem.newFileData(data, "tileset")
  local imgData = love.image.newImageData(fileData)
  return love.graphics.newImage(imgData)
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
              love.graphics.draw(tileData.image, tileData.quad, x, y)
            end
          else
            -- Single tileset mode: use original method
            love.graphics.draw(grid.tileSet, grid.tileTexture[gridPos], x, y)
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
  local baseDirectory = love.filesystem.getSourceBaseDirectory()
  local tilesetDir = baseDirectory .. "/tileset"
  
  -- Get list of PNG files in tileset directory
  local tilesetFiles = {}
  
  -- Cross-platform directory scanning
  if love.system.getOS() == "Windows" then
    local handle = io.popen('dir "' .. tilesetDir .. '\\*.png" /B 2>nul')
    if handle then
      for file in handle:lines() do
        if file:lower():match("%.png$") then
          table.insert(tilesetFiles, "tileset/" .. file)
        end
      end
      handle:close()
    end
  else
    -- Linux/Mac using ls command
    local handle = io.popen('ls "' .. tilesetDir .. '"/*.png 2>/dev/null')
    if handle then
      for file in handle:lines() do
        local filename = file:match("([^/]+)$")
        if filename and filename:lower():match("%.png$") then
          table.insert(tilesetFiles, "tileset/" .. filename)
        end
      end
      handle:close()
    end
  end
  
  -- Manual scan as fallback (check known files)
  if #tilesetFiles == 0 then
    local knownFiles = {"TileSheet.png", "TileSheet2.png", "tileset.png", "ground.png", "buildings.png", "decorations.png"}
    for _, filename in ipairs(knownFiles) do
      local fullPath = tilesetDir .. "/" .. filename
      local file = io.open(fullPath, "rb")
      if file then
        file:close()
        table.insert(tilesetFiles, "tileset/" .. filename)
      end
    end
  end
  
  -- If we found multiple PNG files, enable multi-tileset mode
  if #tilesetFiles > 1 then
    grid.multiTilesetMode = true
    grid.tilesetPaths = tilesetFiles
    
    -- Sort files alphabetically for consistent ordering
    table.sort(grid.tilesetPaths)
    
    love.window.showMessageBox(
      "Multi-Tileset Mode", 
      "Found " .. #tilesetFiles .. " tilesets. Enabling multi-tileset mode with collapsible sections in right panel.", 
      "info"
    )
  elseif #tilesetFiles == 1 then
    -- Single tileset found, use it
    grid.tileSetPath = tilesetFiles[1]
  end
end

return grid
