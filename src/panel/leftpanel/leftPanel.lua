-- Left panel main coordinator
local leftPanel = {}
local button = require("ui.button")

leftPanel.width = 40
leftPanel.height = window.height

function leftPanel.draw()
  love.graphics.setColor(85/255, 85/255, 85/255)
  -- Shift leftpanel down by menuBar.height
  love.graphics.rectangle("fill", 0, menuBar.height + 40, leftPanel.width, leftPanel.height - menuBar.height - 40)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", leftPanel.width-1, menuBar.height + 40, 1, leftPanel.height - menuBar.height - 40)
end

function leftPanel.drawButtonLeftBar(pX, pY, spacing, height, name)
  love.graphics.setColor(1, 1, 1)
  local i
  for i = 1, #name do
    local y = pY+(i-1)*spacing+(i-1)*height
    if tool.current == name[i] then
      love.graphics.draw(button.bg.on, pX, y)
    else
      if mouse.collide(pX, y, height, height) then
        if love.mouse.isDown(mouseTouch1) then
          love.graphics.draw(button.bg.on, pX, y)
        else
          love.graphics.draw(button.bg.over, pX, y)
        end
      else
        love.graphics.draw(button.bg.off, pX, y)
      end
    end
    love.graphics.draw(button.list[name[i]], pX, y)
  end
end

function leftPanel.updateDimensions()
  leftPanel.height = window.height
end

return leftPanel