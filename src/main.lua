-- Handle quit confirmation for unsaved changes
local pendingQuit = false

function love.quit()
  -- Only intercept if there are unsaved changes
  if grid and grid.isDirty and not pendingQuit then
    local confirmation = require("ui.confirmation")
    -- If confirmation is already visible, don't show again
    if not confirmation.visible then
      confirmation.show(
        "You have non-exported changes! \n Are you sure you want to quit?",
        function()
          pendingQuit = true
          love.event.quit()
        end,
        function()
          pendingQuit = false
        end
      )
    end
    return true -- Prevent quit for now
  end
  return false -- Allow quit
end
-- Helper to always get welcome modal
local function getWelcome()
  return require("menu.welcome.welcome")
end


local importTilesizeSetter = require("ui.importTilesizeSetter")
local didStartupCamera = false
io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")
if arg[#arg] == "-debug" then require("mobdebug").start() end
utf8 = require("utf8")

mouseTouch1 = 1
mouseTouch2 = 2

window = {}
window.width = 1200
window.height = 760
Font = love.graphics.newFont(16)

-- Loading screen state
local isLoading = true
local loadingTimer = 0
local loadingMinTime = 0.7 -- seconds to show loading screen at minimum
local runningManImg = nil
local runningManFrame = 1
local runningManStartTime = nil
local runningManAnimSpeed = 0.12 -- seconds per frame
local runningManFrames = 8 -- number of frames in the png

local function doDeferredLoad()
  data = require("panel.rightpanel.tilesetLoader")
  camera = require("ui.camera")
  action = require("utils.action")
  mouse = require("utils.mouse")
  grid = require("ui.grid")
  hud = require("panel.panelMain")
  export = require("menu.export.exportMain")
  import = require("menu.import.importMain")
  input = require("utils.input")
  menuBar = require("menu.menuBar")
  leftPanel = require("panel.leftpanel.leftPanel")
  local welcome = getWelcome()
  -- Only load grid, do not set default size (let new map creation handle it)
  grid.load()
  action.resetPos()
  hud.button.load()
  window.grid = {}
  window.grid.width = window.width-hud.leftBar.width-hud.rightBar.width
  window.grid.height = window.height-hud.topBar.height-menuBar.height
  action.resetPos()
  -- Show welcome modal on first load
  welcome.visible = true
end

function love.load()
  runningManImg = love.graphics.newImage("assets/img/runningman.png")
  runningManStartTime = love.timer.getTime()
end

function love.keyreleased(key)
  require("utils.input").modalKeyreleased(key)
end

-- State for right mouse drag
local isRightDragging = false

-- Utility to force stop right drag (e.g. after modal closes)
local function stopRightDrag()
  isRightDragging = false
end

function love.mousepressed(x, y, touch)
  -- Always give importTilesizeSetter priority if visible
  if importTilesizeSetter.visible then
    -- Only pass left mouse button as button 1
    if touch == mouseTouch1 or touch == 1 then
      importTilesizeSetter.mousepressed(x, y, 1)
    end
    return
  end
  -- Always stop right drag on any left mouse press (prevents sticky drag after native dialogs)
  if touch == mouseTouch1 then
    stopRightDrag()
  end
  -- Block all background input if any modal is visible
  local confirmation = require("ui.confirmation")
  if confirmation.visible then
    confirmation.mousepressed(x, y, touch)
    return
  end
  local welcome = getWelcome()
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
  local confirmation = require("ui.confirmation")
  local welcome = getWelcome()
  if confirmation.visible or welcome.visible or (menuBar.modal and menuBar.modal.visible) then
    stopRightDrag()
  elseif touch == mouseTouch2 then
    isRightDragging = false
  end
end

function love.mousemoved(x, y, dx, dy, istouch)
  -- Only move camera if right mouse is dragging and in grid area, and no modal is active
  local confirmation = require("ui.confirmation")
  local welcome = getWelcome()
  if isRightDragging and mouse.zone == "grid" and not (welcome.visible or (menuBar.modal and menuBar.modal.visible) or confirmation.visible) then
    camera:move(-dx * camera.scaleX, -dy * camera.scaleY)
  end
end

function love.textinput(t)
  -- Always give importTilesizeSetter priority if visible
  if importTilesizeSetter.visible then
    importTilesizeSetter.textinput(t)
    return
  end
  -- Block all background input if any modal is visible
  local welcome = getWelcome()
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
  -- Always give importTilesizeSetter priority if visible
  if importTilesizeSetter.visible then
    importTilesizeSetter.keypressed(key)
    return
  end
  -- Block all background input if any modal is visible
  local welcome = getWelcome()
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
    action.zoomWheel(-1)
    return
  elseif key == "kp+" then
    action.zoomWheel(1)
    return
  end
  input.keypressed(key)
end
function love.wheelmoved(x, y)
  -- Block all background input if any modal is visible
  local welcome = getWelcome()
  if welcome.visible or (menuBar.modal and menuBar.modal.visible) then return end
  -- Try tileset scrolling first
  if not hud.scrollTileset(y) then
    -- If tileset didn't consume the scroll, use for zooming
    action.zoomWheel(y)
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
  if isLoading then
    loadingTimer = loadingTimer + dt
    -- Use wall clock time for animation so it always loops
    local now = love.timer.getTime()
    local elapsed = (runningManStartTime and (now - runningManStartTime) or 0)
    runningManFrame = (math.floor(elapsed / runningManAnimSpeed) % runningManFrames) + 1
    -- Don't call mouse.update() or other logic until loaded
    if loadingTimer > loadingMinTime then
      doDeferredLoad()
      isLoading = false
    end
    return
  end
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
  leftPanel.tool.update()
  menuBar.update()
  require("utils.input").update(dt)
end

function love.draw()
  if isLoading then
    local w, h = love.graphics.getDimensions()
    local frameW, frameH = 64, 64
    local frame = runningManFrame
    if runningManImg then
      love.graphics.clear(0.08, 0.08, 0.08, 1)
      local quad = love.graphics.newQuad((frame-1)*frameW, 0, frameW, frameH, runningManImg:getDimensions())
      love.graphics.draw(runningManImg, quad, w/2-frameW/2, h/2-frameH/2)
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf("TileMapper loading...", 0, h/2+frameH/2+16, w, "center")
    return
  end
  love.graphics.setBackgroundColor(50/255, 50/255, 50/255)

  camera:set()
    grid.draw()
  action.drawGrid()
  camera:unset()

  hud.leftBar.draw()
  hud.rightBar.draw()
  hud.topBar.draw()

  hud.drawButtonLeftBar(5, 50 + menuBar.height + hud.topBar.height, 10, 30, leftPanel.tool.list)
  hud.drawButtonLeftBar(5, 400 + menuBar.height + hud.topBar.height, 10, 30, action.list)
  hud.drawButtonLeftBar(5, 650 + menuBar.height + hud.topBar.height, 10, 30, action.importantList)
  hud.drawTile(10, 70 + menuBar.height + hud.topBar.height, 1, 32)
  input.draw()

  -- Always draw menu bar
  menuBar.draw()
  -- Draw confirmation modal above everything if visible
  local confirmation = require("ui.confirmation")
  if confirmation.visible then
    confirmation.draw()
  end
  -- Draw importTilesizeSetter modal above everything if visible
  if importTilesizeSetter.visible then
    importTilesizeSetter.draw()
    return
  end
  -- Draw welcome modal above everything if visible
  local welcome = getWelcome()
  if welcome and welcome.visible then
    welcome.draw()
  end
end