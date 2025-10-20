local input = {}

function input.modalTextinput(text)
  local ctx = input.modalFields
  local field = ctx.fields[ctx.selectedField]
  if field then
    local val = tostring(ctx[field] or "")
    if ctx.selectAll then
      ctx[field] = text
      ctx.selectAll = false
    else
      ctx[field] = val .. text
    end
    if love.graphics then love.graphics.present() end
    return true
  end
  return false
end

function input.modalKeypressed(key)
  local ctx = input.modalFields
  if key == "tab" then
    ctx.selectedField = ctx.selectedField + 1
    if ctx.selectedField > #ctx.fields then ctx.selectedField = 1 end
    if love.graphics then love.graphics.present() end
    return true
  elseif key == "backspace" then
    local field = ctx.fields[ctx.selectedField]
    if field and ctx[field] then
      if ctx.selectAll then
        ctx[field] = ""
        ctx.selectAll = false
      else
        local val = tostring(ctx[field] or "")
        ctx[field] = string.sub(val, 1, -2)
      end
      if love.graphics then love.graphics.present() end
    end
    return true
  elseif key == "return" then
    -- Trigger create action (handled in modal)
    if love.graphics then love.graphics.present() end
    return true
  end
  return false
end

-- Modal input context for new map fields (welcome modal)
input.modalFields = {
  fields = {"mapName", "mapWidth", "mapHeight", "tileSize"},
  selectedField = 1,
  mapName = "NewMap",
  mapWidth = "128",
  mapHeight = "128",
  tileSize = "64"
}

function input.modalMousepressed(x, y, menu, onCreate, fieldHeight, spacing)
  -- Field selection
  local fieldY = menu.y
  fieldHeight = fieldHeight or 25
  local labelWidth = 120
  local inputWidth = 150
  spacing = spacing or 12
  local now = love.timer.getTime()
  input.modalFields._lastClick = input.modalFields._lastClick or {time=0, field=0}
  for i = 1, #input.modalFields.fields do
    local fieldY_pos = fieldY + (i - 1) * (fieldHeight + spacing)
    local inputX = menu.x + 20 + labelWidth
    if x >= inputX and x <= inputX+inputWidth and y >= fieldY_pos and y <= fieldY_pos+fieldHeight then
      if input.modalFields.selectedField == i and input.modalFields._lastClick.field == i and (now - input.modalFields._lastClick.time) < 0.3 then
        input.modalFields.selectAll = true
      else
        input.modalFields.selectAll = false
      end
      input.modalFields.selectedField = i
      input.modalFields._lastClick = {time=now, field=i}
      return true
    end
  end
  -- Create button
  local buttonW = 100
  local extraSpacing = 8
  local createY = fieldY + #input.modalFields.fields * (fieldHeight + spacing) + extraSpacing
  local labelX = menu.x + 20
  local inputX = labelX + labelWidth
  local createButtonX = labelX + ((inputX - labelX + inputWidth) / 2) - (buttonW / 2)
  if x >= createButtonX and x <= createButtonX+buttonW and y >= createY and y <= createY+fieldHeight then
    if onCreate then onCreate(input.modalFields) end
    return true
  end
  input.modalFields.selectAll = false
  return false
end

input.list = {"c", "l"}

function input.add(name, toUpdate, x, y, nextTab)
  input[name] = {}
  input[name].toUpdate = toUpdate
  input[name].value = grid[toUpdate]
  input[name].nextTab = nextTab
  input[name].focus = false
  input[name].x = x
  input[name].y = y
  input[name].width = 60
  input[name].height = 20
end

function input.mousepressed(touch)
  local noFocus = true
  for i = 1, #input.list do
    local curInput = input[input.list[i]]
    if mouse.collide(curInput.x, curInput.y, curInput.width, curInput.height) then
      curInput.focus = true
      noFocus = false
    else
      curInput.focus = false
    end
  end
  if noFocus then
    for i = 1, #input.list do
      local curInput = input[input.list[i]]
      curInput.value = grid[curInput.toUpdate]
    end
  end
end

function input.textinput(t)
  for i = 1, #input.list do
    local curInput = input[input.list[i]]
    if curInput.focus == true then
      if string.len(curInput.value) < 3 and tonumber(t) ~= nil then
        curInput.value = curInput.value..t
      end
    end
  end
end

function input.keypressed(key)
  -- Handle fullscreen toggle (F11 or Alt+Enter)
  if key == "f11" or (key == "return" and love.keyboard.isDown("lalt")) then
    local isFullscreen = love.window.getFullscreen()
    love.window.setFullscreen(not isFullscreen)
    
    -- Update window dimensions
    window.width, window.height = love.graphics.getDimensions()
    hud.updateDimensions()
    window.grid.width = window.width-hud.leftBar.width-hud.rightBar.width
    window.grid.height = window.height-hud.topBar.height
    
    return -- Exit early to avoid processing other input
  end
  
  local toUpdate = false
  local nextOnce = false
  for i = 1, #input.list do
    local curInput = input[input.list[i]]
    if key == "backspace" and curInput.focus then
      curInput.value = string.gsub(curInput.value, ".$", "")
    end
    if key == "return" then
      if string.len(curInput.value) > 0 then
        if grid[curInput.toUpdate] ~= tonumber(curInput.value) then
          grid[curInput.toUpdate] = tonumber(curInput.value)
          toUpdate = true
        end
      else
        curInput.value = tostring(grid[curInput.toUpdate])
      end
      curInput.focus = false
    end
    if not nextOnce and key == "tab" and curInput.focus then
      nextOnce = true
      curInput.focus = false
      input[curInput.nextTab].focus = true
    end
  end
  if toUpdate then
    grid.mapLoad()
  end
end

function input.draw()
  local welcome = package.loaded["menu.welcome.welcome"]
  local menuBar = package.loaded["menu.menuBar"]
  local modalActive = (welcome and welcome.visible)
  if menuBar and menuBar.modal and menuBar.modal.visible then
    modalActive = true
  end
  if modalActive then return end
  for i = 1, #input.list do
    local curInput = input[input.list[i]]
    local x = curInput.x
    local y = curInput.y
    if curInput.focus then
      love.graphics.draw(hud.button.bgInput.on, x, y)
    else
      if mouse.collide(x, y, curInput.width, curInput.height) then
        if love.mouse.isDown(mouseTouch1) then
          love.graphics.draw(hud.button.bgInput.on, x, y)
        else
          love.graphics.draw(hud.button.bgInput.over, x, y)
        end
      else
        love.graphics.draw(hud.button.bgInput.off, x, y)
      end
    end
    love.graphics.setFont(Font)
    love.graphics.print(curInput.value, curInput.x + 16, curInput.y + 1)
  end
end

return input