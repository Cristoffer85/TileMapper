-- New project dialog controller
local newProject = {}

-- Import sub-modules
local projectForm = require("menu.newProject.projectForm")
local tilesetBrowser = require("menu.newProject.tilesetBrowser")
local projectValidator = require("menu.newProject.projectValidator")

-- State management
newProject.data = {
  mapWidth = "64",
  mapHeight = "64", 
  tileSize = "32",
  tilesetPath = "",
  projectName = "NewProject",
  selectedField = 1
}

newProject.showTilesetBrowser = false

function newProject.draw(menu)
  if newProject.showTilesetBrowser then
    tilesetBrowser.draw(menu, newProject.data)
  else
    projectForm.draw(menu, newProject.data)
  end
end

function newProject.mousepressed(x, y, menu)
  if newProject.showTilesetBrowser then
    return tilesetBrowser.mousepressed(x, y, menu, newProject.data, newProject)
  else
    return projectForm.mousepressed(x, y, menu, newProject.data, newProject)
  end
end

function newProject.textinput(text)
  if newProject.showTilesetBrowser then
    return tilesetBrowser.textinput(text)
  else
    return projectForm.textinput(text, newProject.data)
  end
end

function newProject.keypressed(key, menu)
  if newProject.showTilesetBrowser then
    return tilesetBrowser.keypressed(key, newProject)
  else
    return projectForm.keypressed(key, menu, newProject.data)
  end
end

function newProject.selectTileset()
  newProject.showTilesetBrowser = true
end

function newProject.create(menu)
  local success, errors = projectValidator.createProject(newProject.data)
  if not success then
    local errorMsg = projectValidator.formatErrors(errors)
    love.window.showMessageBox("Invalid Input", errorMsg, "error")
    return
  end
  
  menu.hide()
  love.window.showMessageBox("Project Created", "New project '" .. newProject.data.projectName .. "' created successfully!", "info")
end

return newProject