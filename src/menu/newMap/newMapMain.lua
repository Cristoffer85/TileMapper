-- New map dialog controller
local newMap = {}
local input = require("utils.input")
local mapValidator = require("menu.newMap.projectValidator")

-- Use centralized modalFields for new map modal
input.modalFields.fields = {"mapName", "mapWidth", "mapHeight", "tileSize"}
input.modalFields.selectedField = 1
input.modalFields.mapName = input.modalFields.mapName or "NewMap"
input.modalFields.mapWidth = input.modalFields.mapWidth or "128"
input.modalFields.mapHeight = input.modalFields.mapHeight or "128"
input.modalFields.tileSize = input.modalFields.tileSize or "64"

function newMap.draw(menu)
  -- Modal background dimensions
  local modalWidth = 420
  local modalHeight = 240
  local windowW, windowH = window.width, window.height
  local modalX = (windowW - modalWidth) / 2
  local modalY = (windowH - modalHeight) / 2

  -- Center fields and Create button (no background)
  local fieldHeight = 22
  local fieldSpacing = 6
  local fieldLabelWidth = 120
  local fieldInputWidth = 150
  local font = Font
  love.graphics.setFont(font)
  local numFields = #input.modalFields.fields
  local totalFieldsHeight = numFields * fieldHeight + (numFields-1) * fieldSpacing
  local fieldsY = modalY + (modalHeight - totalFieldsHeight - 40) / 2
  local col2x = modalX + (modalWidth - (fieldLabelWidth + fieldInputWidth + 20)) / 2

  for i, field in ipairs(input.modalFields.fields) do
    local y = fieldsY + (i-1)*(fieldHeight+fieldSpacing)
    local label = (field == "mapName" and "Map Name:") or (field == "mapWidth" and "Map Width:") or (field == "mapHeight" and "Map Height:") or (field == "tileSize" and "Tile Size:")
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(label, col2x + 20, y)
    local inputX = col2x + 20 + fieldLabelWidth
    local selected = (input.modalFields.selectedField == i)
    love.graphics.setColor(selected and {0.5, 0.5, 0.8} or {0.3, 0.3, 0.3})
    love.graphics.rectangle("fill", inputX, y, fieldInputWidth, fieldHeight)
    if selected and input.modalFields.selectAll then
      love.graphics.setColor(0.2, 0.5, 0.9, 0.5)
      love.graphics.rectangle("fill", inputX+1, y+1, fieldInputWidth-2, fieldHeight-2)
    end
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("line", inputX, y, fieldInputWidth, fieldHeight)
    love.graphics.setColor(1, 1, 1)
    local value = tostring(input.modalFields[field] or "")
    if selected then
      local t = love.timer.getTime()
      if math.floor(t * 2) % 2 == 0 and not input.modalFields.selectAll then
        value = value .. "|"
      end
    end
    love.graphics.print(value, inputX + 5, y + 3)
  end

  -- Draw Create button below all fields, centered
  local buttonW = 100
  local buttonH = fieldHeight
  local createY = fieldsY + numFields * (fieldHeight + fieldSpacing) + 8
  local labelX = col2x + 20
  local inputX = labelX + fieldLabelWidth
  local createButtonX = labelX + ((inputX - labelX + fieldInputWidth) / 2) - (buttonW / 2)
  love.graphics.setColor(0.2, 0.7, 0.3)
  love.graphics.rectangle("fill", createButtonX, createY, buttonW, buttonH)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", createButtonX, createY, buttonW, buttonH)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Create", createButtonX + (buttonW-60)/2, createY + 3)
end

function newMap.mousepressed(x, y, menu)
  -- Modal background dimensions (must match draw)
  local modalWidth = 420
  local modalHeight = 240
  local windowW, windowH = window.width, window.height
  local modalX = (windowW - modalWidth) / 2
  local modalY = (windowH - modalHeight) / 2
  local fieldHeight = 22
  local fieldSpacing = 6
  local fieldLabelWidth = 120
  local fieldInputWidth = 150
  local numFields = #input.modalFields.fields
  local totalFieldsHeight = numFields * fieldHeight + (numFields-1) * fieldSpacing
  local fieldsY = modalY + (modalHeight - totalFieldsHeight - 40) / 2
  local col2x = modalX + (modalWidth - (fieldLabelWidth + fieldInputWidth + 20)) / 2
  -- Create button position (must match draw)
  local buttonW = 100
  local buttonH = fieldHeight
  local createY = fieldsY + numFields * (fieldHeight + fieldSpacing) + 8
  local labelX = col2x + 20
  local inputX = labelX + fieldLabelWidth
  local createButtonX = labelX + ((inputX - labelX + fieldInputWidth) / 2) - (buttonW / 2)

  -- Check Create button click
  if x >= createButtonX and x <= createButtonX+buttonW and y >= createY and y <= createY+buttonH then
    newMap.create(menu)
    return true
  end
  -- Check field selection
  local menuForFields = {x=col2x, y=fieldsY}
  return input.modalMousepressed(x, y, menuForFields, function()
    newMap.create(menu)
  end, fieldHeight, fieldSpacing)
end

function newMap.textinput(text)
  return input.modalTextinput(text)
end

function newMap.keypressed(key, menu)
  return input.modalKeypressed(key)
end

function newMap.create(menu)
  local fields = input.modalFields
  for _, k in ipairs(fields.fields) do fields[k] = tostring(fields[k] or "") end
  local success, errors = mapValidator.createMap(fields)
  if not success then
    local errorMsg = mapValidator.formatErrors(errors)
    love.window.showMessageBox("Invalid Input", errorMsg, "error")
    return
  end
  if grid then
    grid.mapName = fields.mapName
    grid.isDirty = true -- Mark as dirty on new map
  end
  if grid and camera and grid.width and grid.height and grid.tileWidth and grid.tileHeight then
    local centerX = (grid.width * grid.tileWidth) / 2
    local centerY = (grid.height * grid.tileHeight) / 2
    camera:setPosition(centerX - window.width/2, centerY - window.height/2)
  end
  -- Clear undo stack so ctrl+z cannot revert to old map
  local action = require("utils.action")
  if action and action.ctrlZ and action.ctrlZ.save then
    action.ctrlZ.save = {}
  end
  local menuBar = require("menu.menuBar")
  if menuBar and menuBar.mapSession then
    menuBar.mapSession.hasCreatedMap = true
  end
  menuBar.hideModal()
end

return newMap