-- Main menu controller
local menu = {}

-- Import menu modules
local newProject = require("menu.newProject.newProjectInit")

menu.state = "none" -- none, newProject
menu.visible = false

-- Menu dimensions and positioning
menu.width = 400
menu.height = 300
menu.x = 0
menu.y = 0

function menu.show(menuType)
  menu.state = menuType or "main"
  menu.visible = true
  menu.updatePosition()
  -- Debug info will be drawn visually, not in message boxes
end

function menu.hide()
  menu.state = "none"
  menu.visible = false
end

function menu.updatePosition()
  menu.x = (window.width - menu.width) / 2
  menu.y = (window.height - menu.height) / 2
end

function menu.isMouseOver(x, y, w, h)
  local mouseX, mouseY = love.mouse.getPosition()
  return mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h
end

function menu.draw()
  if not menu.visible then return end
  -- Draw debug info as yellow text overlay (top-left corner)
  love.graphics.setColor(1, 1, 0)
  love.graphics.print("menu.visible=" .. tostring(menu.visible), 10, 10)
  love.graphics.print("menu.state=" .. tostring(menu.state), 10, 30)
  love.graphics.setColor(1, 1, 1)
  -- Semi-transparent overlay
  love.graphics.setColor(0, 0, 0, 0.7)
  love.graphics.rectangle("fill", 0, 0, window.width, window.height)
  -- Menu background
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle("fill", menu.x, menu.y, menu.width, menu.height)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", menu.x, menu.y, menu.width, menu.height)
  -- Delegate drawing to specific menu modules
  if menu.state == "newProject" or menu.state == "newMap" then
    newProject.draw(menu)
  end
end

function menu.mousepressed(x, y, button)
  if not menu.visible or button ~= 1 then return false end
  
  -- Delegate mouse handling to specific menu modules
  if menu.state == "newProject" or menu.state == "newMap" then
    return newProject.mousepressed(x, y, menu)
  end
  return false
end

function menu.textinput(text)
  if not menu.visible then return false end
  
  -- Delegate text input to specific menu modules
  if menu.state == "newProject" or menu.state == "newMap" then
    return newProject.textinput(text)
  end
  
  return false
end

function menu.keypressed(key)
  if not menu.visible then return false end
  
  if key == "escape" then
    menu.hide()
    return true
  end
  
  -- Delegate key handling to specific menu modules
  if menu.state == "newProject" or menu.state == "newMap" then
    return newProject.keypressed(key, menu)
  end
  
  return false
end

return menu