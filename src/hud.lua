local hud = {}
hud.button = require("button")

hud.leftBar = {}
hud.leftBar.width = 40
hud.leftBar.height = window.height

hud.rightBar = {}
hud.rightBar.width = 200
hud.rightBar.height = window.height

hud.topBar = {}
hud.topBar.width = window.width
hud.topBar.height = 40

-- Tileset scrolling and multi-tileset support
hud.tileset = {
  scrollOffset = 0,
  scrollSpeed = 32,
  collapsedSections = {},  -- Track which tileset sections are collapsed
  sectionHeight = 25,      -- Height of each section header
  tileSize = 32           -- Display size of tiles in panel
}

function hud.leftBar.draw()
  love.graphics.setColor(85/255, 85/255, 85/255)
  love.graphics.rectangle("fill", 0, menuBar.height, hud.leftBar.width, hud.leftBar.height - menuBar.height)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", hud.leftBar.width-1, menuBar.height, 1, hud.leftBar.height - menuBar.height)
end


function hud.rightBar.draw()
  love.graphics.setColor(85/255, 85/255, 85/255)
  love.graphics.rectangle("fill", window.width-hud.rightBar.width, menuBar.height, hud.rightBar.width, hud.rightBar.height - menuBar.height)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", window.width-hud.rightBar.width, menuBar.height, 1, hud.rightBar.height - menuBar.height)
end


function hud.topBar.draw()
  love.graphics.setColor(85/255, 85/255, 85/255)
  love.graphics.rectangle("fill", 0, menuBar.height, hud.topBar.width, hud.topBar.height)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, menuBar.height + hud.topBar.height-1, hud.topBar.width, 1)
end



function hud.drawButtonLeftBar(pX, pY, spacing, height, name)
  love.graphics.setColor(1, 1, 1)
  local i
  for i = 1, #name do
    local y = pY+(i-1)*spacing+(i-1)*height
    if tool.current == name[i] then
      love.graphics.draw(hud.button.bg.on, pX, y)
    else
      if mouse.collide(pX, y, height, height) then
        if love.mouse.isDown(mouseTouch1) then
          love.graphics.draw(hud.button.bg.on, pX, y)
        else
          love.graphics.draw(hud.button.bg.over, pX, y)
        end
      else
        love.graphics.draw(hud.button.bg.off, pX, y)
      end
    end
    love.graphics.draw(hud.button.list[name[i]], pX, y)
  end
end


function hud.drawButtonTopBar(pX, pY, spacing, width, name, title)
  love.graphics.setColor(1, 1, 1)
  if title ~= nil then
    love.graphics.setFont(Font)
    love.graphics.print(title, pX-Font:getWidth(title)-10, Font:getHeight(title)/2)
  end
  local i
  for i = 1, #name do
    local x = pX+(i-1)*spacing+(i-1)*width
    if mouse.collide(x, pY, width, width) then
      if love.mouse.isDown(mouseTouch1) then
        love.graphics.draw(hud.button.bg.on, x, pY)
      else
        love.graphics.draw(hud.button.bg.over, x, pY)
      end
    else
      love.graphics.draw(hud.button.bg.off, x, pY)
    end
    love.graphics.draw(hud.button.list[name[i]], x, pY)
  end
end


function hud.drawTile(pX, pY, spacing, pTileWidth)
  if grid.multiTilesetMode then
    hud.drawMultiTilesets(pX, pY, spacing, pTileWidth)
  else
    hud.drawSingleTileset(pX, pY, spacing, pTileWidth)
  end
end

function hud.drawSingleTileset(pX, pY, spacing, pTileWidth)
  local width = hud.rightBar.width-pX*2
  local rapport = pTileWidth/grid.tileWidth
  local nbColumn = math.floor((width)/(pTileWidth+spacing))
  local paddingX = window.width-hud.rightBar.width+pX + (width-nbColumn*(pTileWidth+spacing))/2
  local nbLine = math.floor(((pTileWidth+spacing)*#grid.tileTexture)/width) + 1
  
  -- Setup clipping for scrollable area
  local rightBarX = window.width - hud.rightBar.width
  local availableHeight = window.height - pY
  love.graphics.setScissor(rightBarX, pY, hud.rightBar.width, availableHeight)
  
  love.graphics.setColor(1, 1, 1)
  local l
  for l = 1, nbLine do
    local c
    for c = 1, nbColumn do
      local index = (nbColumn*(l-1))+c
      if grid.tileTexture[index] ~= nil then
        local x = paddingX+(c-1)*(pTileWidth+spacing)
        local y = pY+(l-1)*(pTileWidth+spacing) + hud.tileset.scrollOffset
        
        -- Only draw if tile is visible in the clipped area
        if y + pTileWidth >= pY and y <= pY + availableHeight then
          if mouse.currentColor == (nbColumn*(l-1))+c then
            love.graphics.setColor(50/255, 50/255, 50/255)
            love.graphics.rectangle("fill", x-1, y-1, pTileWidth+2, pTileWidth+2)
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

function hud.drawMultiTilesets(pX, pY, spacing, pTileWidth)
  if not grid.tilesets or #grid.tilesets == 0 then
    return
  end
  
  local width = hud.rightBar.width - pX * 2
  local rapport = pTileWidth / grid.tileWidth
  local nbColumn = math.floor(width / (pTileWidth + spacing))
  local paddingX = window.width - hud.rightBar.width + pX + (width - nbColumn * (pTileWidth + spacing)) / 2
  
  -- Setup clipping for scrollable area
  local rightBarX = window.width - hud.rightBar.width
  local availableHeight = window.height - pY
  love.graphics.setScissor(rightBarX, pY, hud.rightBar.width, availableHeight)
  
  local currentY = pY + hud.tileset.scrollOffset
  
  -- Draw each tileset section
  for tilesetIndex, tileset in ipairs(grid.tilesets) do
    local sectionKey = "tileset_" .. tilesetIndex
    local isCollapsed = hud.tileset.collapsedSections[sectionKey]
    
    -- Draw section header
    local headerY = currentY
    local headerHeight = hud.tileset.sectionHeight
    
    -- Header background
    if headerY + headerHeight >= pY and headerY <= pY + availableHeight then
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
      local tilesDrawn = hud.drawTilesetSection(tileset, tilesetIndex, paddingX, currentY, pTileWidth, spacing, nbColumn, pY, availableHeight, rapport)
      local tileRows = math.ceil(tilesDrawn / nbColumn)
      currentY = currentY + (tileRows * (pTileWidth + spacing)) + 10
    end
  end
  
  -- Reset clipping
  love.graphics.setScissor()
end

function hud.drawTilesetSection(tileset, tilesetIndex, paddingX, startY, pTileWidth, spacing, nbColumn, clipY, clipHeight, rapport)
  local tilesDrawn = 0
  local currentRow = 0
  local currentCol = 0
  
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
      
      -- Only draw if tile is visible in the clipped area
      if y + pTileWidth >= clipY and y <= clipY + clipHeight then
        -- Highlight selected tile
        if mouse.currentColor == globalTileId then
          love.graphics.setColor(50/255, 50/255, 50/255)
          love.graphics.rectangle("fill", x-1, y-1, pTileWidth+2, pTileWidth+2)
        end
        
        -- Draw tile
        love.graphics.setColor(1, 1, 1)
        local tileData = grid.tileTexture[globalTileId]
        if type(tileData) == "table" then
          love.graphics.draw(tileData.image, tileData.quad, x, y, 0, rapport, rapport)
        else
          love.graphics.draw(tileset.image, tileData, x, y, 0, rapport, rapport)
        end
      end
      
      tilesDrawn = tilesDrawn + 1
      currentCol = currentCol + 1
      
      if currentCol >= nbColumn then
        currentCol = 0
        currentRow = currentRow + 1
      end
    end
  end
  
  return tilesDrawn
end

function hud.updateDimensions()
  hud.leftBar.height = window.height
  hud.rightBar.height = window.height
  hud.topBar.width = window.width
end

function hud.scrollTileset(deltaY)
  if mouse.zone == "rightBar" then
    hud.tileset.scrollOffset = hud.tileset.scrollOffset + (deltaY * hud.tileset.scrollSpeed)
    
    -- Calculate bounds to prevent over-scrolling
    local pX = 10
    local pY = 100
    local spacing = 1
    local pTileWidth = 32
    local width = hud.rightBar.width-pX*2
    local nbColumn = math.floor((width)/(pTileWidth+spacing))
    local nbLine = math.floor(((pTileWidth+spacing)*#grid.tileTexture)/width) + 1
    local totalHeight = nbLine * (pTileWidth + spacing)
    local availableHeight = window.height - pY
    
    -- Clamp scroll offset
    local maxScroll = 0
    local minScroll = math.min(0, availableHeight - totalHeight)
    hud.tileset.scrollOffset = math.max(minScroll, math.min(maxScroll, hud.tileset.scrollOffset))
    
    return true -- Consumed the scroll event
  end
  return false -- Did not consume the scroll event
end

function hud.mousepressed(x, y, button)
  if button == 1 and mouse.zone == "rightBar" then
    return hud.handleTilesetClick(x, y)
  end
  return false
end

function hud.handleTilesetClick(x, y)
  if not grid.multiTilesetMode or not grid.tilesets then
    return false
  end
  
  local pX = 10
  local pY = 100 + menuBar.height  -- Same as main.lua drawTile call
  local spacing = 1
  local pTileWidth = hud.tileset.tileSize
  local width = hud.rightBar.width - pX * 2
  local nbColumn = math.floor(width / (pTileWidth + spacing))
  
  local rightBarX = window.width - hud.rightBar.width
  local currentY = pY + hud.tileset.scrollOffset
  
  -- Check each tileset section
  for tilesetIndex, tileset in ipairs(grid.tilesets) do
    local sectionKey = "tileset_" .. tilesetIndex
    local headerHeight = hud.tileset.sectionHeight
    
    -- Check if click is on section header
    if y >= currentY and y <= currentY + headerHeight and x >= rightBarX + 5 and x <= rightBarX + width - 5 then
      -- Toggle collapse state
      hud.tileset.collapsedSections[sectionKey] = not hud.tileset.collapsedSections[sectionKey]
      return true
    end
    
    currentY = currentY + headerHeight + 5
    
    -- Check tile clicks if section is not collapsed
    if not hud.tileset.collapsedSections[sectionKey] then
      local tileClicked = hud.checkTileClick(tileset, tilesetIndex, x, y, currentY, pX, pTileWidth, spacing, nbColumn)
      if tileClicked then
        return true
      end
      
      -- Calculate section height to advance currentY
      local tilesetWidth = tileset.image:getWidth()
      local tilesetHeight = tileset.image:getHeight()
      local tilesPerRow = math.floor(tilesetWidth / grid.tileWidth)
      local totalRows = math.floor(tilesetHeight / grid.tileHeight)
      local totalTiles = tilesPerRow * totalRows
      local tileRows = math.ceil(totalTiles / nbColumn)
      currentY = currentY + (tileRows * (pTileWidth + spacing)) + 10
    end
  end
  
  return false
end

function hud.checkTileClick(tileset, tilesetIndex, clickX, clickY, startY, pX, pTileWidth, spacing, nbColumn)
  local paddingX = window.width - hud.rightBar.width + pX + ((hud.rightBar.width - pX * 2) - nbColumn * (pTileWidth + spacing)) / 2
  
  local tilesetWidth = tileset.image:getWidth()
  local tilesetHeight = tileset.image:getHeight()
  local tilesPerRow = math.floor(tilesetWidth / grid.tileWidth)
  local totalRows = math.floor(tilesetHeight / grid.tileHeight)
  local totalTiles = tilesPerRow * totalRows
  
  local currentRow = 0
  local currentCol = 0
  
  for localTileId = 1, totalTiles do
    local globalTileId = tileset.startTileId + localTileId - 1
    
    if grid.tileTexture[globalTileId] then
      local x = paddingX + currentCol * (pTileWidth + spacing)
      local y = startY + currentRow * (pTileWidth + spacing)
      
      -- Check if click is within this tile's bounds
      if clickX >= x and clickX <= x + pTileWidth and clickY >= y and clickY <= y + pTileWidth then
        mouse.currentColor = globalTileId
        return true
      end
      
      currentCol = currentCol + 1
      if currentCol >= nbColumn then
        currentCol = 0
        currentRow = currentRow + 1
      end
    end
  end
  
  return false
end

return hud