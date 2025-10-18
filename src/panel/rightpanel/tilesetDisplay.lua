-- Tileset display functionality
local tilesetDisplay = {}
local tilesetScroll = require("panel.rightpanel.tilesetScroll")

-- Storage for click detection areas
tilesetDisplay.tilesetClickAreas = {}
tilesetDisplay.sectionPositions = {}

function tilesetDisplay.drawTile(pX, pY, spacing, pTileWidth)
  -- Only support multi-tileset mode
  if not grid.tilesets or #grid.tilesets == 0 then
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.print("No tilesets available", window.width - 200 + 10, pY)
    love.graphics.print("Use 'Browse Tileset' to add one", window.width - 200 + 10, pY + 20)
    return
  end
  tilesetDisplay.drawMultiTilesets(pX, pY, spacing, pTileWidth)
end

function tilesetDisplay.drawSingleTileset(pX, pY, spacing, pTileWidth)
  -- Safety check
  if not grid.tileTexture or #grid.tileTexture == 0 then
    return
  end
  
  local rightBarWidth = 200  -- rightPanel.width
  local width = rightBarWidth - pX * 2
  local rapport = pTileWidth / grid.tileWidth
  local nbColumn = math.floor(width / (pTileWidth + spacing))
  local paddingX = window.width - rightBarWidth + pX + (width - nbColumn * (pTileWidth + spacing)) / 2
  local nbLine = math.floor(((pTileWidth + spacing) * #grid.tileTexture) / width) + 1
  
  -- Setup clipping for scrollable area
  local rightBarX = window.width - rightBarWidth
  local availableHeight = window.height - pY
  love.graphics.setScissor(rightBarX, pY, rightBarWidth, availableHeight)
  
  love.graphics.setColor(1, 1, 1)
  local l
  for l = 1, nbLine do
    local c
    for c = 1, nbColumn do
      local index = (nbColumn * (l - 1)) + c
      if grid.tileTexture[index] ~= nil then
        local x = paddingX + (c - 1) * (pTileWidth + spacing)
        local y = pY + (l - 1) * (pTileWidth + spacing) + tilesetScroll.getScrollOffset()
        
        -- Only draw if tile is visible in the clipped area
        if y + pTileWidth >= pY and y <= pY + availableHeight then
          if mouse.currentColor == (nbColumn * (l - 1)) + c then
            love.graphics.setColor(50/255, 50/255, 50/255)
            love.graphics.rectangle("fill", x - 1, y - 1, pTileWidth + 2, pTileWidth + 2)
            love.graphics.setColor(1, 1, 1)
          end
          love.graphics.draw(grid.tileSet, grid.tileTexture[index], x, y, 0, rapport, rapport)
        end
      end
    end
  end
  
  -- Reset clipping
  love.graphics.setScissor()
end

function tilesetDisplay.drawMultiTilesets(pX, pY, spacing, pTileWidth)
  if not grid.tilesets or #grid.tilesets == 0 then
    return
  end
  
  -- Clear previous frame's click areas and section positions
  tilesetDisplay.tilesetClickAreas = {}
  tilesetDisplay.sectionPositions = {}
  
  local rightBarWidth = 200  -- rightPanel.width
  local width = rightBarWidth - pX * 2
  local rapport = pTileWidth / grid.tileWidth
  local nbColumn = math.floor(width / (pTileWidth + spacing))
  local paddingX = window.width - rightBarWidth + pX + (width - nbColumn * (pTileWidth + spacing)) / 2
  
  -- NO SCISSOR CLIPPING - this was causing coordinate mismatch
  local rightBarX = window.width - rightBarWidth
  local availableHeight = window.height - pY
  
  local currentY = pY + tilesetScroll.getScrollOffset()
  
  -- Draw each tileset section
  for tilesetIndex, tileset in ipairs(grid.tilesets) do
    local sectionKey = "tileset_" .. tilesetIndex
    local isCollapsed = tilesetScroll.getCollapsedSections()[sectionKey]
    
    -- Store section position for click detection
    local sectionInfo = {
      headerY = currentY,
      headerHeight = tilesetScroll.getSectionHeight(),
      contentY = currentY + tilesetScroll.getSectionHeight() + 5,
      isCollapsed = isCollapsed
    }
    tilesetDisplay.sectionPositions[tilesetIndex] = sectionInfo
    
    -- Draw section header ONLY if visible
    local headerY = currentY
    local headerHeight = tilesetScroll.getSectionHeight()
    
    if headerY + headerHeight >= pY and headerY <= pY + availableHeight then
      -- Header background
      love.graphics.setColor(0.3, 0.3, 0.3)
      love.graphics.rectangle("fill", rightBarX + 5, headerY, width - 10, headerHeight)
      
      -- Header border
      love.graphics.setColor(0.5, 0.5, 0.5)
      love.graphics.rectangle("line", rightBarX + 5, headerY, width - 10, headerHeight)
      
      -- Collapse/expand indicator
      love.graphics.setColor(1, 1, 1)
      local indicator = isCollapsed and "▶" or "▼"
      love.graphics.print(indicator, rightBarX + 10, headerY + 5)
      
      -- Tileset name
      local tilesetName = tileset.path:match("([^/\\]+)$") or ("Tileset " .. tilesetIndex)
      love.graphics.print(tilesetName, rightBarX + 25, headerY + 5)
    end
    
    currentY = currentY + headerHeight + 5
    
    -- Draw tiles if not collapsed
    if not isCollapsed then
      local tilesDrawn = tilesetDisplay.drawTilesetSection(tileset, tilesetIndex, paddingX, currentY, pTileWidth, spacing, nbColumn, pY, availableHeight, rapport)
      local tileRows = math.ceil(tilesDrawn / nbColumn)
      currentY = currentY + (tileRows * (pTileWidth + spacing)) + 10
    end
  end
end

function tilesetDisplay.drawTilesetSection(tileset, tilesetIndex, paddingX, startY, pTileWidth, spacing, nbColumn, clipY, clipHeight, rapport)
  local tilesDrawn = 0
  local currentRow = 0
  local currentCol = 0
  
  -- Initialize tileset-specific click areas
  if not tilesetDisplay.tilesetClickAreas then
    tilesetDisplay.tilesetClickAreas = {}
  end
  tilesetDisplay.tilesetClickAreas[tilesetIndex] = {}
  
  -- Calculate how many tiles this tileset has
  local tilesetWidth = tileset.image:getWidth()
  local tilesetHeight = tileset.image:getHeight()
  local tilesPerRow = math.floor(tilesetWidth / grid.tileWidth)
  local totalRows = math.floor(tilesetHeight / grid.tileHeight)
  local totalTiles = tilesPerRow * totalRows
  
  for localTileId = 1, totalTiles do
    local globalTileId = tileset.startTileId + localTileId - 1
    
    if grid.tileTexture[globalTileId] then
      local x = paddingX + currentCol * (pTileWidth + spacing)
      local y = startY + currentRow * (pTileWidth + spacing)
      
      -- Store click area for this tileset
      table.insert(tilesetDisplay.tilesetClickAreas[tilesetIndex], {
        x = x, y = y, w = pTileWidth, h = pTileWidth, 
        tileId = globalTileId,
        tilesetIndex = tilesetIndex
      })
      
      -- Only draw if visible
      if y + pTileWidth >= clipY and y <= clipY + clipHeight and y >= menuBar.height + 40 then  -- topBar.height = 40
        -- Highlight selected tile
        if mouse.currentColor == globalTileId then
          love.graphics.setColor(50/255, 50/255, 50/255)
          love.graphics.rectangle("fill", x - 1, y - 1, pTileWidth + 2, pTileWidth + 2)
        end
        
      end
    end
  end
end

return tilesetDisplay