local confirmation = {}

confirmation.visible = false
confirmation.message = ""
confirmation.onYes = nil
confirmation.onNo = nil
confirmation.width = 420
confirmation.height = 210
confirmation.x = 0
confirmation.y = 0

function confirmation.show(message, onYes, onNo)
  confirmation.message = message or "Are you sure?"
  confirmation.onYes = onYes
  confirmation.onNo = onNo
  confirmation.visible = true
  confirmation.x = (window.width - confirmation.width) / 2
  confirmation.y = (window.height - confirmation.height) / 2
end

function confirmation.hide()
  confirmation.visible = false
end

function confirmation.draw()
  if not confirmation.visible then return end
  -- Fade background
  love.graphics.setColor(0, 0, 0, 0.7)
  love.graphics.rectangle("fill", 0, 0, window.width, window.height)
  -- Modal background
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle("fill", confirmation.x, confirmation.y, confirmation.width, confirmation.height)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", confirmation.x, confirmation.y, confirmation.width, confirmation.height)
  -- Message (support multi-line, centered)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(Font)
  local lines = {}
  for line in string.gmatch(confirmation.message or "", "[^\n]+") do
    table.insert(lines, line)
  end
  local totalHeight = #lines * Font:getHeight() + (#lines-1)*10
  local startY = confirmation.y + 36
  for i, line in ipairs(lines) do
    local lineW = Font:getWidth(line)
    local y = startY + (i-1)*(Font:getHeight()+10)
    love.graphics.print(line, confirmation.x + (confirmation.width - lineW) / 2, y)
  end
  -- Yes/No buttons
  local btnW, btnH = 100, 36
  local spacing = 40
  local yesX = confirmation.x + confirmation.width/2 - btnW - spacing/2
  local noX = confirmation.x + confirmation.width/2 + spacing/2
  local btnY = confirmation.y + confirmation.height - btnH - 38
  -- Yes button
  love.graphics.setColor(0.2, 0.7, 0.3)
  love.graphics.rectangle("fill", yesX, btnY, btnW, btnH, 8, 8)
  love.graphics.setColor(1, 1, 1)
  local yesLabel = "Yes"
  love.graphics.print(yesLabel, yesX + (btnW-Font:getWidth(yesLabel))/2, btnY + (btnH-Font:getHeight())/2)
  -- No button
  love.graphics.setColor(0.7, 0.2, 0.2)
  love.graphics.rectangle("fill", noX, btnY, btnW, btnH, 8, 8)
  love.graphics.setColor(1, 1, 1)
  local noLabel = "Cancel"
  love.graphics.print(noLabel, noX + (btnW-Font:getWidth(noLabel))/2, btnY + (btnH-Font:getHeight())/2)
  -- Store button positions for click detection
  confirmation._yesBtn = {x = yesX, y = btnY, w = btnW, h = btnH}
  confirmation._noBtn = {x = noX, y = btnY, w = btnW, h = btnH}
end

function confirmation.mousepressed(x, y, button)
  if not confirmation.visible or button ~= 1 then return false end
  if confirmation._yesBtn and x >= confirmation._yesBtn.x and x <= confirmation._yesBtn.x + confirmation._yesBtn.w and y >= confirmation._yesBtn.y and y <= confirmation._yesBtn.y + confirmation._yesBtn.h then
    confirmation.visible = false
    if confirmation.onYes then confirmation.onYes() end
    return true
  elseif confirmation._noBtn and x >= confirmation._noBtn.x and x <= confirmation._noBtn.x + confirmation._noBtn.w and y >= confirmation._noBtn.y and y <= confirmation._noBtn.y + confirmation._noBtn.h then
    confirmation.visible = false
    if confirmation.onNo then confirmation.onNo() end
    return true
  end
  return false
end

return confirmation
