-- Modal for setting tile size during import

local importTilesizeSetter = {}
local input = require("utils.input")

importTilesizeSetter.visible = false
importTilesizeSetter.onProceed = nil
importTilesizeSetter.onCancel = nil
importTilesizeSetter.context = nil -- "welcome" or "menu"

-- Modal field context for this modal
local modalFields = {
  fields = {"tileSize"},
  selectedField = 1,
  tileSize = "32",
  selectAll = false
}

function importTilesizeSetter.show(context, onProceed, onCancel)
  importTilesizeSetter.visible = true
  importTilesizeSetter.onProceed = onProceed
  importTilesizeSetter.onCancel = onCancel
  importTilesizeSetter.context = context
  modalFields.tileSize = "32"
  modalFields.selectedField = 1
  modalFields.selectAll = false
end

function importTilesizeSetter.hide()
  importTilesizeSetter.visible = false
end

function importTilesizeSetter.draw()
  if not importTilesizeSetter.visible then return end
  local w, h = love.graphics.getDimensions()
  local modalW, modalH = 340, 160
  local x = (w - modalW) / 2
  local y = (h - modalH) / 2
  love.graphics.setColor(0, 0, 0, 0.7)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(0.12, 0.12, 0.12, 0.97)
  love.graphics.rectangle("fill", x, y, modalW, modalH, 12, 12)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(Font)
  love.graphics.printf("Set Tile Size for Import", x, y + 18, modalW, "center")
  -- Draw field using input logic
  local label = "Tile size (pixels):"
  local labelW = Font:getWidth(label)
  local fieldHeight = 32
  local fieldSpacing = 0
  local fieldY = y + 60
  local fieldLabelWidth = 140
  local fieldInputWidth = 80
  local col2x = x + 30
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(label, col2x, fieldY)
  local inputX = col2x + fieldLabelWidth
  local selected = (modalFields.selectedField == 1)
  love.graphics.setColor(selected and {0.5, 0.5, 0.8} or {0.3, 0.3, 0.3})
  love.graphics.rectangle("fill", inputX, fieldY-2, fieldInputWidth, fieldHeight)
  if selected and modalFields.selectAll then
    love.graphics.setColor(0.2, 0.5, 0.9, 0.5)
    love.graphics.rectangle("fill", inputX+1, fieldY-1, fieldInputWidth-2, fieldHeight-2)
  end
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", inputX, fieldY-2, fieldInputWidth, fieldHeight)
  love.graphics.setColor(1, 1, 1)
  local value = tostring(modalFields.tileSize or "")
  if selected then
    local t = love.timer.getTime()
    if math.floor(t * 2) % 2 == 0 and not modalFields.selectAll then
      value = value .. "|"
    end
  end
  love.graphics.print(value, inputX + 8, fieldY + 3)
  -- Draw buttons
  local btnW, btnH = 90, 32
  local btnY = y + modalH - 50
  local proceedX = x + 30
  local cancelX = x + modalW - 30 - btnW
  love.graphics.setColor(0.2, 0.7, 0.3)
  love.graphics.rectangle("fill", proceedX, btnY, btnW, btnH, 6, 6)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", proceedX, btnY, btnW, btnH, 6, 6)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Proceed", proceedX + (btnW-60)/2, btnY + 6)
  love.graphics.setColor(0.7, 0.2, 0.2)
  love.graphics.rectangle("fill", cancelX, btnY, btnW, btnH, 6, 6)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", cancelX, btnY, btnW, btnH, 6, 6)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Cancel", cancelX + (btnW-50)/2, btnY + 6)
end



function importTilesizeSetter.textinput(text)
  if not importTilesizeSetter.visible then return false end
  -- Directly update modalFields.tileSize
  if modalFields.selectedField == 1 and #text == 1 and text:match("%d") and #modalFields.tileSize < 4 then
    if modalFields.selectAll then
      modalFields.tileSize = text
      modalFields.selectAll = false
    else
      modalFields.tileSize = modalFields.tileSize .. text
    end
  end
  return true
end



function importTilesizeSetter.keypressed(key)
  if not importTilesizeSetter.visible then return false end
  if key == "escape" then
    if importTilesizeSetter.onCancel then importTilesizeSetter.onCancel() end
    importTilesizeSetter.hide()
    return true
  end
  if key == "return" then
    if importTilesizeSetter.onProceed then
      local size = tonumber(modalFields.tileSize)
      if not size or size < 1 then size = 32 end
      importTilesizeSetter.onProceed(size)
    end
    importTilesizeSetter.hide()
    return true
  end
  if key == "backspace" then
    if modalFields.selectAll then
      modalFields.tileSize = ""
      modalFields.selectAll = false
    else
      modalFields.tileSize = modalFields.tileSize:sub(1, -2)
    end
    return true
  end
  return false
end

function importTilesizeSetter.mousepressed(x, y, button)
  if not importTilesizeSetter.visible or button ~= 1 then return false end
  local w, h = love.graphics.getDimensions()
  local modalW, modalH = 340, 160
  local bx = (w - modalW) / 2
  local by = (h - modalH) / 2
  local btnW, btnH = 90, 32
  local btnY = by + modalH - 50
  local proceedX = bx + 30
  local cancelX = bx + modalW - 30 - btnW
  -- Proceed
  if x >= proceedX and x <= proceedX+btnW and y >= btnY and y <= btnY+btnH then
    if importTilesizeSetter.onProceed then
      local size = tonumber(modalFields.tileSize)
      if not size or size < 1 then size = 32 end
      importTilesizeSetter.onProceed(size)
    end
    importTilesizeSetter.hide()
    return true
  end
  -- Cancel
  if x >= cancelX and x <= cancelX+btnW and y >= btnY and y <= btnY+btnH then
    if importTilesizeSetter.onCancel then importTilesizeSetter.onCancel() end
    importTilesizeSetter.hide()
    return true
  end
  -- Field selection
  local fieldLabelWidth = 140
  local fieldInputWidth = 80
  local col2x = bx + 30
  local fieldY = by + 60
  local inputX = col2x + fieldLabelWidth
  if x >= inputX and x <= inputX+fieldInputWidth and y >= fieldY-2 and y <= fieldY-2+32 then
    modalFields.selectedField = 1
    modalFields.selectAll = true
    return true
  end
  return false
end

return importTilesizeSetter
