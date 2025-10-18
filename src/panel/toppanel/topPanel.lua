-- Initialize width/height input fields for the toppanel
local function initDimensionInputs()
  local x = 80
  if not input["c"] or not input["l"] then
    input.add(input.list[1], "width", x, 10 + menuBar.height, input.list[2])
    input.add(input.list[2], "height", x + 150, 10 + menuBar.height, input.list[1])
  end
end

-- Top panel main coordinator
local topPanel = {}
local button = require("src.assets.button")

topPanel.width = window.width
topPanel.height = 40

function topPanel.draw()
  -- Ensure dimension input fields are initialized
  initDimensionInputs()
  love.graphics.setColor(85/255, 85/255, 85/255)
  -- Shift toppanel down by menuBar.height
  love.graphics.rectangle("fill", 0, menuBar.height, topPanel.width, topPanel.height)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, menuBar.height + topPanel.height-1, topPanel.width, 1)

  -- Draw width/height labels for input fields (aligned with input fields)
  if input and input["c"] and input["l"] then
    love.graphics.setFont(Font)
    local widthLabel = "width:"
    local heightLabel = "height:"
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(widthLabel, input["c"].x - Font:getWidth(widthLabel) - 4, input["c"].y)
    love.graphics.print(heightLabel, input["l"].x - Font:getWidth(heightLabel) - 4, input["l"].y)
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