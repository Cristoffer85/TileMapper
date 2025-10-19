-- New map dialog controller
local newMap = {}

-- Import sub-modules
local mapForm = require("src.menu.newMap.projectForm")
local mapValidator = require("src.menu.newMap.projectValidator")

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

  -- Set map name globally for display
  if grid then
    grid.mapName = newMap.data.mapName
  end

  -- Center camera on middle tile after map creation
  if grid and camera and grid.width and grid.height and grid.tileWidth and grid.tileHeight then
    local centerX = (grid.width * grid.tileWidth) / 2
    local centerY = (grid.height * grid.tileHeight) / 2
    camera:setPosition(centerX - window.width/2, centerY - window.height/2)
  end
  -- After first successful new map, set inWelcomeFlow to false
  local welcome = package.loaded["menu.welcome.welcome"]
  if welcome then
    welcome.inWelcomeFlow = false
  end
  require("menu.menuBar").hideModal()
end

return newMap