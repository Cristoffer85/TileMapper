local mouse = {}
local function modalActive()
local welcome = package.loaded["menu.welcome.welcome"]
local menuBar = package.loaded["menu.menuBar"]
  return (welcome and welcome.visible) or (menuBar and menuBar.modal and menuBar.modal.visible)
end
mouse.currentColor = 1
mouse.fillColor = mouse.currentColor

function mouse.update()
  mouse.x = love.mouse.getX() or 0
  mouse.y = love.mouse.getY() or 0
  -- Guard: Only proceed if all dependencies are ready
  if not (menuBar and hud and hud.topBar and hud.leftBar and hud.rightBar and window and camera and grid and grid.tileWidth and grid.tileHeight) then
    mouse.zone = nil
    return
  end
  if modalActive() then
    mouse.zone = nil
    return
  end
  if mouse.y <= menuBar.height then
    mouse.zone = "menuBar"
  elseif mouse.y <= menuBar.height + hud.topBar.height then
    mouse.zone = "topBar"
  elseif mouse.x <= hud.leftBar.width then
    mouse.zone = "leftBar"
  elseif mouse.x >= window.width-hud.rightBar.width then
    mouse.zone = "rightBar"
  else
    mouse.zone = "grid"
    local mx, my = camera:mousePosition()
    if grid.tileWidth and grid.tileHeight then
      mouse.c = math.floor(mx/(grid.tileWidth))+1
      mouse.l = math.floor(my/(grid.tileHeight))+1
    else
      mouse.c = 1
      mouse.l = 1
    end
  end
end

function mouse.collide(pX, pY, pWidth, pHeight)
  if type(mouse.x) ~= 'number' or type(mouse.y) ~= 'number' or type(pX) ~= 'number' or type(pY) ~= 'number' or type(pWidth) ~= 'number' or type(pHeight) ~= 'number' then
    return false
  end
  if mouse.x >= pX and mouse.x <= pX+pWidth and mouse.y >= pY and mouse.y <= pY+pHeight then
    return true
  else
    return false
  end
end

return mouse
