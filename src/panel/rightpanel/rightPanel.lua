-- Tile selection logic moved to tilesetDisplay.lua
-- Main right panel coordinator
local rightPanel = {}
local browse = require("utils.browse")
local tilesetDisplay = require("panel.rightpanel.tilesetDisplay")
local tilesetScroll = require("panel.rightpanel.tilesetScroll")
local tilesetClick = require("panel.rightpanel.tilesetClick")

-- Global for right panel width to avoid circular require
RIGHT_PANEL_WIDTH = 240
rightPanel.width = 240
rightPanel.height = window.height

function rightPanel.draw()
  love.graphics.setColor(85/255, 85/255, 85/255)
  -- Shift rightpanel down by menuBar.height
  love.graphics.rectangle("fill", window.width-rightPanel.width, menuBar.height + 40, rightPanel.width, rightPanel.height - menuBar.height - 40)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", window.width-rightPanel.width, menuBar.height + 40, 1, rightPanel.height - menuBar.height - 40)
  
  -- Draw browse button at top of right panel
  local rightBarX = window.width - rightPanel.width
  local buttonX = rightBarX + 10
  local buttonY = menuBar.height + 40 + 10
  local buttonWidth = rightPanel.width - 20
  local buttonHeight = 30
  love.graphics.setColor(0.3, 0.5, 0.7)
  love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", buttonX, buttonY, buttonWidth, buttonHeight)
  love.graphics.setColor(1, 1, 1)
  local buttonText = "Add Tileset.."
  local textWidth = love.graphics.getFont():getWidth(buttonText)
  love.graphics.print(buttonText, buttonX + (buttonWidth - textWidth) / 2, buttonY + 8)
  rightPanel.browseButton = {x = buttonX, y = buttonY, width = buttonWidth, height = buttonHeight}
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
    if rightPanel.browseButton and 
       x >= rightPanel.browseButton.x and x <= rightPanel.browseButton.x + rightPanel.browseButton.width and
       y >= rightPanel.browseButton.y and y <= rightPanel.browseButton.y + rightPanel.browseButton.height then
      browse.openTilesetImage()
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