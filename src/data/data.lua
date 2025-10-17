local data = {}

local function formatString(str)
  return string.gsub(string.gsub(str, "\r", ""), "\n", "")
end

function data.load()
  local filename = "editor.txt"
  local contentFile = {}
  local baseDirectory = love.filesystem.getSourceBaseDirectory()
  local i = 0
  for line in io.lines(baseDirectory.."/"..filename) do
    i = i+1
    contentFile[i] = formatString(line)
  end
  export.path = baseDirectory.."/"..contentFile[2]
  import.path = baseDirectory.."/"..contentFile[2]
  
  -- Check if this is the new multi-tileset format
  if contentFile[3] == "tileset_count" then
    -- New multi-tileset format
    data.loadMultiTilesetFormat(contentFile)
  else
    -- Legacy single tileset format
    data.loadLegacyFormat(contentFile)
  end
end

function data.loadMultiTilesetFormat(contentFile)
  local tilesetCount = tonumber(contentFile[4])
  
  -- Load tileset paths
  grid.tilesetPaths = {}
  grid.multiTilesetMode = true
  
  local lineIndex = 5
  for i = 1, tilesetCount do
    -- Skip tileset_X line
    lineIndex = lineIndex + 1
    -- Get tileset path
    grid.tilesetPaths[i] = contentFile[lineIndex]
    lineIndex = lineIndex + 1
  end
  
  -- Set primary tileset for compatibility
  grid.tileSetPath = grid.tilesetPaths[1]
  
  -- Load tile dimensions and grid size
  while lineIndex <= #contentFile do
    if contentFile[lineIndex] == "tile_width" then
      grid.tileWidth = tonumber(contentFile[lineIndex + 1])
      lineIndex = lineIndex + 2
    elseif contentFile[lineIndex] == "tile_height" then
      grid.tileHeight = tonumber(contentFile[lineIndex + 1])
      lineIndex = lineIndex + 2
    elseif contentFile[lineIndex] == "grid_width" then
      grid.width = tonumber(contentFile[lineIndex + 1])
      lineIndex = lineIndex + 2
    elseif contentFile[lineIndex] == "grid_height" then
      grid.height = tonumber(contentFile[lineIndex + 1])
      lineIndex = lineIndex + 2
    else
      lineIndex = lineIndex + 1
    end
  end
end

function data.loadLegacyFormat(contentFile)
  grid.multiTilesetMode = false
  grid.tileSetPath = contentFile[4]
  grid.tileWidth = tonumber(contentFile[6])
  grid.tileHeight = tonumber(contentFile[8])
  grid.width = tonumber(contentFile[10])
  grid.height = tonumber(contentFile[12])
end

return data