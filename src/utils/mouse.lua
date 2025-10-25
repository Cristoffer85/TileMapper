local mouse = {}
local function modalActive()
local welcome = package.loaded["menu.welcome.welcome"]
local menuBar = package.loaded["menu.menuBar"]
  return (welcome and welcome.visible) or (menuBar and menuBar.modal and menuBar.modal.visible)
end
mouse.currentColor = 1
mouse.fillColor = mouse.currentColor

function mouse.update()
  mouse.x = love.mouse.getX()
  mouse.y = love.mouse.getY()
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
    mouse.c = math.floor(mx/(grid.tileWidth))+1
    mouse.l = math.floor(my/(grid.tileHeight))+1
  end
end

function mouse.collide(pX, pY, pWidth, pHeight)
  if mouse.x >= pX and mouse.x <= pX+pWidth and mouse.y >= pY and mouse.y <= pY+pHeight then
    return true
  else
    return false
  end
end

return mouse
