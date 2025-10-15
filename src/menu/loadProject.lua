-- Load project interface
local loadProject = {}

-- Recent projects
loadProject.recentProjects = {}
loadProject.maxRecentProjects = 5

function loadProject.draw(menu)
  love.graphics.setColor(1, 1, 1)
  
  local title = "Recent Projects"
  local titleWidth = love.graphics.getFont():getWidth(title)
  love.graphics.print(title, menu.x + (menu.width - titleWidth) / 2, menu.y + 20)
  
  local listY = menu.y + 60
  local itemHeight = 30
  
  if #loadProject.recentProjects == 0 then
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("No recent projects", menu.x + 20, listY)
  else
    for i, project in ipairs(loadProject.recentProjects) do
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
  
  loadProject.buttons = {
    back = {x = backButtonX, y = backButtonY, w = 100, h = 25}
  }
end

function loadProject.mousepressed(x, y, menu)
  for _, project in ipairs(loadProject.recentProjects) do
    if menu.isMouseOver(project.x, project.y, project.w, project.h) then
      loadProject.load(project.path)
      return true
    end
  end
  
  local buttons = loadProject.buttons
  if buttons and menu.isMouseOver(buttons.back.x, buttons.back.y, buttons.back.w, buttons.back.h) then
    menu.show("main")
    return true
  end
  
  return false
end

function loadProject.showDialog()
  -- Show file selection instructions
  love.window.showMessageBox("Load Project", 
    "To load a project:\n1. Make sure your map files are in the 'map' folder\n2. Update the 'editor.txt' file with the correct paths\n3. Restart the application\n\nThis will be improved in future versions with proper file dialogs.", 
    "info")
end

function loadProject.load(projectPath)
  -- This would load a project file
  -- For now, just show a message
  love.window.showMessageBox("Load Project", "Loading: " .. projectPath .. "\n\nThis feature will be fully implemented in a future version.", "info")
end

function loadProject.addToRecentProjects(name, path)
  -- Remove if already exists
  for i = #loadProject.recentProjects, 1, -1 do
    if loadProject.recentProjects[i].path == path then
      table.remove(loadProject.recentProjects, i)
    end
  end
  
  -- Add to front
  table.insert(loadProject.recentProjects, 1, {name = name, path = path})
  
  -- Limit to max recent projects
  while #loadProject.recentProjects > loadProject.maxRecentProjects do
    table.remove(loadProject.recentProjects)
  end
end

return loadProject