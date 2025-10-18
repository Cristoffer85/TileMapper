local newMap = require("menu.newMap.newMapInit")
local didStartupCamera = false
io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")
if arg[#arg] == "-debug" then require("mobdebug").start() end
utf8 = require("utf8")

mouseTouch1 = 1
mouseTouch2 = 2

window = {}
window.width = 1200
window.height = 700
Font = love.graphics.newFont(16)

data = require("data.data")
camera = require("ui.camera")
action = require("src.action.action")
tool = require("tools.tool")
tile = require("ui.tile")
mouse = require("src.action.mouse")
grid = require("ui.grid")
hud = require("panel.panelInit")
export = require("src.menu.export.export")
import = require("src.menu.import.import")
input = require("src.action.input")
menuBar = require("src.menu.menuBar")

function love.load()
  
  -- Set default grid size to 48x48 tiles, tile size 64
  grid.width = 48
  grid.height = 48
  grid.tileWidth = 64
  grid.tileHeight = 64
  grid.load()

  action.resetPos.f()

  -- Center camera on middle tile and zoom out for a wider view (do this last)
  if camera and grid.width and grid.height and grid.tileWidth and grid.tileHeight and hud and hud.leftBar and hud.rightBar and hud.topBar then
    local usableWidth = window.width - (hud.leftBar.width or 0) - (hud.rightBar.width or 0)
    local usableHeight = window.height - (hud.topBar.height or 0)
    local centerX = (grid.width * grid.tileWidth) / 2
    local centerY = (grid.height * grid.tileHeight) / 2
  local offsetX = 80  -- move more to the left
  local offsetY = 60  -- move more down
  camera:setPosition(centerX - usableWidth/2 + (hud.leftBar.width or 0) - offsetX, centerY - usableHeight/2 + (hud.topBar.height or 0) + offsetY)
    camera:setScale(0.25, 0.25) -- Zoom out to show much more of the map
  end

  -- Load button images after Love2D is properly initialized
  hud.button.load()

  window.grid = {}
  window.grid.width = window.width-hud.leftBar.width-hud.rightBar.width
  window.grid.height = window.height-hud.topBar.height-menuBar.height

  action.resetPos.f()
  
end

function love.mousepressed(x, y, touch)
  -- MenuBar input has highest priority
  if menuBar.mousepressed(x, y, touch) then
    return
  end
  
  -- Modal dialog input
  if menuBar.modalMousepressed(x, y, touch) then
    return
  end
  
  -- HUD input for tileset selection
  if hud.mousepressed(x, y, touch) then
    return
  end
  
  action.mousepressed(touch)
  -- removed import/export mousepressed
  input.mousepressed(touch)
end

function love.textinput(t)
  -- Modal dialog input
  if menuBar.modalTextinput(t) then
    return
  end
  input.textinput(t)
end

function love.keypressed(key)
  -- Modal dialog input
  if menuBar.modalKeypressed(key) then
    return
  end
  input.keypressed(key)
end

function love.wheelmoved(x, y)
  -- Try tileset scrolling first
  if not hud.scrollTileset(y) then
    -- If tileset didn't consume the scroll, use for zooming
    action.zoom.wheelmoved(y)
  end
end

function love.resize(w, h)
  window.width = w
  window.height = h
  hud.updateDimensions()
  window.grid.width = window.width-hud.leftBar.width-hud.rightBar.width
  window.grid.height = window.height-hud.topBar.height-menuBar.height
  menuBar.updateModalPosition()
end

function love.update(dt)
  
  -- One-time camera centering and zoom after all initializations
  if not didStartupCamera and camera and grid and grid.width and grid.height and grid.tileWidth and grid.tileHeight and hud and hud.leftBar and hud.rightBar and hud.topBar then
    local usableWidth = window.width - (hud.leftBar.width or 0) - (hud.rightBar.width or 0)
    local usableHeight = window.height - (hud.topBar.height or 0)
    local centerX = (grid.width * grid.tileWidth) / 2
    local centerY = (grid.height * grid.tileHeight) / 2
    local offsetX = -160  -- move more to the left
    local offsetY = -120  -- move more down
  camera:setPosition(centerX - usableWidth/2 + (hud.leftBar.width or 0) - offsetX, centerY - usableHeight/2 + (hud.topBar.height or 0) + offsetY)
    camera:setScale(6, 6)
    didStartupCamera = true
  end

  mouse.update()
  action.update(dt)
  tool.update()
  tile.update()
  menuBar.update()
  
end

function love.draw()
  
  love.graphics.setBackgroundColor(50/255, 50/255, 50/255)
  
  camera:set()
    grid.draw()
    action.grid.f()
  camera:unset()
  
  hud.leftBar.draw()
  hud.rightBar.draw()
  hud.topBar.draw()
  
  hud.drawButtonLeftBar(5, 50 + menuBar.height + hud.topBar.height, 10, 30, tool.list)
  hud.drawButtonLeftBar(5, 400 + menuBar.height + hud.topBar.height, 10, 30, action.list)
  hud.drawButtonLeftBar(5, 650 + menuBar.height + hud.topBar.height, 10, 30, action.importantList)
  -- removed export/import buttons from top panel
  hud.drawTile(10, 70 + menuBar.height + hud.topBar.height, 1, 32)
  input.draw()
  
  -- Draw menu bar
  menuBar.draw()
  
  
end

function love.filedropped(file)
  -- Handle file drops for tileset selection when in new map modal
  if menuBar.modal and menuBar.modal.state == "newMap" and newMap and newMap.handleFileDrop then
    newMap.handleFileDrop(file)
  end
end