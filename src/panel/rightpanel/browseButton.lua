-- Browse button functionality
local browseButton = {}

browseButton.button = nil

function browseButton.draw()
  local rightBarX = window.width - 200  -- rightPanel.width
  local buttonX = rightBarX + 10
  local buttonY = menuBar.height + 40 + 10  -- topBar.height = 40
  local buttonWidth = 200 - 20  -- rightPanel.width - 20
  local buttonHeight = 30
  
  -- Button background
  love.graphics.setColor(0.3, 0.5, 0.7)
  love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
  
  -- Button border
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", buttonX, buttonY, buttonWidth, buttonHeight)
  
  -- Button text
  love.graphics.setColor(1, 1, 1)
  local buttonText = "Add Tileset.."
  local textWidth = love.graphics.getFont():getWidth(buttonText)
  love.graphics.print(buttonText, buttonX + (buttonWidth - textWidth) / 2, buttonY + 8)
  
  -- Store button for click detection
  browseButton.button = {x = buttonX, y = buttonY, width = buttonWidth, height = buttonHeight}
end

function browseButton.mousepressed(x, y)
  if browseButton.button and 
     x >= browseButton.button.x and x <= browseButton.button.x + browseButton.button.width and
     y >= browseButton.button.y and y <= browseButton.button.y + browseButton.button.height then
    browseButton.openTilesetBrowser()
    return true
  end
  return false
end

function browseButton.openTilesetBrowser()
  local browse = require("src.action.browse")
  local filePath = browse.openFile(".png", "Select Tileset Image")
  if filePath and filePath ~= "" and filePath:lower():match("%.png$") then
    local filename = filePath:match("([^\\]+)$") or filePath:match("([^/]+)$") or filePath
    if browseButton.copyTilesetToProject(filePath, filename) then
  if grid.addTileset(filename) then
        local tilesetScroll = require("panel.rightpanel.tilesetScroll")
        tilesetScroll.resetScroll()
        if tool and tool.camera then
          tool.camera.state = false
        end
      end
    end
  end
end

function browseButton.copyTilesetToProject(sourcePath, filename)
  local baseDirectory = love.filesystem.getSourceBaseDirectory()
  local targetDir = baseDirectory .. "/tileset/"
  local targetPath = targetDir .. filename
  
  -- Read source file
  local sourceFile = io.open(sourcePath, "rb")
  if not sourceFile then
    love.window.showMessageBox("Copy Error", "Could not read tileset: " .. sourcePath, "error")
    return false
  end
  
  local data = sourceFile:read("*all")
  sourceFile:close()
  
  -- Write to target directory
  local targetFile = io.open(targetPath, "wb")
  if not targetFile then
    love.window.showMessageBox("Copy Error", "Could not write tileset to: " .. targetPath, "error")
    return false
  end
  
  targetFile:write(data)
  targetFile:close()
  
  return true
end

return browseButton