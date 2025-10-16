-- Top panel main coordinator
local topPanel = {}
local button = require("button")

topPanel.width = window.width
topPanel.height = 40

function topPanel.draw()
  love.graphics.setColor(85/255, 85/255, 85/255)
  love.graphics.rectangle("fill", 0, menuBar.height, topPanel.width, topPanel.height)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, menuBar.height + topPanel.height-1, topPanel.width, 1)
end

function topPanel.drawButtonTopBar(pX, pY, spacing, width, name, title)
  love.graphics.setColor(1, 1, 1)
  if title ~= nil then
    love.graphics.setFont(Font)
    love.graphics.print(title, pX-Font:getWidth(title)-10, Font:getHeight(title)/2)
  end
  local i
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