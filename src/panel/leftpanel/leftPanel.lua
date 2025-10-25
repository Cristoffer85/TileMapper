-- Left panel main coordinator

local leftPanel = {}
local button = require("src.assets.button")

leftPanel.width = 40
leftPanel.height = window.height

-- Tool state and logic (formerly tool.lua)
leftPanel.tool = {
  last = "pen",
  current = "pen",
  list = {"pen", "erase", "fill", "tilePicker"},
  shortcut = {"d", "e", "f", "lalt"},
  select = {},
}

local function isMapPosValid()
  return grid.map[mouse.l] ~= nil and grid.map[mouse.l][mouse.c] ~= nil
end

function leftPanel.tool.pen()
  if love.mouse.isDown(mouseTouch1) then
    if isMapPosValid() then
      if grid.map[mouse.l][mouse.c] ~= mouse.currentColor then
        grid.map[mouse.l][mouse.c] = mouse.currentColor
        grid.isDirty = true
      end
    end
  end
  mouse.fillColor = mouse.currentColor
end

function leftPanel.tool.erase()
  if love.mouse.isDown(mouseTouch1) then
    if isMapPosValid() then
      if grid.map[mouse.l][mouse.c] ~= 0 then
        grid.map[mouse.l][mouse.c] = 0
        grid.isDirty = true
      end
    end
  end
end

function leftPanel.tool.fill()
  local changed = false
  if love.mouse.isDown(mouseTouch1) then
    if isMapPosValid() and grid.map[mouse.l][mouse.c] ~= mouse.fillColor then
      local remplacer = grid.map[mouse.l][mouse.c]
      grid.map[mouse.l][mouse.c] = -1
      changed = true
      local stop = false
      while not stop do
        stop = true
        for l = 1, grid.height do
          for c = 1, grid.width do
            local value = grid.map[l][c]
            if value == -1 then
              if grid.map[l] ~= nil and grid.map[l][c-1] ~= nil then
                if grid.map[l][c-1] == remplacer then
                  grid.map[l][c-1] = -1
                  stop = false
                  changed = true
                end
              end
              if grid.map[l] ~= nil and grid.map[l][c+1] ~= nil then
                if grid.map[l][c+1] == remplacer then
                  grid.map[l][c+1] = -1
                  stop = false
                  changed = true
                end
              end
              if grid.map[l-1] ~= nil and grid.map[l-1][c] ~= nil then
                if grid.map[l-1][c] == remplacer then
                  grid.map[l-1][c] = -1
                  stop = false
                  changed = true
                end
              end
              if grid.map[l+1] ~= nil and grid.map[l+1][c] ~= nil then
                if grid.map[l+1][c] == remplacer then
                  grid.map[l+1][c] = -1
                  stop = false
                  changed = true
                end
              end
            end
          end
        end
      end
    end
    for l = 1, grid.height do
      for c = 1, grid.width do
        local value = grid.map[l][c]
        if value == -1 then
          grid.map[l][c] = mouse.fillColor
        end
      end
    end
    if changed then grid.isDirty = true end
  end
  if mouse.fillColor ~= 0 then
    mouse.currentColor = mouse.fillColor
  end
end

function leftPanel.tool.tilePicker()
  if love.mouse.isDown(mouseTouch1) then
    if isMapPosValid() then
      local value = grid.map[mouse.l][mouse.c]
      if value == 0 then
        leftPanel.tool.current = "erase"
      else
        mouse.currentColor = value
        mouse.fillColor = value
        leftPanel.tool.current = "pen"
      end
    end
  end
end

function leftPanel.tool.update()
  -- Tool selection by mouse
  if mouse.zone == "leftBar" then
    local spacing = 10
    local pX = 5
    local pY = 50 + menuBar.height + hud.topBar.height
    local height = 30
    for i = 1, #leftPanel.tool.list do
      local y = pY+(i-1)*spacing+(i-1)*height
      if mouse.collide(pX, y, height, height) then
        if love.mouse.isDown(mouseTouch1) then
          leftPanel.tool.current = leftPanel.tool.list[i]
        end
      end
    end
  end
  -- Tool selection by shortcut
  for i = 1, #leftPanel.tool.shortcut do
    if love.keyboard.isDown(leftPanel.tool.shortcut[i]) then
      if leftPanel.tool.current ~= leftPanel.tool.list[i] then
        leftPanel.tool.last = leftPanel.tool.current
      end
      leftPanel.tool.current = leftPanel.tool.list[i]
    end
  end
  -- Color picker (right mouse)
  if love.mouse.isDown(mouseTouch2) then
    local value = grid.map[mouse.l][mouse.c]
    if isMapPosValid() then
      if leftPanel.tool.current ~= "fill" then
        if value == 0 then
          leftPanel.tool.current = "erase"
        else
          mouse.currentColor = value
          leftPanel.tool.current = "pen"
        end
      else
        mouse.fillColor = value
      end
    end
  end
  -- Tool action
  if mouse.zone == "grid" then
    local t = leftPanel.tool.current
    if t and leftPanel.tool[t] then
      leftPanel.tool[t]()
    end
  end
end

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
    if leftPanel.tool.current == name[i] then
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