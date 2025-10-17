-- New map dialog controller
local newMap = {}

-- Import sub-modules
local mapForm = require("menu.newProject.projectForm")
local mapValidator = require("menu.newProject.projectValidator")

newMap.data = {
  mapWidth = "128",
  mapHeight = "128",
  tileSize = "64",
  mapName = "NewMap",
  selectedField = 1
}

function newMap.draw(menu)
  mapForm.draw(menu, newMap.data)
end

function newMap.mousepressed(x, y, menu)
  return mapForm.mousepressed(x, y, menu, newMap.data, newMap)
end

function newMap.textinput(text)
  return mapForm.textinput(text, newMap.data)
end

function newMap.keypressed(key, menu)
  return mapForm.keypressed(key, menu, newMap.data)
end

function newMap.create(menu)
  local success, errors = mapValidator.createMap(newMap.data)
  if not success then
    local errorMsg = mapValidator.formatErrors(errors)
    love.window.showMessageBox("Invalid Input", errorMsg, "error")
    return
  end
  
  menu.hide()
  love.window.showMessageBox("Map Created", "New map '" .. newMap.data.mapName .. "' created successfully!", "info")
end

return newMap