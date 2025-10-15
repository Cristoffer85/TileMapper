-- Main menu interface
local mainMenu = {}

function mainMenu.draw(menu)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(love.graphics.getFont())
  
  local title = "TileMapper"
  local titleWidth = love.graphics.getFont():getWidth(title)
  love.graphics.print(title, menu.x + (menu.width - titleWidth) / 2, menu.y + 20)
  
  local buttons = {
    {text = "New Project", action = function() menu.show("newProject") end},
    {text = "Load Project", action = function() menu.loadProject.showDialog() end},
    {text = "Save Project", action = function() menu.saveProject.save() end},
    {text = "Load Tileset", action = function() mainMenu.loadTilesetDialog() end},
    {text = "Recent Projects", action = function() menu.show("loadProject") end},
    {text = "Cancel", action = function() menu.hide() end}
  }
  
  local buttonHeight = 30
  local buttonSpacing = 10
  local startY = menu.y + 60
  
  for i, button in ipairs(buttons) do
    local buttonY = startY + (i - 1) * (buttonHeight + buttonSpacing)
    local buttonX = menu.x + 50
    local buttonW = menu.width - 100
    
    -- Button background
    if menu.isMouseOver(buttonX, buttonY, buttonW, buttonHeight) then
      love.graphics.setColor(0.4, 0.4, 0.4)
    else
      love.graphics.setColor(0.3, 0.3, 0.3)
    end
    love.graphics.rectangle("fill", buttonX, buttonY, buttonW, buttonHeight)
    
    -- Button border
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", buttonX, buttonY, buttonW, buttonHeight)
    
    -- Button text
    love.graphics.setColor(1, 1, 1)
    local textWidth = love.graphics.getFont():getWidth(button.text)
    love.graphics.print(button.text, 
      buttonX + (buttonW - textWidth) / 2, 
      buttonY + (buttonHeight - love.graphics.getFont():getHeight()) / 2)
    
    button.x = buttonX
    button.y = buttonY
    button.w = buttonW
    button.h = buttonHeight
  end
  
  mainMenu.buttons = buttons
end

function mainMenu.mousepressed(x, y, menu)
  for _, btn in ipairs(mainMenu.buttons or {}) do
    if menu.isMouseOver(btn.x, btn.y, btn.w, btn.h) then
      btn.action()
      return true
    end
  end
  return false
end

function mainMenu.loadTilesetDialog()
  love.window.showMessageBox("Load Tileset", 
    "To load a different tileset:\n1. Place the image in the 'tileset' folder\n2. Use 'New Project' to specify the tileset\n\nCurrent tileset: " .. (grid.tileSetPath or "none"), 
    "info")
end

return mainMenu