

-- Top panel main coordinator
local topPanel = {}
local button = require("src.assets.button")

topPanel.width = window.width
topPanel.height = 40

function topPanel.draw()
  -- Hide all top panel content if welcome modal is visible
  local welcome = package.loaded["menu.welcome.welcome"]
  -- Always draw toppanel background and border
  love.graphics.setColor(85/255, 85/255, 85/255)
  love.graphics.rectangle("fill", 0, menuBar.height, topPanel.width, topPanel.height)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, menuBar.height + topPanel.height-1, topPanel.width, 1)

  -- Only draw map info if no modal is visible
  local modalActive = (welcome and welcome.visible)
  local menuBar = package.loaded["menu.menuBar"]
  if menuBar and menuBar.modal and menuBar.modal.visible then
    modalActive = true
  end
  if not modalActive then
    love.graphics.setFont(Font)
    -- Draw width/height as static text (left-aligned)
    if grid and grid.width and grid.height then
      local widthLabel = "Width: " .. tostring(grid.width)
      local heightLabel = "Height: " .. tostring(grid.height)
      love.graphics.setColor(1, 1, 1)
      love.graphics.print(widthLabel, 80, 10 + menuBar.height)
      love.graphics.print(heightLabel, 230, 10 + menuBar.height)
    end
    -- Draw map name centered in top panel
    if grid and grid.mapName then
      local mapName = grid.mapName
      local textWidth = Font:getWidth(mapName)
      local textHeight = Font:getHeight()
      local x = (topPanel.width - textWidth) / 2
      local y = menuBar.height + (topPanel.height - textHeight) / 2
      love.graphics.setColor(1, 1, 1)
      love.graphics.print(mapName, x, y)
    end
  end
end

function topPanel.drawButtonTopBar(pX, pY, spacing, width, name, title)
  love.graphics.setColor(1, 1, 1)
  if title ~= nil then
    love.graphics.setFont(Font)
    -- Shift the title text down by menuBar.height
    love.graphics.print(title, pX-Font:getWidth(title)-10, menuBar.height + Font:getHeight(title)/2)
  end
  if not name then return end
  for i = 1, #name do
    local x = pX+(i-1)*spacing+(i-1)*width
    if mouse.collide(x, pY, width, width) then
      if love.mouse.isDown(mouseTouch1) then
        love.graphics.draw(button.bg.on, x, pY)
      else
        love.graphics.draw(button.bg.over, x, pY)
      end
    else
      love.graphics.draw(button.bg.off, x, pY)
    end
    love.graphics.draw(button.list[name[i]], x, pY)
  end
end

function topPanel.updateDimensions()
  topPanel.width = window.width
end

return topPanel