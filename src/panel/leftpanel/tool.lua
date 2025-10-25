local tool = {}
tool.last = "pen"
tool.current = "pen"
tool.list     = {"pen", "erase", "fill", "tilePicker"}
tool.shortcut = {"d",   "e",     "f",    "lalt"}
tool.select = {}
tool.pen = {}
tool.erase = {}
tool.fill = {}
tool.tileSwapper = {}
tool.tilePicker = {}

local function isMapPosValid()
  return grid.map[mouse.l] ~= nil and grid.map[mouse.l][mouse.c] ~= nil
end

function tool.update()
  
  --(5, 50, 10, 30, tool.list)
  if mouse.zone == "leftBar" then 
    local spacing = 10
    local pX = 5
    local pY = 50 + menuBar.height + hud.topBar.height
    local height = 30
    local i
    for i = 1, #tool.list do
      local y = pY+(i-1)*spacing+(i-1)*height
      if mouse.collide(pX, y, height, height) then
        if love.mouse.isDown(mouseTouch1) then
          tool.current = tool.list[i]
        end
      end
    end
  end
  
  for i = 1, #tool.shortcut do
    if love.keyboard.isDown(tool.shortcut[i]) then
      if tool.current ~= tool.list[i] then
        tool.last = tool.current
      end
      tool.current = tool.list[i]
    end
  end

  if love.mouse.isDown(mouseTouch2) then -- Color picker
    local value = grid.map[mouse.l][mouse.c]
    if isMapPosValid() then
      if tool.current ~= "fill" then
        if value == 0 then
          tool.current = "erase"
        else
          mouse.currentColor = value
          tool.current = "pen"
        end
      else
        mouse.fillColor = value
      end
    end
  end

  if mouse.zone == "grid" then
    if tool.current and tool[tool.current] and tool[tool.current].f then
      tool[tool.current].f()
    end
  end
end

function tool.pen.f()
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

function tool.erase.f()
  if love.mouse.isDown(mouseTouch1) then
    if isMapPosValid() then
      if grid.map[mouse.l][mouse.c] ~= 0 then
        grid.map[mouse.l][mouse.c] = 0
        grid.isDirty = true
      end
    end
  end
end

function tool.fill.f()
  local changed = false
  if love.mouse.isDown(mouseTouch1) then
    if isMapPosValid() and grid.map[mouse.l][mouse.c] ~= mouse.fillColor then
      local remplacer = grid.map[mouse.l][mouse.c]
      grid.map[mouse.l][mouse.c] = -1
      changed = true
      local i = 1
      local stop = false
      while not stop do
        stop = true
        local l
        for l = 1, grid.height do
          local c
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
    local l
    for l = 1, grid.height do
      local c
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

function tool.tilePicker.f()
  if love.mouse.isDown(mouseTouch1) then
    if isMapPosValid() then
      local value = grid.map[mouse.l][mouse.c]
      if value == 0 then
        tool.current = "erase"
      else
        mouse.currentColor = value
        mouse.fillColor = value
        tool.current = "pen"
      end
    end
  end
end



return tool