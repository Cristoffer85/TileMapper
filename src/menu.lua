local menu = {}

menu.state = "none" -- none, main, newProject, loadProject
menu.visible = false

-- Menu dimensions and positioning
menu.width = 400
menu.height = 300
menu.x = 0
menu.y = 0

-- New project dialog data
menu.newProject = {
  mapWidth = "64",
  mapHeight = "64",
  tileWidth = "32", 
  tileHeight = "32",
  tilesetPath = "",
  projectName = "NewProject",
  selectedField = 1 -- For keyboard navigation
}

menu.fields = {
  "projectName",
  "mapWidth", 
  "mapHeight",
  "tileWidth",
  "tileHeight"
}

-- Recent projects
menu.recentProjects = {}
menu.maxRecentProjects = 5

function menu.show(menuType)
  menu.state = menuType or "main"
  menu.visible = true
  menu.updatePosition()
end

function menu.hide()
  menu.state = "none"
  menu.visible = false
end

function menu.updatePosition()
  menu.x = (window.width - menu.width) / 2
  menu.y = (window.height - menu.height) / 2
end

function menu.draw()
  if not menu.visible then return end
  
  -- Semi-transparent overlay
  love.graphics.setColor(0, 0, 0, 0.7)
  love.graphics.rectangle("fill", 0, 0, window.width, window.height)
  
  -- Menu background
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle("fill", menu.x, menu.y, menu.width, menu.height)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", menu.x, menu.y, menu.width, menu.height)
  
  if menu.state == "main" then
    menu.drawMainMenu()
  elseif menu.state == "newProject" then
    menu.drawNewProjectDialog()
  elseif menu.state == "loadProject" then
    menu.drawLoadProjectDialog()
  end
end

function menu.drawMainMenu()
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(love.graphics.getFont())
  
  local title = "TileMapper"
  local titleWidth = love.graphics.getFont():getWidth(title)
  love.graphics.print(title, menu.x + (menu.width - titleWidth) / 2, menu.y + 20)
  
  local buttons = {
    {text = "New Project", action = function() menu.show("newProject") end},
    {text = "Load Project", action = function() menu.loadProjectDialog() end},
    {text = "Save Project", action = function() menu.saveProject() end},
    {text = "Load Tileset", action = function() menu.loadTilesetDialog() end},
    {text = "Recent Projects", action = function() menu.show("loadProject") end},
    {text = "Cancel", action = function() menu.hide() end}
  }
  
  local buttonHeight = 30
  local buttonSpacing = 10
  local startY = menu.y + 60
  
  for i, button in ipairs(buttons) do
    local buttonY = startY + (i - 1) * (buttonHeight + buttonSpacing)
    local buttonX = menu.x + 50
    local buttonW = menu.width - 100
    
    -- Button background
    if menu.isMouseOver(buttonX, buttonY, buttonW, buttonHeight) then
      love.graphics.setColor(0.4, 0.4, 0.4)
    else
      love.graphics.setColor(0.3, 0.3, 0.3)
    end
    love.graphics.rectangle("fill", buttonX, buttonY, buttonW, buttonHeight)
    
    -- Button border
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", buttonX, buttonY, buttonW, buttonHeight)
    
    -- Button text
    love.graphics.setColor(1, 1, 1)
    local textWidth = love.graphics.getFont():getWidth(button.text)
    love.graphics.print(button.text, 
      buttonX + (buttonW - textWidth) / 2, 
      buttonY + (buttonHeight - love.graphics.getFont():getHeight()) / 2)
    
    button.x = buttonX
    button.y = buttonY
    button.w = buttonW
    button.h = buttonHeight
  end
  
  menu.mainMenuButtons = buttons
end

function menu.drawNewProjectDialog()
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
    local selected = (menu.newProject.selectedField == i)
    
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
    local text = menu.newProject[field.key] or ""
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
  local tilesetText = menu.newProject.tilesetPath ~= "" and menu.newProject.tilesetPath or "Click to select tileset..."
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
  
  menu.newProjectButtons = {
    tileset = {x = buttonX, y = tilesetY, w = buttonW, h = fieldHeight},
    create = {x = createButtonX, y = createButtonY, w = createButtonW, h = fieldHeight},
    cancel = {x = cancelButtonX, y = createButtonY, w = createButtonW, h = fieldHeight}
  }
end

function menu.drawLoadProjectDialog()
  love.graphics.setColor(1, 1, 1)
  
  local title = "Recent Projects"
  local titleWidth = love.graphics.getFont():getWidth(title)
  love.graphics.print(title, menu.x + (menu.width - titleWidth) / 2, menu.y + 20)
  
  local listY = menu.y + 60
  local itemHeight = 30
  
  if #menu.recentProjects == 0 then
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("No recent projects", menu.x + 20, listY)
  else
    for i, project in ipairs(menu.recentProjects) do
      local itemY = listY + (i - 1) * (itemHeight + 5)
      local itemX = menu.x + 20
      local itemW = menu.width - 40
      
      -- Item background
      if menu.isMouseOver(itemX, itemY, itemW, itemHeight) then
        love.graphics.setColor(0.4, 0.4, 0.4)
      else
        love.graphics.setColor(0.25, 0.25, 0.25)
      end
      love.graphics.rectangle("fill", itemX, itemY, itemW, itemHeight)
      
      love.graphics.setColor(0.6, 0.6, 0.6)
      love.graphics.rectangle("line", itemX, itemY, itemW, itemHeight)
      
      -- Project name
      love.graphics.setColor(1, 1, 1)
      love.graphics.print(project.name, itemX + 10, itemY + 5)
      love.graphics.setColor(0.8, 0.8, 0.8)
      love.graphics.print(project.path, itemX + 10, itemY + 18)
      
      project.x = itemX
      project.y = itemY
      project.w = itemW
      project.h = itemHeight
    end
  end
  
  -- Back button
  local backButtonY = menu.y + menu.height - 50
  local backButtonX = menu.x + (menu.width - 100) / 2
  
  if menu.isMouseOver(backButtonX, backButtonY, 100, 25) then
    love.graphics.setColor(0.4, 0.4, 0.4)
  else
    love.graphics.setColor(0.3, 0.3, 0.3)
  end
  love.graphics.rectangle("fill", backButtonX, backButtonY, 100, 25)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", backButtonX, backButtonY, 100, 25)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Back", backButtonX + 35, backButtonY + 5)
  
  menu.loadProjectButtons = {
    back = {x = backButtonX, y = backButtonY, w = 100, h = 25}
  }
end

function menu.isMouseOver(x, y, w, h)
  local mouseX, mouseY = love.mouse.getPosition()
  return mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h
end

function menu.mousepressed(x, y, button)
  if not menu.visible or button ~= 1 then return false end
  
  if menu.state == "main" then
    for _, btn in ipairs(menu.mainMenuButtons or {}) do
      if menu.isMouseOver(btn.x, btn.y, btn.w, btn.h) then
        btn.action()
        return true
      end
    end
  elseif menu.state == "newProject" then
    local buttons = menu.newProjectButtons
    if buttons then
      if menu.isMouseOver(buttons.tileset.x, buttons.tileset.y, buttons.tileset.w, buttons.tileset.h) then
        menu.selectTileset()
        return true
      elseif menu.isMouseOver(buttons.create.x, buttons.create.y, buttons.create.w, buttons.create.h) then
        menu.createProject()
        return true
      elseif menu.isMouseOver(buttons.cancel.x, buttons.cancel.y, buttons.cancel.w, buttons.cancel.h) then
        menu.show("main")
        return true
      end
    end
  elseif menu.state == "loadProject" then
    for _, project in ipairs(menu.recentProjects) do
      if menu.isMouseOver(project.x, project.y, project.w, project.h) then
        menu.loadProject(project.path)
        return true
      end
    end
    
    local buttons = menu.loadProjectButtons
    if buttons and menu.isMouseOver(buttons.back.x, buttons.back.y, buttons.back.w, buttons.back.h) then
      menu.show("main")
      return true
    end
  end
  
  return false
end

function menu.selectTileset()
  -- Simple text input for tileset filename
  local result = love.window.showMessageBox("Select Tileset", 
    "Enter the tileset filename (with extension).\nThe file should be in the 'tileset' folder.\n\nExample: TileSheet2.png", 
    "info", "okcancel")
    
  if result then
    -- For demonstration, we'll use a simple prompt system
    -- In a full implementation, this would be a proper text input dialog
    menu.newProject.tilesetPath = "TileSheet2.png" -- Default for now
    love.window.showMessageBox("Tileset Selected", 
      "Using tileset: " .. menu.newProject.tilesetPath .. "\n\nTo use a different tileset, manually edit this value in the dialog.", 
      "info")
  end
end

function menu.loadTilesetDialog()
  -- Similar to selectTileset, show instructions
  love.window.showMessageBox("Load Tileset", 
    "To load a different tileset:\n1. Place the image in the 'tileset' folder\n2. Use 'New Project' to specify the tileset\n\nCurrent tileset: " .. (grid.tileSetPath or "none"), 
    "info")
end

function menu.createProject()
  -- Validate inputs
  local mapW = tonumber(menu.newProject.mapWidth)
  local mapH = tonumber(menu.newProject.mapHeight)
  local tileW = tonumber(menu.newProject.tileWidth)
  local tileH = tonumber(menu.newProject.tileHeight)
  
  if not mapW or not mapH or not tileW or not tileH then
    love.window.showMessageBox("Invalid Input", "Please enter valid numbers for all size fields.", "error")
    return
  end
  
  if menu.newProject.tilesetPath == "" then
    love.window.showMessageBox("No Tileset", "Please select a tileset first.", "error")
    return
  end
  
  -- Validate tileset exists
  local tilesetFullPath = "tileset/" .. menu.newProject.tilesetPath
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
  
  -- Add to recent projects
  menu.addToRecentProjects(menu.newProject.projectName, "project/" .. menu.newProject.projectName)
  
  -- Update window dimensions
  if window and window.grid then
    window.grid.width = window.width - hud.leftBar.width - hud.rightBar.width
    window.grid.height = window.height - hud.topBar.height
  end
  
  menu.hide()
  love.window.showMessageBox("Project Created", "New project '" .. menu.newProject.projectName .. "' created successfully!", "info")
end

function menu.saveProject()
  if not export or not export.txt then
    love.window.showMessageBox("Export Error", "Export functionality not available.", "error")
    return
  end
  
  -- Save in all available formats
  for _, format in ipairs(export.list) do
    if export[format] then
      export[format]()
    end
  end
  
  menu.hide()
  love.window.showMessageBox("Project Saved", "Project saved successfully!", "info")
end

function menu.loadProjectDialog()
  -- Show file selection instructions
  love.window.showMessageBox("Load Project", 
    "To load a project:\n1. Make sure your map files are in the 'map' folder\n2. Update the 'editor.txt' file with the correct paths\n3. Restart the application\n\nThis will be improved in future versions with proper file dialogs.", 
    "info")
end

function menu.loadProject(projectPath)
  -- This would load a project file
  -- For now, just show a message
  love.window.showMessageBox("Load Project", "Loading: " .. projectPath .. "\n\nThis feature will be fully implemented in a future version.", "info")
  menu.hide()
end

function menu.addToRecentProjects(name, path)
  -- Remove if already exists
  for i = #menu.recentProjects, 1, -1 do
    if menu.recentProjects[i].path == path then
      table.remove(menu.recentProjects, i)
    end
  end
  
  -- Add to front
  table.insert(menu.recentProjects, 1, {name = name, path = path})
  
  -- Limit to max recent projects
  while #menu.recentProjects > menu.maxRecentProjects do
    table.remove(menu.recentProjects)
  end
end

function menu.textinput(text)
  if not menu.visible or menu.state ~= "newProject" then return false end
  
  local field = menu.fields[menu.newProject.selectedField]
  if field then
    menu.newProject[field] = (menu.newProject[field] or "") .. text
    return true
  end
  
  return false
end

function menu.keypressed(key)
  if not menu.visible then return false end
  
  if key == "escape" then
    if menu.state == "main" then
      menu.hide()
    else
      menu.show("main")
    end
    return true
  end
  
  if menu.state == "newProject" then
    if key == "tab" then
      menu.newProject.selectedField = menu.newProject.selectedField + 1
      if menu.newProject.selectedField > #menu.fields then
        menu.newProject.selectedField = 1
      end
      return true
    elseif key == "backspace" then
      local field = menu.fields[menu.newProject.selectedField]
      if field and menu.newProject[field] then
        menu.newProject[field] = string.sub(menu.newProject[field], 1, -2)
      end
      return true
    elseif key == "return" then
      menu.createProject()
      return true
    end
  end
  
  return false
end

return menu