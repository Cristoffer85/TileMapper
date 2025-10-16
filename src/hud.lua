local hud = {}
hud.button = require("button")
local rightPanel = require("panel.rightpanel.rightPanel")

hud.leftBar = {}
hud.leftBar.width = 40
hud.leftBar.height = window.height

hud.rightBar = {}
hud.rightBar.width = rightPanel.width
hud.rightBar.height = rightPanel.height

hud.topBar = {}
hud.topBar.width = window.width
hud.topBar.height = 40



function hud.leftBar.draw()
  love.graphics.setColor(85/255, 85/255, 85/255)
  love.graphics.rectangle("fill", 0, menuBar.height + hud.topBar.height, hud.leftBar.width, hud.leftBar.height - menuBar.height - hud.topBar.height)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", hud.leftBar.width-1, menuBar.height + hud.topBar.height, 1, hud.leftBar.height - menuBar.height - hud.topBar.height)
end


function hud.rightBar.draw()
  rightPanel.draw()
end


function hud.topBar.draw()
  love.graphics.setColor(85/255, 85/255, 85/255)
  love.graphics.rectangle("fill", 0, menuBar.height, hud.topBar.width, hud.topBar.height)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, menuBar.height + hud.topBar.height-1, hud.topBar.width, 1)
end



function hud.drawButtonLeftBar(pX, pY, spacing, height, name)
  love.graphics.setColor(1, 1, 1)
  local i
  for i = 1, #name do
    local y = pY+(i-1)*spacing+(i-1)*height
    if tool.current == name[i] then
      love.graphics.draw(hud.button.bg.on, pX, y)
    else
      if mouse.collide(pX, y, height, height) then
        if love.mouse.isDown(mouseTouch1) then
          love.graphics.draw(hud.button.bg.on, pX, y)
        else
          love.graphics.draw(hud.button.bg.over, pX, y)
        end
      else
        love.graphics.draw(hud.button.bg.off, pX, y)
      end
    end
    love.graphics.draw(hud.button.list[name[i]], pX, y)
  end
end


function hud.drawButtonTopBar(pX, pY, spacing, width, name, title)
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
        love.graphics.draw(hud.button.bg.on, x, pY)
      else
        love.graphics.draw(hud.button.bg.over, x, pY)
      end
    else
      love.graphics.draw(hud.button.bg.off, x, pY)
    end
    love.graphics.draw(hud.button.list[name[i]], x, pY)
  end
end


function hud.drawTile(pX, pY, spacing, pTileWidth)
  rightPanel.drawTile(pX, pY, spacing, pTileWidth)
end



function hud.scrollTileset(deltaY)
  return rightPanel.scrollTileset(deltaY)
end

function hud.updateDimensions()
  hud.leftBar.height = window.height
  hud.topBar.width = window.width
  rightPanel.updateDimensions()
  hud.rightBar.width = rightPanel.width
  hud.rightBar.height = rightPanel.height
end

function hud.mousepressed(x, y, button)
  return rightPanel.mousepressed(x, y, button)
end



return hud