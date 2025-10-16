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

-- Debug mode
hud.debugMode = true

-- Tile selection protection
hud.tileSelectionProtected = false
hud.protectedTileId = nil
hud.protectionTimer = 0

function hud.leftBar.draw()
  love.graphics.setColor(85/255, 85/255, 85/255)
  love.graphics.rectangle("fill", 0, menuBar.height + hud.topBar.height, hud.leftBar.width, hud.leftBar.height - menuBar.height - hud.topBar.height)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", hud.leftBar.width-1, menuBar.height + hud.topBar.height, 1, hud.leftBar.height - menuBar.height - hud.topBar.height)
end


function hud.rightBar.draw()
  love.graphics.setColor(85/255, 85/255, 85/255)
  love.graphics.rectangle("fill", window.width-hud.rightBar.width, menuBar.height + hud.topBar.height, hud.rightBar.width, hud.rightBar.height - menuBar.height - hud.topBar.height)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", window.width-hud.rightBar.width, menuBar.height + hud.topBar.height, 1, hud.rightBar.height - menuBar.height - hud.topBar.height)
  
  -- Draw browse button at top of right panel
  hud.drawBrowseButton()
  
  -- DEBUG: Show mouse position and zone info
  if hud.debugMode then
    love.graphics.setColor(1, 1, 0)  -- Yellow text
    local mx, my = love.mouse.getPosition()
    local yPos = 200
    love.graphics.print("Mouse: " .. mx .. "," .. my, 10, yPos)
    yPos = yPos + 20
    love.graphics.print("Zone: " .. (mouse.zone or "none"), 10, yPos)
    yPos = yPos + 20
    love.graphics.print("CurrentColor: " .. (mouse.currentColor or "none"), 10, yPos)
    yPos = yPos + 20
    
    -- Show click areas count
    if hud.tilesetClickAreas then
      local totalAreas = 0
      for tilesetIndex, areas in pairs(hud.tilesetClickAreas) do
        totalAreas = totalAreas + #areas
      end
      love.graphics.print("Click areas: " .. totalAreas, 10, yPos)
      yPos = yPos + 20
    end
    
    -- Show tileset info
    if grid.tilesets and #grid.tilesets > 0 then
      love.graphics.print("Tilesets: " .. #grid.tilesets, 10, yPos)
      yPos = yPos + 20
      
      if grid.tilesets[1] then
        love.graphics.print("T1 startId: " .. (grid.tilesets[1].startTileId or "nil"), 10, yPos)
        yPos = yPos + 20
      end
    end
    
    -- Show current tool
    if tool and tool.current then
      love.graphics.print("Tool: " .. tool.current, 10, yPos)
      yPos = yPos + 20
    end
    
    -- Show last click info
    if hud.lastClickInfo then
      love.graphics.print("Last click: " .. hud.lastClickInfo, 10, yPos)
      yPos = yPos + 20
    end
    
    -- Show tileset debug info
    if hud.tilesetDebugInfo then
      love.graphics.print(hud.tilesetDebugInfo, 10, yPos)
      yPos = yPos + 20
    end
    
    -- Show first tile mappings
    if hud.firstTileMappings then
      for i = 1, math.min(3, #hud.firstTileMappings) do
        if hud.firstTileMappings[i] then
          love.graphics.print(hud.firstTileMappings[i], 10, yPos)
          yPos = yPos + 20
        end
      end
    end
    
    -- Show color change debug
    if hud.debugColorChange then
      love.graphics.print("Color: " .. hud.debugColorChange, 10, yPos)
      yPos = yPos + 20
    end
    
    -- Show protection status
    if hud.tileSelectionProtected then
      love.graphics.print("Protected: " .. (hud.protectedTileId or "nil") .. " timer:" .. string.format("%.2f", hud.protectionTimer), 10, yPos)
      yPos = yPos + 20
    end
    
    -- Show tool blocking debug
    if hud.debugToolBlocked then
      love.graphics.print(hud.debugToolBlocked, 10, yPos)
      yPos = yPos + 20
    end
  end
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
  -- Check if any tilesets are available
  if not grid.tileTexture or (#grid.tileTexture == 0 and (not grid.tilesets or #grid.tilesets == 0)) then
    -- Draw "No tilesets" message
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.print("No tilesets available", window.width - hud.rightBar.width + 10, pY)
    love.graphics.print("Use 'Browse Tileset' to add one", window.width - hud.rightBar.width + 10, pY + 20)
    return
  end
  
  if grid.multiTilesetMode then
    hud.drawMultiTilesets(pX, pY, spacing, pTileWidth)
  else
    hud.drawSingleTileset(pX, pY, spacing, pTileWidth)
  end
end

function hud.drawSingleTileset(pX, pY, spacing, pTileWidth)
  -- Safety check
  if not grid.tileTexture or #grid.tileTexture == 0 then
    return
  end
  
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
  
  -- Clear previous frame's click areas and section positions
  hud.tileClickAreas = {}
  hud.tilesetClickAreas = {}
  hud.sectionPositions = {}
  
  local width = hud.rightBar.width - pX * 2
  local rapport = pTileWidth / grid.tileWidth
  local nbColumn = math.floor(width / (pTileWidth + spacing))
  local paddingX = window.width - hud.rightBar.width + pX + (width - nbColumn * (pTileWidth + spacing)) / 2
  
  -- NO SCISSOR CLIPPING - this was causing coordinate mismatch
  local rightBarX = window.width - hud.rightBar.width
  local availableHeight = window.height - pY
  
  local currentY = pY + hud.tileset.scrollOffset
  
  -- Draw each tileset section
  for tilesetIndex, tileset in ipairs(grid.tilesets) do
    local sectionKey = "tileset_" .. tilesetIndex
    local isCollapsed = hud.tileset.collapsedSections[sectionKey]
    
    -- Store section position for click detection
    local sectionInfo = {
      headerY = currentY,
      headerHeight = hud.tileset.sectionHeight,
      contentY = currentY + hud.tileset.sectionHeight + 5,
      isCollapsed = isCollapsed
    }
    hud.sectionPositions[tilesetIndex] = sectionInfo
    
    -- Draw section header ONLY if visible
    local headerY = currentY
    local headerHeight = hud.tileset.sectionHeight
    
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
      local tilesDrawn = hud.drawTilesetSection(tileset, tilesetIndex, paddingX, currentY, pTileWidth, spacing, nbColumn, pY, availableHeight, rapport)
      local tileRows = math.ceil(tilesDrawn / nbColumn)
      currentY = currentY + (tileRows * (pTileWidth + spacing)) + 10
    end
  end
end

function hud.drawTilesetSection(tileset, tilesetIndex, paddingX, startY, pTileWidth, spacing, nbColumn, clipY, clipHeight, rapport)
  local tilesDrawn = 0
  local currentRow = 0
  local currentCol = 0
  
  -- Initialize tileset-specific click areas if not exists
  if not hud.tilesetClickAreas then
    hud.tilesetClickAreas = {}
  end
  hud.tilesetClickAreas[tilesetIndex] = {}
  
  -- Calculate how many tiles this tileset has
  local tilesetWidth = tileset.image:getWidth()
  local tilesetHeight = tileset.image:getHeight()
  local tilesPerRow = math.floor(tilesetWidth / grid.tileWidth)
  local totalRows = math.floor(tilesetHeight / grid.tileHeight)
  local totalTiles = tilesPerRow * totalRows
  
  -- Store debug info for visual display
  if hud.debugMode and tilesetIndex == 1 and not hud.tilesetDebugInfo then
    hud.tilesetDebugInfo = "T1: start=" .. tileset.startTileId .. " total=" .. totalTiles
  end
  
  for localTileId = 1, totalTiles do
    local globalTileId = tileset.startTileId + localTileId - 1
    
    if grid.tileTexture[globalTileId] then
      local x = paddingX + currentCol * (pTileWidth + spacing)
      local y = startY + currentRow * (pTileWidth + spacing)
      
      -- ALWAYS store click area and draw - no clipping interference
      table.insert(hud.tilesetClickAreas[tilesetIndex], {
        x = x, y = y, w = pTileWidth, h = pTileWidth, 
        tileId = globalTileId,
        tilesetIndex = tilesetIndex
      })
      
      -- Store first few tile mappings for debug
      if hud.debugMode and tilesetIndex == 1 and tilesDrawn < 3 then
        if not hud.firstTileMappings then
          hud.firstTileMappings = {}
        end
        hud.firstTileMappings[tilesDrawn + 1] = "pos" .. (tilesDrawn + 1) .. "=tile" .. globalTileId
      end
      
      -- Only draw if visible (simple bounds check)
      if y + pTileWidth >= clipY and y <= clipY + clipHeight and y >= menuBar.height + hud.topBar.height then
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
        
        -- DEBUG: Draw click area boundaries
        if hud.debugMode then
          love.graphics.setColor(1, 0, 0, 0.5)  -- Red with transparency
          love.graphics.rectangle("line", x, y, pTileWidth, pTileWidth)
          
          -- Show tile ID on first few tiles
          if tilesDrawn < 5 then
            love.graphics.setColor(1, 1, 0)
            love.graphics.print(globalTileId, x + 2, y + 2)
          end
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

function hud.update(dt)
  -- Clear tile selection protection after short delay
  if hud.tileSelectionProtected then
    hud.protectionTimer = hud.protectionTimer + dt
    if hud.protectionTimer > 0.1 then  -- 100ms protection
      hud.tileSelectionProtected = false
      hud.protectedTileId = nil
      hud.protectionTimer = 0
    end
  end
end

function hud.scrollTileset(deltaY)
  if mouse.zone == "rightBar" then
    hud.tileset.scrollOffset = hud.tileset.scrollOffset + (deltaY * hud.tileset.scrollSpeed)
    
    -- Calculate bounds to prevent over-scrolling
    local pX = 10
    local pY = 70 + menuBar.height + hud.topBar.height
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
  if button == 1 then
    -- Check browse button first - use direct coordinate check instead of relying on mouse.zone
    if hud.browseButton and 
       x >= hud.browseButton.x and x <= hud.browseButton.x + hud.browseButton.width and
       y >= hud.browseButton.y and y <= hud.browseButton.y + hud.browseButton.height then
      hud.openTilesetBrowser()
      return true
    end
    
    -- Handle tileset clicks only if in right bar
    if mouse.zone == "rightBar" then
      return hud.handleTilesetClick(x, y)
    end
  end
  return false
end

-- Per-tileset coordinate capture approach
hud.tileClickAreas = {}
hud.tilesetClickAreas = {}
hud.sectionPositions = {}

function hud.handleTilesetClick(x, y)
  if not grid.multiTilesetMode or not grid.tilesets then
    return false
  end
  
  -- Store click info for visual debug
  hud.lastClickInfo = "(" .. x .. "," .. y .. ")"
  
  -- First check section headers using stored positions
  local pX = 10
  local width = hud.rightBar.width - pX * 2
  local rightBarX = window.width - hud.rightBar.width
  
  for tilesetIndex, sectionInfo in pairs(hud.sectionPositions) do
    local sectionKey = "tileset_" .. tilesetIndex
    
    -- Check header click using stored position
    if y >= sectionInfo.headerY and y <= sectionInfo.headerY + sectionInfo.headerHeight and 
       x >= rightBarX + 5 and x <= rightBarX + width - 5 then
      hud.tileset.collapsedSections[sectionKey] = not hud.tileset.collapsedSections[sectionKey]
      hud.lastClickInfo = hud.lastClickInfo .. " header " .. tilesetIndex
      return true
    end
  end
  
  -- Then check tile clicks - only in expanded sections
  if hud.tilesetClickAreas then
    for tilesetIndex, tileAreas in pairs(hud.tilesetClickAreas) do
      local sectionKey = "tileset_" .. tilesetIndex
      
      -- Only check tiles if this section is NOT collapsed
      if not hud.tileset.collapsedSections[sectionKey] then
        for i, tileArea in ipairs(tileAreas) do
          if x >= tileArea.x and x <= tileArea.x + tileArea.w and 
             y >= tileArea.y and y <= tileArea.y + tileArea.h then
            local oldColor = mouse.currentColor
            local oldFillColor = mouse.fillColor
            hud.lastClickInfo = hud.lastClickInfo .. " T" .. tilesetIndex .. " area" .. i .. " tile" .. tileArea.tileId
            mouse.currentColor = tileArea.tileId
            mouse.fillColor = tileArea.tileId  -- ALSO set fillColor to prevent override
            
            -- Switch to pen tool for painting (like old system did)
            if tool.current ~= "fill" then 
              tool.current = "pen" 
            end
            
            -- Set protection flag to prevent tool system override
            hud.tileSelectionProtected = true
            hud.protectedTileId = tileArea.tileId
            hud.protectionTimer = 0  -- Reset timer
            
            hud.debugColorChange = "Set " .. tileArea.tileId .. " (was " .. (oldColor or "nil") .. "/" .. (oldFillColor or "nil") .. ")"
            return true
          end
        end
      end
    end
  end
  
  hud.lastClickInfo = hud.lastClickInfo .. " no hit"
  return false
end



function hud.countTilesInSection(tileset, nbColumn)
  -- Count tiles exactly like drawTilesetSection does
  local tilesDrawn = 0
  local tilesetWidth = tileset.image:getWidth()
  local tilesetHeight = tileset.image:getHeight()
  local tilesPerRow = math.floor(tilesetWidth / grid.tileWidth)
  local totalRows = math.floor(tilesetHeight / grid.tileHeight)
  local totalTiles = tilesPerRow * totalRows
  
  for localTileId = 1, totalTiles do
    local globalTileId = tileset.startTileId + localTileId - 1
    if grid.tileTexture[globalTileId] then
      tilesDrawn = tilesDrawn + 1
    end
  end
  
  return tilesDrawn
end

function hud.drawBrowseButton()
  local rightBarX = window.width - hud.rightBar.width
  local buttonX = rightBarX + 10
  local buttonY = menuBar.height + hud.topBar.height + 10
  local buttonWidth = hud.rightBar.width - 20
  local buttonHeight = 30
  
  -- Button background
  love.graphics.setColor(0.3, 0.5, 0.7)
  love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
  
  -- Button border
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", buttonX, buttonY, buttonWidth, buttonHeight)
  
  -- Button text
  love.graphics.setColor(1, 1, 1)
  local buttonText = "Browse Tileset"
  local textWidth = love.graphics.getFont():getWidth(buttonText)
  love.graphics.print(buttonText, buttonX + (buttonWidth - textWidth) / 2, buttonY + 8)
  
  -- Store button for click detection
  hud.browseButton = {x = buttonX, y = buttonY, width = buttonWidth, height = buttonHeight}
end

function hud.openTilesetBrowser()
  local ffi = require("ffi")
  
  -- Define Windows API functions
  ffi.cdef[[
    typedef struct {
      unsigned long lStructSize;
      void* hwndOwner;
      void* hInstance;
      const char* lpstrFilter;
      char* lpstrCustomFilter;
      unsigned long nMaxCustFilter;
      unsigned long nFilterIndex;
      char* lpstrFile;
      unsigned long nMaxFile;
      char* lpstrFileTitle;
      unsigned long nMaxFileTitle;
      const char* lpstrInitialDir;
      const char* lpstrTitle;
      unsigned long Flags;
      unsigned short nFileOffset;
      unsigned short nFileExtension;
      const char* lpstrDefExt;
      void* lCustData;
      void* lpfnHook;
      const char* lpTemplateName;
    } OPENFILENAMEA;
    
    int GetOpenFileNameA(OPENFILENAMEA* lpofn);
    void* GetModuleHandleA(const char* lpModuleName);
    unsigned long GetEnvironmentVariableA(const char* lpName, char* lpBuffer, unsigned long nSize);
  ]]
  
  -- Load required Windows DLLs
  local comdlg32 = ffi.load("comdlg32")
  local kernel32 = ffi.load("kernel32")
  
  -- Create file buffer
  local fileBuffer = ffi.new("char[260]")  -- MAX_PATH
  fileBuffer[0] = 0  -- Null terminate
  
  -- Get user's Pictures folder path
  local picturesPath = ffi.new("char[260]")
  kernel32.GetEnvironmentVariableA("USERPROFILE", picturesPath, 260)
  local initialDir = ffi.string(picturesPath) .. "\\Pictures"
  
  -- Set up OPENFILENAME structure
  local ofn = ffi.new("OPENFILENAMEA")
  ofn.lStructSize = ffi.sizeof("OPENFILENAMEA")
  ofn.hwndOwner = nil
  ofn.lpstrFilter = "PNG Images (*.png)\0*.png\0All Files (*.*)\0*.*\0\0"
  ofn.nFilterIndex = 1
  ofn.lpstrFile = fileBuffer
  ofn.nMaxFile = 260
  ofn.lpstrInitialDir = initialDir
  ofn.lpstrTitle = "Select Tileset Image"
  ofn.Flags = 0x00001000 + 0x00000004  -- OFN_FILEMUSTEXIST + OFN_HIDEREADONLY
  
  -- Show file dialog
  local result = comdlg32.GetOpenFileNameA(ofn)
  
  if result ~= 0 then
    -- File was selected
    local filePath = ffi.string(fileBuffer)
    
    if filePath ~= "" and filePath:lower():match("%.png$") then
      local filename = filePath:match("([^\\]+)$") or filePath:match("([^/]+)$") or filePath
      
      -- Copy file to tileset folder
      hud.copyTilesetToProject(filePath, filename)
      
      -- Force refresh tileset detection and HUD state
      grid.multiTilesetMode = false  -- Reset to trigger re-detection
      grid.autoDetectTilesets()
      grid.load()
      
      -- Reset HUD tileset state
      hud.tileset.scrollOffset = 0
      hud.tileset.collapsedSections = {}
    end
  end
end

function hud.copyTilesetToProject(sourcePath, filename)
  local baseDirectory = love.filesystem.getSourceBaseDirectory()
  local targetDir = baseDirectory .. "/tileset/"
  local targetPath = targetDir .. filename
  
  -- Read source file
  local sourceFile = io.open(sourcePath, "rb")
  if not sourceFile then
    love.window.showMessageBox("Copy Error", "Could not read tileset: " .. sourcePath, "error")
    return false
  end
  
  local data = sourceFile:read("*all")
  sourceFile:close()
  
  -- Write to target directory
  local targetFile = io.open(targetPath, "wb")
  if not targetFile then
    love.window.showMessageBox("Copy Error", "Could not write tileset to: " .. targetPath, "error")
    return false
  end
  
  targetFile:write(data)
  targetFile:close()
  
  return true
end

return hud