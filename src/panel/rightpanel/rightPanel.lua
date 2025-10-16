-- Main right panel coordinator
local rightPanel = {}
local browseButton = require("panel.rightpanel.browseButton")
local tilesetDisplay = require("panel.rightpanel.tilesetDisplay")
local tilesetScroll = require("panel.rightpanel.tilesetScroll")
local tilesetClick = require("panel.rightpanel.tilesetClick")

rightPanel.width = 200
rightPanel.height = window.height

function rightPanel.draw()
  love.graphics.setColor(85/255, 85/255, 85/255)
  love.graphics.rectangle("fill", window.width-rightPanel.width, menuBar.height + hud.topBar.height, rightPanel.width, rightPanel.height - menuBar.height - hud.topBar.height)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", window.width-rightPanel.width, menuBar.height + hud.topBar.height, 1, rightPanel.height - menuBar.height - hud.topBar.height)
  
  -- Draw browse button at top of right panel
  browseButton.draw()
end

function rightPanel.drawTile(pX, pY, spacing, pTileWidth)
  tilesetDisplay.drawTile(pX, pY, spacing, pTileWidth)
end

function rightPanel.scrollTileset(deltaY)
  return tilesetScroll.scrollTileset(deltaY)
end

function rightPanel.mousepressed(x, y, button)
  if button == 1 then
    -- Check browse button first
    if browseButton.mousepressed(x, y) then
      return true
    end
    
    -- Handle tileset clicks only if in right bar
    if mouse.zone == "rightBar" then
      return tilesetClick.handleTilesetClick(x, y)
    end
  end
  return false
end

function rightPanel.updateDimensions()
  rightPanel.height = window.height
end

return rightPanel