-- New project dialog controller
local newProject = {}

-- Import sub-modules
local projectForm = require("menu.newProject.projectForm")
local projectValidator = require("menu.newProject.projectValidator")

-- State management
newProject.data = {
  mapWidth = "128",
  mapHeight = "128",
  tileSize = "64",
  projectName = "NewProject",
  selectedField = 1
}



function newProject.draw(menu)
  projectForm.draw(menu, newProject.data)
end

function newProject.mousepressed(x, y, menu)
  return projectForm.mousepressed(x, y, menu, newProject.data, newProject)
end

function newProject.textinput(text)
  return projectForm.textinput(text, newProject.data)
end

function newProject.keypressed(key, menu)
  return projectForm.keypressed(key, menu, newProject.data)
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