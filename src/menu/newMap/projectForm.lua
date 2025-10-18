-- Map form UI and input handling
local mapForm = {}

mapForm.fields = {
  "mapName",
  "mapWidth", 
  "mapHeight",
  "tileSize"
}

function mapForm.draw(menu, data)
  love.graphics.setColor(1, 1, 1)
  
  local title = "Create New Map"
  local titleWidth = love.graphics.getFont():getWidth(title)
  love.graphics.print(title, menu.x + (menu.width - titleWidth) / 2, menu.y + 20)
  
  -- Draw input fields
  mapForm.drawInputFields(menu, data)
  
  -- Draw action buttons
  mapForm.drawActionButtons(menu)
end

function mapForm.drawInputFields(menu, data)
  local fieldY = menu.y + 60
  local fieldHeight = 25
  local labelWidth = 120
  local inputWidth = 150
  
  local fields = {
    {label = "Map Name:", key = "mapName"},
    {label = "Map Width:", key = "mapWidth"},
    {label = "Map Height:", key = "mapHeight"},
    {label = "Tile Size:", key = "tileSize"}
  }
  
  for i, field in ipairs(fields) do
    local y = fieldY + (i - 1) * (fieldHeight + 5)
    
    -- Label
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(field.label, menu.x + 20, y)
    
    -- Input field
    local inputX = menu.x + 20 + labelWidth
    local selected = (data.selectedField == i)
    
    love.graphics.setColor(selected and {0.5, 0.5, 0.8} or {0.3, 0.3, 0.3})
    love.graphics.rectangle("fill", inputX, y, inputWidth, fieldHeight)
    
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("line", inputX, y, inputWidth, fieldHeight)
    
    -- Input text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(data[field.key] or "", inputX + 5, y + 3)
  end
end

function mapForm.drawActionButtons(menu)
  local fieldY = menu.y + 60
  local fieldHeight = 25
  local buttonY = fieldY + 6 * (fieldHeight + 5) + 30
  local createButtonX = menu.x + 50
  local cancelButtonX = menu.x + menu.width - 150
  local buttonW = 100
  
  -- Create button
  love.graphics.setColor(0.2, 0.4, 0.2)
  love.graphics.rectangle("fill", createButtonX, buttonY, buttonW, fieldHeight)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", createButtonX, buttonY, buttonW, fieldHeight)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Create", createButtonX + 30, buttonY + 3)
  
  -- Cancel button
  love.graphics.setColor(0.4, 0.2, 0.2)
  love.graphics.rectangle("fill", cancelButtonX, buttonY, buttonW, fieldHeight)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", cancelButtonX, buttonY, buttonW, fieldHeight)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Cancel", cancelButtonX + 30, buttonY + 3)
  
  -- Store button info
  mapForm.buttons = {
    create = {x = createButtonX, y = buttonY, w = buttonW, h = fieldHeight},
    cancel = {x = cancelButtonX, y = buttonY, w = buttonW, h = fieldHeight}
  }
end

function mapForm.mousepressed(x, y, menu, data, controller)
  local menuBar = require("src.menu.menuBar")
  -- Check input field clicks
  local fieldY = menu.y + 60
  local fieldHeight = 25
  local labelWidth = 120
  local inputWidth = 150
  
  for i = 1, #mapForm.fields do
    local fieldY_pos = fieldY + (i - 1) * (fieldHeight + 5)
    local inputX = menu.x + 20 + labelWidth
    
  if menuBar.isMouseOverMenuItem(inputX, fieldY_pos, inputWidth, fieldHeight) then
      data.selectedField = i
      return true
    end
  end
  
  -- Check action buttons
  if mapForm.buttons then
  if menuBar.isMouseOverMenuItem(mapForm.buttons.create.x, mapForm.buttons.create.y, mapForm.buttons.create.w, mapForm.buttons.create.h) then
      controller.create(menu)
      return true
  elseif menuBar.isMouseOverMenuItem(mapForm.buttons.cancel.x, mapForm.buttons.cancel.y, mapForm.buttons.cancel.w, mapForm.buttons.cancel.h) then
  menuBar.hideModal()
      return true
    end
  end
  
  return false
end

function mapForm.textinput(text, data)
  local field = mapForm.fields[data.selectedField]
  if field then
    data[field] = (data[field] or "") .. text
    return true
  end
  return false
end

function mapForm.keypressed(key, menu, data)
  if key == "tab" then
    data.selectedField = data.selectedField + 1
    if data.selectedField > #mapForm.fields then
      data.selectedField = 1
    end
    return true
  elseif key == "backspace" then
  local field = mapForm.fields[data.selectedField]
    if field and data[field] then
      data[field] = string.sub(data[field], 1, -2)
    end
    return true
  elseif key == "return" then
    -- Trigger create action (would need controller reference)
    return true
  end
  
  return false
end

return mapForm