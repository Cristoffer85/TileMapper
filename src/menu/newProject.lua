-- New project creation interface
local newProject = {}

-- New project dialog data
newProject.data = {
  mapWidth = "64",
  mapHeight = "64",
  tileWidth = "32", 
  tileHeight = "32",
  tilesetPath = "",
  projectName = "NewProject",
  selectedField = 1 -- For keyboard navigation
}

-- Tileset browser state
newProject.showTilesetBrowser = false
newProject.manualInput = false
newProject.manualInputText = ""

newProject.fields = {
  "projectName",
  "mapWidth", 
  "mapHeight",
  "tileWidth",
  "tileHeight"
}

function newProject.draw(menu)
  love.graphics.setColor(1, 1, 1)
  
  -- Show tileset browser if active
  if newProject.showTilesetBrowser then
    newProject.drawTilesetBrowser(menu)
    return
  end
  
  local title = "Create New Project"
  local titleWidth = love.graphics.getFont():getWidth(title)
  love.graphics.print(title, menu.x + (menu.width - titleWidth) / 2, menu.y + 20)
  
  local fieldY = menu.y + 60
  local fieldHeight = 25
  local labelWidth = 120
  local inputWidth = 150
  
  local fields = {
    {label = "Project Name:", key = "projectName"},
    {label = "Map Width:", key = "mapWidth"},
    {label = "Map Height:", key = "mapHeight"},
    {label = "Tile Width:", key = "tileWidth"},
    {label = "Tile Height:", key = "tileHeight"}
  }
  
  for i, field in ipairs(fields) do
    local y = fieldY + (i - 1) * (fieldHeight + 5)
    
    -- Label
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(field.label, menu.x + 20, y)
    
    -- Input field
    local inputX = menu.x + 20 + labelWidth
    local selected = (newProject.data.selectedField == i)
    
    if selected then
      love.graphics.setColor(0.5, 0.5, 0.8)
    else
      love.graphics.setColor(0.3, 0.3, 0.3)
    end
    love.graphics.rectangle("fill", inputX, y, inputWidth, fieldHeight)
    
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("line", inputX, y, inputWidth, fieldHeight)
    
    -- Input text
    love.graphics.setColor(1, 1, 1)
    local text = newProject.data[field.key] or ""
    love.graphics.print(text, inputX + 5, y + 3)
  end
  
  -- Tileset path button
  local tilesetY = fieldY + #fields * (fieldHeight + 5) + 10
  local buttonX = menu.x + 20
  local buttonW = menu.width - 40
  
  love.graphics.setColor(0.3, 0.3, 0.3)
  love.graphics.rectangle("fill", buttonX, tilesetY, buttonW, fieldHeight)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", buttonX, tilesetY, buttonW, fieldHeight)
  
  love.graphics.setColor(1, 1, 1)
  local tilesetText = newProject.data.tilesetPath ~= "" and newProject.data.tilesetPath or "Click to select tileset..."
  love.graphics.print(tilesetText, buttonX + 5, tilesetY + 3)
  
  -- Action buttons
  local createButtonY = tilesetY + fieldHeight + 20
  local createButtonX = menu.x + 50
  local createButtonW = 100
  local cancelButtonX = menu.x + menu.width - 150
  
  -- Create button
  if menu.isMouseOver(createButtonX, createButtonY, createButtonW, fieldHeight) then
    love.graphics.setColor(0.4, 0.6, 0.4)
  else
    love.graphics.setColor(0.2, 0.4, 0.2)
  end
  love.graphics.rectangle("fill", createButtonX, createButtonY, createButtonW, fieldHeight)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", createButtonX, createButtonY, createButtonW, fieldHeight)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Create", createButtonX + 30, createButtonY + 3)
  
  -- Cancel button  
  if menu.isMouseOver(cancelButtonX, createButtonY, createButtonW, fieldHeight) then
    love.graphics.setColor(0.6, 0.4, 0.4)
  else
    love.graphics.setColor(0.4, 0.2, 0.2)
  end
  love.graphics.rectangle("fill", cancelButtonX, createButtonY, createButtonW, fieldHeight)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", cancelButtonX, createButtonY, createButtonW, fieldHeight)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Cancel", cancelButtonX + 30, createButtonY + 3)
  
  newProject.buttons = {
    tileset = {x = buttonX, y = tilesetY, w = buttonW, h = fieldHeight},
    create = {x = createButtonX, y = createButtonY, w = createButtonW, h = fieldHeight},
    cancel = {x = cancelButtonX, y = createButtonY, w = createButtonW, h = fieldHeight}
  }
end

function newProject.mousepressed(x, y, menu)
  -- Handle tileset browser first
  if newProject.showTilesetBrowser then
    return newProject.handleTilesetBrowserClick(x, y, menu)
  end
  
  local buttons = newProject.buttons
  if not buttons then return false end
  
  -- Check input field clicks first
  local fieldY = menu.y + 60
  local fieldHeight = 25
  local labelWidth = 120
  local inputWidth = 150
  
  for i = 1, #newProject.fields do
    local fieldY_pos = fieldY + (i - 1) * (fieldHeight + 5)
    local inputX = menu.x + 20 + labelWidth
    
    if menu.isMouseOver(inputX, fieldY_pos, inputWidth, fieldHeight) then
      newProject.data.selectedField = i
      return true
    end
  end
  
  -- Check button clicks
  if menu.isMouseOver(buttons.tileset.x, buttons.tileset.y, buttons.tileset.w, buttons.tileset.h) then
    newProject.selectTileset()
    return true
  elseif menu.isMouseOver(buttons.create.x, buttons.create.y, buttons.create.w, buttons.create.h) then
    newProject.create(menu)
    return true
  elseif menu.isMouseOver(buttons.cancel.x, buttons.cancel.y, buttons.cancel.w, buttons.cancel.h) then
    menu.show("main")
    return true
  end
  
  return false
end

function newProject.textinput(text)
  -- Handle manual tileset input when browser is open and manual input is active
  if newProject.showTilesetBrowser and newProject.manualInput then
    newProject.manualInputText = (newProject.manualInputText or "") .. text
    return true
  end
  
  -- Don't handle other text input when tileset browser is open
  if newProject.showTilesetBrowser then
    return false
  end
  
  local field = newProject.fields[newProject.data.selectedField]
  if field then
    newProject.data[field] = (newProject.data[field] or "") .. text
    return true
  end
  return false
end

function newProject.keypressed(key, menu)
  -- Handle tileset browser keys
  if newProject.showTilesetBrowser then
    if key == "escape" then
      newProject.showTilesetBrowser = false
      newProject.manualInput = false
      newProject.manualInputText = ""
      return true
    elseif key == "backspace" and newProject.manualInput then
      if newProject.manualInputText and #newProject.manualInputText > 0 then
        newProject.manualInputText = string.sub(newProject.manualInputText, 1, -2)
      end
      return true
    elseif key == "return" and newProject.manualInput then
      if newProject.manualInputText and newProject.manualInputText ~= "" then
        newProject.data.tilesetPath = newProject.manualInputText
        newProject.showTilesetBrowser = false
        newProject.manualInput = false
      end
      return true
    end
    return false
  end
  
  if key == "tab" then
    newProject.data.selectedField = newProject.data.selectedField + 1
    if newProject.data.selectedField > #newProject.fields then
      newProject.data.selectedField = 1
    end
    return true
  elseif key == "backspace" then
    local field = newProject.fields[newProject.data.selectedField]
    if field and newProject.data[field] then
      newProject.data[field] = string.sub(newProject.data[field], 1, -2)
    end
    return true
  elseif key == "return" then
    newProject.create(menu)
    return true
  end
  
  return false
end

function newProject.selectTileset()
  newProject.showTilesetBrowser = true
end

function newProject.getTilesetFiles()
  local files = {}
  local baseDirectory = love.filesystem.getSourceBaseDirectory()
  
  -- List of common tileset files to check
  local commonFiles = {
    "TileSheet2.png", "tileset.png", "tiles.png", "tilesheet.png",
    "tilemap.png", "terrain.png", "ground.png", "walls.png",
    "objects.png", "sprites.png", "atlas.png", "texture.png"
  }
  
  -- Check for existing files
  for _, file in ipairs(commonFiles) do
    local fullPath = baseDirectory .. "/tileset/" .. file
    local f = io.open(fullPath, "rb")
    if f then
      f:close()
      table.insert(files, file)
    end
  end
  
  -- Also try some variations with different cases
  local variations = {
    "TileSheet.png", "TileSheet1.png", "TileSheet3.png",
    "Tileset.png", "Tiles.png", "Terrain.png"
  }
  
  for _, file in ipairs(variations) do
    local fullPath = baseDirectory .. "/tileset/" .. file
    local f = io.open(fullPath, "rb")
    if f then
      f:close()
      -- Only add if not already in list
      local found = false
      for _, existing in ipairs(files) do
        if existing == file then
          found = true
          break
        end
      end
      if not found then
        table.insert(files, file)
      end
    end
  end
  
  return files
end

function newProject.drawTilesetBrowser(menu)
  -- Tileset browser overlay
  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.rectangle("fill", 0, 0, window.width, window.height)
  
  local browserWidth = 350
  local browserHeight = 450
  local browserX = (window.width - browserWidth) / 2
  local browserY = (window.height - browserHeight) / 2
  
  -- Browser background
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle("fill", browserX, browserY, browserWidth, browserHeight)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", browserX, browserY, browserWidth, browserHeight)
  
  -- Title
  love.graphics.setColor(1, 1, 1)
  local title = "Select Tileset"
  local titleWidth = love.graphics.getFont():getWidth(title)
  love.graphics.print(title, browserX + (browserWidth - titleWidth) / 2, browserY + 10)
  
  -- Instructions
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.print("Available tilesets in /tileset folder:", browserX + 10, browserY + 35)
  
  -- File list
  local files = newProject.getTilesetFiles()
  local listY = browserY + 60
  local itemHeight = 25
  local maxItems = 10
  
  if #files == 0 then
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("No tileset files found.", browserX + 20, listY)
    love.graphics.print("Place .png files in the /tileset folder", browserX + 20, listY + 20)
  else
    for i = 1, math.min(#files, maxItems) do
      local file = files[i]
      local itemY = listY + (i - 1) * (itemHeight + 2)
      local itemX = browserX + 10
      local itemW = browserWidth - 20
      
      -- Item background
      if menu.isMouseOver(itemX, itemY, itemW, itemHeight) then
        love.graphics.setColor(0.4, 0.4, 0.6)
      else
        love.graphics.setColor(0.3, 0.3, 0.3)
      end
      love.graphics.rectangle("fill", itemX, itemY, itemW, itemHeight)
      
      -- Selected item highlight
      if newProject.data.tilesetPath == file then
        love.graphics.setColor(0.5, 0.7, 0.5)
        love.graphics.rectangle("line", itemX, itemY, itemW, itemHeight)
      else
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.rectangle("line", itemX, itemY, itemW, itemHeight)
      end
      
      -- File name
      love.graphics.setColor(1, 1, 1)
      love.graphics.print(file, itemX + 5, itemY + 3)
      
      -- Store for click detection
      files[i] = {name = file, x = itemX, y = itemY, w = itemW, h = itemHeight}
    end
  end
  
  -- Manual input section
  local manualY = listY + (math.min(#files, maxItems) * (itemHeight + 2)) + 20
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.print("Or enter filename manually:", browserX + 10, manualY)
  
  -- Manual input field
  local inputY = manualY + 20
  local inputX = browserX + 10
  local inputW = browserWidth - 20
  local inputH = 25
  
  if newProject.manualInput then
    love.graphics.setColor(0.5, 0.5, 0.8)
  else
    love.graphics.setColor(0.3, 0.3, 0.3)
  end
  love.graphics.rectangle("fill", inputX, inputY, inputW, inputH)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", inputX, inputY, inputW, inputH)
  
  love.graphics.setColor(1, 1, 1)
  local inputText = newProject.manualInputText or ""
  if inputText == "" and not newProject.manualInput then
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.print("e.g., mytileset.png", inputX + 5, inputY + 3)
  else
    love.graphics.print(inputText, inputX + 5, inputY + 3)
  end
  
  -- Buttons
  local buttonY = browserY + browserHeight - 50
  local selectButtonX = browserX + 30
  local cancelButtonX = browserX + browserWidth - 110
  local manualButtonX = browserX + (browserWidth - 80) / 2
  local buttonW = 80
  local buttonH = 25
  
  -- Select button
  if newProject.data.tilesetPath ~= "" then
    love.graphics.setColor(0.2, 0.6, 0.2)
  else
    love.graphics.setColor(0.3, 0.3, 0.3)
  end
  love.graphics.rectangle("fill", selectButtonX, buttonY, buttonW, buttonH)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", selectButtonX, buttonY, buttonW, buttonH)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Select", selectButtonX + 25, buttonY + 3)
  
  -- Use Manual button
  local manualText = newProject.manualInputText and newProject.manualInputText ~= "" and "Use Manual" or "Manual"
  if newProject.manualInputText and newProject.manualInputText ~= "" then
    love.graphics.setColor(0.6, 0.6, 0.2)
  else
    love.graphics.setColor(0.4, 0.4, 0.4)
  end
  love.graphics.rectangle("fill", manualButtonX, buttonY, buttonW, buttonH)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", manualButtonX, buttonY, buttonW, buttonH)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(manualText, manualButtonX + (buttonW - love.graphics.getFont():getWidth(manualText)) / 2, buttonY + 3)
  
  -- Cancel button
  love.graphics.setColor(0.6, 0.2, 0.2)
  love.graphics.rectangle("fill", cancelButtonX, buttonY, buttonW, buttonH)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", cancelButtonX, buttonY, buttonW, buttonH)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Cancel", cancelButtonX + 20, buttonY + 3)
  
  -- Store button positions
  newProject.tilesetBrowserButtons = {
    files = files,
    select = {x = selectButtonX, y = buttonY, w = buttonW, h = buttonH},
    manual = {x = manualButtonX, y = buttonY, w = buttonW, h = buttonH},
    cancel = {x = cancelButtonX, y = buttonY, w = buttonW, h = buttonH},
    manualInput = {x = inputX, y = inputY, w = inputW, h = inputH}
  }
end

function newProject.handleTilesetBrowserClick(x, y, menu)
  local buttons = newProject.tilesetBrowserButtons
  if not buttons then return false end
  
  -- Check manual input field click
  if buttons.manualInput and menu.isMouseOver(buttons.manualInput.x, buttons.manualInput.y, buttons.manualInput.w, buttons.manualInput.h) then
    newProject.manualInput = true
    return true
  else
    newProject.manualInput = false
  end
  
  -- Check file clicks
  for _, file in ipairs(buttons.files) do
    if file.x and menu.isMouseOver(file.x, file.y, file.w, file.h) then
      newProject.data.tilesetPath = file.name
      newProject.manualInputText = "" -- Clear manual input when selecting from list
      return true
    end
  end
  
  -- Check button clicks
  if menu.isMouseOver(buttons.select.x, buttons.select.y, buttons.select.w, buttons.select.h) then
    if newProject.data.tilesetPath ~= "" then
      newProject.showTilesetBrowser = false
      newProject.manualInput = false
      newProject.manualInputText = ""
    end
    return true
  elseif buttons.manual and menu.isMouseOver(buttons.manual.x, buttons.manual.y, buttons.manual.w, buttons.manual.h) then
    if newProject.manualInputText and newProject.manualInputText ~= "" then
      newProject.data.tilesetPath = newProject.manualInputText
      newProject.showTilesetBrowser = false
      newProject.manualInput = false
    end
    return true
  elseif menu.isMouseOver(buttons.cancel.x, buttons.cancel.y, buttons.cancel.w, buttons.cancel.h) then
    newProject.showTilesetBrowser = false
    newProject.manualInput = false
    newProject.manualInputText = ""
    return true
  end
  
  return false
end

function newProject.create(menu)
  -- Validate inputs
  local mapW = tonumber(newProject.data.mapWidth)
  local mapH = tonumber(newProject.data.mapHeight)
  local tileW = tonumber(newProject.data.tileWidth)
  local tileH = tonumber(newProject.data.tileHeight)
  
  if not mapW or not mapH or not tileW or not tileH then
    love.window.showMessageBox("Invalid Input", "Please enter valid numbers for all size fields.", "error")
    return
  end
  
  if newProject.data.tilesetPath == "" then
    love.window.showMessageBox("No Tileset", "Please select a tileset first.", "error")
    return
  end
  
  -- Validate tileset exists
  local tilesetFullPath = "tileset/" .. newProject.data.tilesetPath
  local baseDirectory = love.filesystem.getSourceBaseDirectory()
  local file = io.open(baseDirectory .. "/" .. tilesetFullPath, "rb")
  if not file then
    love.window.showMessageBox("Tileset Not Found", 
      "Could not find tileset: " .. tilesetFullPath .. "\n\nPlease make sure the file exists in the tileset folder.", 
      "error")
    return
  end
  file:close()
  
  -- Apply the new project settings
  grid.width = mapW
  grid.height = mapH
  grid.tileWidth = tileW
  grid.tileHeight = tileH
  grid.tileSetPath = tilesetFullPath
  
  -- Clear the current map
  grid.map = {}
  for x = 1, grid.width do
    grid.map[x] = {}
    for y = 1, grid.height do
      grid.map[x][y] = 0
    end
  end
  
  -- Reload the tileset and grid
  grid.loadExternalImage()
  grid.load()
  
  -- Update window dimensions
  if window and window.grid then
    window.grid.width = window.width - hud.leftBar.width - hud.rightBar.width
    window.grid.height = window.height - hud.topBar.height - menuBar.height
  end
  
  menu.hide()
  love.window.showMessageBox("Project Created", "New project '" .. newProject.data.projectName .. "' created successfully!", "info")
end

return newProject