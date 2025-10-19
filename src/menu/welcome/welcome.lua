
local welcome = {}
local import = require("menu.import.importMain")
local browse = require("action.browse")

welcome.visible = true
welcome.width = 500
welcome.height = 260
welcome.x = 0
welcome.y = 0

function welcome.updatePosition()
  welcome.x = (window.width - welcome.width) / 2
  welcome.y = (window.height - welcome.height) / 2
end

function welcome.draw()
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
  -- Welcome text
  love.graphics.setColor(1, 1, 1)
  local title = "Welcome to TileMapper!"
  local subtitle = "Would you like to load previous project or start new?"
  local font = Font
  love.graphics.setFont(font)
  local titleW = font:getWidth(title)
  local subtitleW = font:getWidth(subtitle)
  love.graphics.print(title, welcome.x + (welcome.width-titleW)/2, welcome.y + 24)
  love.graphics.setColor(0.9, 0.9, 0.9)
  love.graphics.print(subtitle, welcome.x + (welcome.width-subtitleW)/2, welcome.y + 60)
  -- Draw buttons
  local btnW, btnH, spacing = 140, 36, 12
  local col1x = welcome.x + 60
  local col2x = welcome.x + welcome.width - btnW - 60
  local btnY = welcome.y + 110
  -- Import buttons (column)
  local importLabels = { {"Import .txt", ".txt", import.txt}, {"Import .json", ".json", import.json}, {"Import .lua", ".lua", import.lua} }
  for i, btn in ipairs(importLabels) do
    local by = btnY + (i-1)*(btnH+spacing)
    love.graphics.setColor(0.3, 0.5, 0.9)
    love.graphics.rectangle("fill", col1x, by, btnW, btnH, 8, 8)
    love.graphics.setColor(1, 1, 1)
    local labelW = font:getWidth(btn[1])
    love.graphics.print(btn[1], col1x + (btnW-labelW)/2, by + (btnH-font:getHeight())/2)
  end
  -- Start new map button (beside import column)
  love.graphics.setColor(0.2, 0.7, 0.3)
  love.graphics.rectangle("fill", col2x, btnY + btnH + spacing/2, btnW, btnH, 8, 8)
  love.graphics.setColor(1, 1, 1)
  local newLabel = "Start new map"
  local newLabelW = font:getWidth(newLabel)
  love.graphics.print(newLabel, col2x + (btnW-newLabelW)/2, btnY + btnH + spacing/2 + (btnH-font:getHeight())/2)
end

function welcome.mousepressed(x, y, button)
  if not welcome.visible or button ~= 1 then return false end
  local btnW, btnH, spacing = 140, 36, 12
  local col1x = welcome.x + 60
  local col2x = welcome.x + welcome.width - btnW - 60
  local btnY = welcome.y + 110
  -- Import buttons
  local importLabels = { {"Import .txt", ".txt", import.txt}, {"Import .json", ".json", import.json}, {"Import .lua", ".lua", import.lua} }
  for i, btn in ipairs(importLabels) do
    local by = btnY + (i-1)*(btnH+spacing)
    if x >= col1x and x <= col1x+btnW and y >= by and y <= by+btnH then
      -- Open file dialog and import
      local filename = browse.openFile(btn[2], "Select File to Import")
      if filename then
        local file = io.open(filename, "r")
        if file then
          btn[3](file)
          io.close(file)
        end
      end
      welcome.visible = false
      return true
    end
  end
  -- Start new map button
  local newY = btnY + btnH + spacing/2
  if x >= col2x and x <= col2x+btnW and y >= newY and y <= newY+btnH then
    welcome.visible = false
    local menuBar = package.loaded["menu.menuBar"]
    if menuBar and menuBar.showModal then
      menuBar.showModal("newMap")
    end
    return true
  end
  return false
end

return welcome
