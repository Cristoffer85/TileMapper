-- Main panel coordinator - replaces hud.lua
local panelInit = {}

-- Import button system for backward compatibility
panelInit.button = require("src.assets.button")

-- Add tileset property for backward compatibility with tile.lua
local tilesetScroll = require("panel.rightpanel.tilesetScroll")
panelInit.tileset = {
  scrollOffset = 0,  -- This will be dynamically updated
  scrollSpeed = 32,
  collapsedSections = {},
  sectionHeight = 25
}

-- Import all panel components
local leftPanel = require("panel.leftpanel.leftPanel")
local topPanel = require("panel.toppanel.topPanel") 
local rightPanel = require("panel.rightpanel.rightPanel")

-- Create unified interface for backward compatibility
panelInit.leftBar = {}
panelInit.rightBar = {}
panelInit.topBar = {}

-- Delegate properties to actual panels
panelInit.leftBar.width = leftPanel.width
panelInit.leftBar.height = leftPanel.height
panelInit.leftBar.draw = function() leftPanel.draw() end

panelInit.rightBar.width = rightPanel.width  
panelInit.rightBar.height = rightPanel.height
panelInit.rightBar.draw = function() rightPanel.draw() end

panelInit.topBar.width = topPanel.width
panelInit.topBar.height = topPanel.height
panelInit.topBar.draw = function() topPanel.draw() end

-- Delegate main functions
function panelInit.drawButtonLeftBar(pX, pY, spacing, height, name)
  leftPanel.drawButtonLeftBar(pX, pY, spacing, height, name)
end

function panelInit.drawButtonTopBar(pX, pY, spacing, width, name, title)
  topPanel.drawButtonTopBar(pX, pY, spacing, width, name, title)
end

function panelInit.drawTile(pX, pY, spacing, pTileWidth)
  rightPanel.drawTile(pX, pY, spacing, pTileWidth)
end

function panelInit.scrollTileset(deltaY)
  return rightPanel.scrollTileset(deltaY)
end

function panelInit.mousepressed(x, y, button)
  return rightPanel.mousepressed(x, y, button)
end

function panelInit.updateDimensions()
  leftPanel.updateDimensions()
  topPanel.updateDimensions() 
  rightPanel.updateDimensions()
  
  -- Update our interface properties
  panelInit.leftBar.width = leftPanel.width
  panelInit.leftBar.height = leftPanel.height
  panelInit.rightBar.width = rightPanel.width
  panelInit.rightBar.height = rightPanel.height
  panelInit.topBar.width = topPanel.width
  panelInit.topBar.height = topPanel.height
  
  -- Sync tileset scroll offset for backward compatibility
  panelInit.tileset.scrollOffset = tilesetScroll.getScrollOffset()
end

return panelInit