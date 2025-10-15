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

-- Tileset scrolling
hud.tileset = {
  scrollOffset = 0,
  scrollSpeed = 32
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

return hud