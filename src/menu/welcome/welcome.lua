local welcome = {}
local import = require("menu.import.importMain")
local browse = require("utils.browse")

welcome.visible = true
welcome.inWelcomeFlow = true
welcome.width = 660
welcome.height = 340
welcome.x = 0
welcome.y = 0

function welcome.updatePosition()
  welcome.x = (window.width - welcome.width) / 2 - 55
  welcome.y = (window.height - welcome.height) / 2
  welcome.x = (window.width - welcome.width) / 2 - 55
  welcome.y = (window.height - welcome.height) / 2
end

function welcome.draw()
  -- Draw modal background first
  if not welcome.visible then return end
  welcome.updatePosition()
  -- Fade background
  love.graphics.setColor(0, 0, 0, 0.7)
  love.graphics.rectangle("fill", 0, 0, window.width, window.height)
  -- Modal background
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle("fill", welcome.x, welcome.y, welcome.width, welcome.height)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", welcome.x, welcome.y, welcome.width, welcome.height)
  -- Draw vertical divider between columns (after background, before content)
  local dividerX = welcome.x + welcome.width/2 - 80
  love.graphics.setColor(0.1, 0.1, 0.1) -- very dark gray
  love.graphics.setLineWidth(3)
  love.graphics.line(dividerX, welcome.y + 100, dividerX, welcome.y + welcome.height - 30)
  love.graphics.setLineWidth(1)
-- (removed redundant end)

function welcome.textinput(text)
  if not welcome.visible then return false end
  local input = require("utils.input")
  return input.modalTextinput(text)
end

function welcome.keypressed(key)
  if not welcome.visible then return false end
  local input = require("utils.input")
  return input.modalKeypressed(key)
end
  -- Welcome text
  love.graphics.setColor(1, 1, 1)
  local title = "Welcome to TileMapper!"
  local subtitle = "Would you like to load a previous map or start a new one?"
  local font = Font
  love.graphics.setFont(font)
  local titleW = font:getWidth(title)
  local subtitleW = font:getWidth(subtitle)
  love.graphics.print(title, welcome.x + (welcome.width-titleW)/2, welcome.y + 24)
  love.graphics.setColor(0.9, 0.9, 0.9)
  love.graphics.print(subtitle, welcome.x + (welcome.width-subtitleW)/2, welcome.y + 60)
  -- Draw import buttons (left column)
  local btnW, btnH, spacing = 140, 36, 12
  local col1x = welcome.x + 40
  local btnY = welcome.y + 110
  local importLabels = { {"Import .txt", ".txt", import.txt}, {"Import .json", ".json", import.json}, {"Import .lua", ".lua", import.lua} }
  for i, btn in ipairs(importLabels) do
    local by = btnY + (i-1)*(btnH+spacing)
    love.graphics.setColor(0.3, 0.5, 0.9)
    love.graphics.rectangle("fill", col1x, by, btnW, btnH, 8, 8)
    love.graphics.setColor(1, 1, 1)
    local labelW = font:getWidth(btn[1])
    love.graphics.print(btn[1], col1x + (btnW-labelW)/2, by + (btnH-font:getHeight())/2)
  end

  -- Draw new map fields and create button (right column, aligned, with compressed spacing)
  local input = require("utils.input")
  local fieldHeight = 22
  local fieldSpacing = 6
  local fieldLabelWidth = 120
  local fieldInputWidth = 150
  local col2x = welcome.x + welcome.width/2 - 20
  local fieldY = btnY
  local menu = {
    x = col2x,
    y = fieldY,
    width = btnW + 40,
    height = 180
  }
  for i, field in ipairs(input.modalFields.fields) do
    local y = fieldY + (i-1)*(fieldHeight+fieldSpacing)
    local label = (field == "mapName" and "Map Name:") or (field == "mapWidth" and "Map Width:") or (field == "mapHeight" and "Map Height:") or (field == "tileSize" and "Tile Size:")
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(label, col2x + 20, y)
    local inputX = col2x + 20 + fieldLabelWidth
    local selected = (input.modalFields.selectedField == i)
    love.graphics.setColor(selected and {0.5, 0.5, 0.8} or {0.3, 0.3, 0.3})
    love.graphics.rectangle("fill", inputX, y, fieldInputWidth, fieldHeight)
    -- Draw selection highlight if selectAll is true for this field
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
  -- Draw create button below all fields (compressed spacing)
  local buttonW = 100
  local createY = fieldY + (#input.modalFields.fields)*(fieldHeight+fieldSpacing) + 8
    -- Center create button between label and input columns
    local labelX = col2x + 20
    local inputX = labelX + fieldLabelWidth
    local createButtonX = labelX + ((inputX - labelX + fieldInputWidth) / 2) - (buttonW / 2)
  love.graphics.setColor(0.2, 0.7, 0.3)
  love.graphics.rectangle("fill", createButtonX, createY, buttonW, fieldHeight)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", createButtonX, createY, buttonW, fieldHeight)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Create", createButtonX + (buttonW-60)/2, createY + 3)
end

function welcome.mousepressed(x, y, button)
  if not welcome.visible or button ~= 1 then return false end
  local btnW, btnH, spacing = 140, 36, 12
  local col1x = welcome.x + 60
  local btnY = welcome.y + 110
  -- For modal fields, use compressed spacing
  local fieldHeight = 22
  local fieldSpacing = 6
  -- Import buttons
  local importLabels = { {"Import .txt", ".txt", import.txt}, {"Import .json", ".json", import.json}, {"Import .lua", ".lua", import.lua} }
  for i, btn in ipairs(importLabels) do
    local by = btnY + (i-1)*(btnH+spacing)
    if x >= col1x and x <= col1x+btnW and y >= by and y <= by+btnH then
      local filename = browse.openFile(btn[2], "Select File to Import")
      if filename then
        local file = io.open(filename, "r")
        if file then
          btn[3](file)
          io.close(file)
        end
        welcome.inWelcomeFlow = false
        welcome.visible = false
      else
        welcome.visible = true
      end
      return true
    end
  end
  local input = require("utils.input")
  local col2x = welcome.x + welcome.width/2 - 20
  local menu = {x=col2x, y=btnY}
  local function onCreate()
    local fields = input.modalFields
    -- Convert all fields to string before validation
    for _, k in ipairs(fields.fields) do fields[k] = tostring(fields[k] or "") end
    local mapValidator = require("menu.newMap.projectValidator")
    local success, errors = mapValidator.createMap(fields)
    if not success then
      local errorMsg = mapValidator.formatErrors(errors)
      love.window.showMessageBox("Invalid Input", errorMsg, "error")
      return true
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
    welcome.visible = false
    welcome.inWelcomeFlow = false
    if love.graphics then love.graphics.present() end
    return true
  end
  if input.modalMousepressed(x, y, menu, onCreate, fieldHeight, fieldSpacing) then return true end
  return false
end

return welcome