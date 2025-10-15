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

data = require("data")
camera = require("camera")
action = require("action")
tool = require("tool")
tile = require("tile")
mouse = require("mouse")
grid = require("grid")
hud = require("hud")
export = require("export")
import = require("import")
input = require("input")
menu = require("menu")
menuBar = require("menuBar")



function love.load()
  
  data.load()
  grid.load()
  input.load()
  
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
  
  -- Menu input has priority
  if menu.mousepressed(x, y, touch) then
    return
  end
  
  action.mousepressed(touch)
  import.mousepressed(touch)
  export.mousepressed(touch)
  input.mousepressed(touch)
end

function love.textinput(t)
  -- Menu input has priority
  if menu.textinput(t) then
    return
  end
  input.textinput(t)
end

function love.keypressed(key)
  -- Menu input has priority
  if menu.keypressed(key) then
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
  menu.updatePosition()
end

function love.update(dt)
  
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
  
  hud.drawButtonLeftBar(5, 50 + menuBar.height, 10, 30, tool.list)
  hud.drawButtonLeftBar(5, 400 + menuBar.height, 10, 30, action.list)
  hud.drawButtonLeftBar(5, 650 + menuBar.height, 10, 30, action.importantList)
  hud.drawButtonTopBar(450, 5 + menuBar.height, 10, 30, export.list, "Export")
  hud.drawButtonTopBar(700, 5 + menuBar.height, 10, 30, import.list, "Import")
  hud.drawTile(10, 100 + menuBar.height, 1, 32)
  input.draw()
  
  -- Draw menu bar
  menuBar.draw()
  
  -- Draw menu on top of everything
  menu.draw()
  
end

function love.filedropped(file)
  -- Handle file drops for tileset selection when in new project menu
  if menu and menu.state and menu.state == "newProject" and menu.currentMenu and menu.currentMenu.handleFileDrop then
    menu.currentMenu.handleFileDrop(file)
  end
end