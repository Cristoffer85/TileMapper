local didStartupCamera = false
io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")
if arg[#arg] == "-debug" then require("mobdebug").start() end
utf8 = require("utf8")

mouseTouch1 = 1
mouseTouch2 = 2

window = {}
window.width = 1200
window.height = 800
Font = love.graphics.newFont(16)

data = require("panel.rightpanel.tilesetLoader")
camera = require("ui.camera")
action = require("utils.action")
tool = require("panel.leftpanel.tool")
mouse = require("utils.mouse")
grid = require("ui.grid")
hud = require("panel.panelMain")
export = require("menu.export.exportMain")
import = require("menu.import.importMain")
input = require("utils.input")
menuBar = require("menu.menuBar")

local welcome = require("menu.welcome.welcome")
function love.load()
  -- Only load grid, do not set default size (let new map creation handle it)
  grid.load()

  action.resetPos.f()

  -- Load button images after Love2D is properly initialized
  hud.button.load()
  window.grid = {}
  window.grid.width = window.width-hud.leftBar.width-hud.rightBar.width
  window.grid.height = window.height-hud.topBar.height-menuBar.height

  action.resetPos.f()

  -- Show welcome modal on first load
  welcome.visible = true
end

function love.keyreleased(key)
  require("utils.input").modalKeyreleased(key)
end


-- State for right mouse drag
local isRightDragging = false
local lastDragX, lastDragY = 0, 0

-- Utility to force stop right drag (e.g. after modal closes)
local function stopRightDrag()
  isRightDragging = false
end

function love.mousepressed(x, y, touch)
  -- Always stop right drag on any left mouse press (prevents sticky drag after native dialogs)
  if touch == mouseTouch1 then
    stopRightDrag()
  end
  -- Block all background input if any modal is visible
  local confirmation = require("utils.confirmation")
  if confirmation.visible then
    confirmation.mousepressed(x, y, touch)
    return
  end
  if welcome.visible then
    welcome.mousepressed(x, y, touch)
    return
  end
  if menuBar.modal and menuBar.modal.visible then
    menuBar.modalMousepressed(x, y, touch)
    return
  end
  -- Right mouse button drag for camera movement (only in grid area)
  if touch == mouseTouch2 and mouse.zone == "grid" then
    isRightDragging = true
    lastDragX, lastDragY = x, y
    return
  end
  -- MenuBar input
  if menuBar.mousepressed(x, y, touch) then return end
  if hud.mousepressed(x, y, touch) then return end
  action.mousepressed(touch)
  input.mousepressed(touch)
end

function love.mousereleased(x, y, touch)
  -- Always stop right drag if any modal is visible (prevents sticky drag after modal closes)
  local confirmation = require("utils.confirmation")
  if confirmation.visible or welcome.visible or (menuBar.modal and menuBar.modal.visible) then
    stopRightDrag()
  elseif touch == mouseTouch2 then
    isRightDragging = false
  end
end

function love.mousemoved(x, y, dx, dy, istouch)
  -- Only move camera if right mouse is dragging and in grid area, and no modal is active
  local confirmation = require("utils.confirmation")
  if isRightDragging and mouse.zone == "grid" and not (welcome.visible or (menuBar.modal and menuBar.modal.visible) or confirmation.visible) then
    camera:move(-dx * camera.scaleX, -dy * camera.scaleY)
  end
end

function love.textinput(t)
  -- Block all background input if any modal is visible
  if welcome.visible then
    welcome.textinput(t)
    return
  end
  if menuBar.modal and menuBar.modal.visible then
    menuBar.modalTextinput(t)
    return
  end
  input.textinput(t)
end


function love.keypressed(key)
  -- Block all background input if any modal is visible
  if welcome.visible then
    welcome.keypressed(key)
    return
  end
  if menuBar.modal and menuBar.modal.visible then
    menuBar.modalKeypressed(key)
    return
  end
  -- Zoom in/out with + and - keys (main and keypad)
  if key == "kp-" then
    action.zoom.wheelmoved(-1)
    return
  elseif key == "kp+" then
    action.zoom.wheelmoved(1)
    return
  end
  input.keypressed(key)
end

  if welcome.visible then
    welcome.draw()
  else
    menuBar.draw()
  end
function love.wheelmoved(x, y)
  -- Block all background input if any modal is visible
  if welcome.visible or (menuBar.modal and menuBar.modal.visible) then return end
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
  menuBar.update()
  require("utils.input").update(dt)
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
  hud.drawTile(10, 70 + menuBar.height + hud.topBar.height, 1, 32)
  input.draw()

  -- Always draw menu bar
  menuBar.draw()
  -- Draw confirmation modal above everything if visible
  local confirmation = require("utils.confirmation")
  if confirmation.visible then
    confirmation.draw()
  end
  -- Draw welcome modal above everything if visible
  if welcome.visible then
    welcome.draw()
  end

end