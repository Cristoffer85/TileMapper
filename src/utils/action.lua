local action = {}

-- Button definitions
action.list = {"grid", "resetPos"}
action.importantList = {"resetMap"}

-- Grid state
action.grid = { state = true }

-- Undo/Redo (Ctrl+Z) state
action.ctrlZ = {
  touch1 = false,
  touch2 = false,
  timer = 0,
  hasUsed = false,
  limit = 200,
  save = {},
}

-- Helper: check if a modal is active
local function isModalActive()
  local welcome = package.loaded["menu.welcome.welcome"]
  local menuBar = package.loaded["menu.menuBar"]
  return (welcome and welcome.visible) or (menuBar and menuBar.modal and menuBar.modal.visible)
end

-- Helper: handle left panel button clicks
local function handleLeftBarButtons()
  local spacing, pX, pY, height = 10, 5, 400 + menuBar.height + hud.topBar.height, 30
  for i = 1, #action.list do
    local y = pY + (i-1)*spacing + (i-1)*height
    if mouse.collide(pX, y, height, height) then
      if action.list[i] == "grid" then
        action.grid.state = not action.grid.state
      elseif action.list[i] == "resetPos" then
        action.resetPos()
      end
    end
  end
  -- Clear Map button
  local clearMapY = 650 + menuBar.height + hud.topBar.height
  if mouse.collide(pX, clearMapY, height, height) then
    local answer = love.window.showMessageBox(
      "Warning",
      "Clear map?\n(Its still possible to use ctrl+z afterwards)",
      { "Yes", "No" }
    )
    if answer == 1 then grid.mapLoad() end
  end
end

-- Update action state (call every frame)
function action.update(dt)
  if not isModalActive() then
    action.move(dt)
  end
  action.zoom(dt)
  action.ctrlZUpdate(dt)
end

-- Handle mouse press for left bar
function action.mousepressed(touch)
  if mouse.zone == "leftBar" then
    handleLeftBarButtons()
  end
end

-- Draw grid overlay
function action.draw()
  action.drawGrid()
end

-- Reset camera position and zoom
function action.resetPos()
  camera:setScale(3, 3)
  if grid and camera and grid.width and grid.height and grid.tileWidth and grid.tileHeight then
    local centerX = (grid.width * grid.tileWidth) / 2
    local centerY = (grid.height * grid.tileHeight) / 2
    camera:setPosition(centerX - window.width/2, centerY - window.height/2)
  else
    camera:setPosition(0, 0)
  end
end

-- Keyboard zoom shortcuts
function action.zoom(dt)
  if love.keyboard.isDown("lctrl") and (love.keyboard.isDown("=") or love.keyboard.isDown("+")) then
    action.zoomWheel(1)
  end
  if love.keyboard.isDown("lctrl") and love.keyboard.isDown("-") then
    action.zoomWheel(-1)
  end
end

-- Mouse wheel zoom
function action.zoomWheel(y)
  local zoomSize = 0.14
  local mouseWorldX, mouseWorldY = camera:mousePosition()
  if y < 0 then
    camera:scale(1 + zoomSize, 1 + zoomSize)
  elseif y > 0 then
    camera:scale(1 - zoomSize, 1 - zoomSize)
  end
  local newMouseWorldX, newMouseWorldY = camera:mousePosition()
  camera:move(mouseWorldX - newMouseWorldX, mouseWorldY - newMouseWorldY)
end

-- Camera movement with arrow keys
function action.move(dt)
  local moveSpeed = 10*60*dt
  if love.keyboard.isDown("left") then camera:move(-moveSpeed*camera.scaleX, 0) end
  if love.keyboard.isDown("right") then camera:move(moveSpeed*camera.scaleX, 0) end
  if love.keyboard.isDown("up") then camera:move(0, -moveSpeed*camera.scaleY) end
  if love.keyboard.isDown("down") then camera:move(0, moveSpeed*camera.scaleY) end
end

-- Undo/Redo logic (Ctrl+Z)
function action.ctrlZUpdate(dt)
  local cz = action.ctrlZ
  if #cz.save > 0 then
    local changed = false
    for l = 1, grid.height do
      for c = 1, grid.width do
        if grid.map[l] ~= nil and cz.save[#cz.save][l] ~= nil then
          if cz.save[#cz.save][l][c] ~= grid.map[l][c] then changed = true break end
        else changed = true break end
      end
    end
    if changed then
      cz.save[#cz.save+1] = {}
      local save = cz.save[#cz.save]
      save.height = grid.height
      save.width = grid.width
      for l = 1, grid.height do
        save[l] = {}
        for c = 1, grid.width do
          save[l][c] = grid.map[l][c]
        end
      end
    end
  else
    cz.save[1] = {}
    local save = cz.save[1]
    save.height = grid.height
    save.width = grid.width
    for l = 1, grid.height do
      save[l] = {}
      for c = 1, grid.width do
        save[l][c] = grid.map[l][c]
      end
    end
  end
  -- Ctrl+Z detection
  if (love.keyboard.isDown("lctrl") and not love.keyboard.isDown("z")) or (love.keyboard.isDown("lctrl") and cz.ctrlPressedBeforeZ) then
    cz.ctrlPressedBeforeZ = true
    cz.touch1 = true
    cz.touch2 = love.keyboard.isDown("z")
  else
    cz.ctrlPressedBeforeZ = false
    cz.touch1 = false
    cz.touch2 = false
  end
  if cz.touch1 and cz.touch2 then
    if cz.timer == 0 then
      if #cz.save > 1 then
        table.remove(cz.save, #cz.save)
        local save = cz.save[#cz.save]
        grid.height = save.height
        grid.width = save.width
        grid.mapLoad()
        for l = 1, grid.height do
          for c = 1, grid.width do
            grid.map[l][c] = save[l][c]
          end
        end
      end
    end
    if cz.timer >= 40 then
      cz.timer = 0
      cz.hasUsed = true
    else
      if cz.timer >= 6 and cz.hasUsed == true then
        cz.timer = 0
      else
        cz.timer = cz.timer + 60*dt
      end
    end
  else
    cz.timer = 0
    cz.hasUsed = false
  end
  if #cz.save > cz.limit+1 then
    table.remove(cz.save, 1)
  end
end

-- Draw grid overlay
function action.drawGrid()
  love.graphics.setColor(180/255, 180/255, 180/255, 100/255)
  if action.grid.state then
    for i = 1, grid.height+1 do
      love.graphics.line(0, (i-1)*grid.tileHeight, grid.width*grid.tileWidth, (i-1)*grid.tileHeight)
    end
    for i = 1, grid.width+1 do
      love.graphics.line((i-1)*grid.tileWidth, 0, (i-1)*grid.tileWidth, grid.height*grid.tileHeight)
    end
  else
    love.graphics.line(0, 0, grid.width*grid.tileWidth, 0)
    love.graphics.line(0, grid.height*grid.tileHeight, grid.width*grid.tileWidth, grid.height*grid.tileHeight)
    love.graphics.line(0, 0, 0, grid.height*grid.tileHeight)
    love.graphics.line(grid.width*grid.tileWidth, 0, grid.width*grid.tileWidth, grid.height*grid.tileHeight)
  end
end

return action