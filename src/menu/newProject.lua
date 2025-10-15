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

newProject.fields = {
  "projectName",
  "mapWidth", 
  "mapHeight",
  "tileWidth",
  "tileHeight"
}

function newProject.draw(menu)
  love.graphics.setColor(1, 1, 1)
  
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
  local buttons = newProject.buttons
  if not buttons then return false end
  
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
  local field = newProject.fields[newProject.data.selectedField]
  if field then
    newProject.data[field] = (newProject.data[field] or "") .. text
    return true
  end
  return false
end

function newProject.keypressed(key, menu)
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
  -- Simple text input for tileset filename
  local result = love.window.showMessageBox("Select Tileset", 
    "Enter the tileset filename (with extension).\nThe file should be in the 'tileset' folder.\n\nExample: TileSheet2.png", 
    "info", "okcancel")
    
  if result then
    newProject.data.tilesetPath = "TileSheet2.png" -- Default for now
    love.window.showMessageBox("Tileset Selected", 
      "Using tileset: " .. newProject.data.tilesetPath .. "\n\nTo use a different tileset, manually edit this value in the dialog.", 
      "info")
  end
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
    window.grid.height = window.height - hud.topBar.height
  end
  
  menu.hide()
  love.window.showMessageBox("Project Created", "New project '" .. newProject.data.projectName .. "' created successfully!", "info")
end

return newProject