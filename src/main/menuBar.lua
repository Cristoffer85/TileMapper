-- Menu bar for classic desktop-style menus
local menuBar = {}

menuBar.height = 25
menuBar.items = {
  {
    label = "File",
    items = {
  {label = "New Map", action = function() menu.show("newMap") end},
  {label = "Open Map", action = function() menu.loadMap.showDialog() end},
  {label = "Save Map", action = function() menu.saveMap.save() end},
  {label = "Save As...", action = function() menu.saveMap.saveAs() end},
      {label = "separator"},
      {label = "Load Tileset", action = function() menuBar.loadTilesetDialog() end},
      {label = "separator"},
      {label = "Export Map", action = function() menuBar.showExportOptions() end},
      {label = "Import Map", action = function() menuBar.showImportOptions() end}
    }
  },
  {
    label = "Edit",
    items = {
      {label = "Clear Map", action = function() menuBar.clearMap() end},
      {label = "Fill Map", action = function() menuBar.fillMap() end},
      {label = "Resize Map", action = function() menuBar.resizeMap() end}
    }
  },
  {
    label = "View",
    items = {
      {label = "Toggle Fullscreen", action = function() menuBar.toggleFullscreen() end},
      {label = "Reset Camera", action = function() action.resetPos.f() end},
      {label = "Zoom In", action = function() action.zoom.wheelmoved(1) end},
      {label = "Zoom Out", action = function() action.zoom.wheelmoved(-1) end}
    }
  },
  {
    label = "Tools",
    items = {
      {label = "Pen Tool", action = function() tool.current = "pen" end},
      {label = "Fill Tool", action = function() tool.current = "fill" end},
      {label = "Eraser Tool", action = function() tool.current = "eraser" end}
    }
  },
  {
    label = "Help",
    items = {
      {label = "About", action = function() menuBar.showAbout() end},
      {label = "Controls", action = function() menuBar.showControls() end}
    }
  }
}

menuBar.activeDropdown = nil
menuBar.dropdownX = 0
menuBar.dropdownY = 0
menuBar.dropdownWidth = 150

function menuBar.draw()
  -- Menu bar background
  love.graphics.setColor(0.9, 0.9, 0.9)
  love.graphics.rectangle("fill", 0, 0, window.width, menuBar.height)
  love.graphics.setColor(0.7, 0.7, 0.7)
  love.graphics.rectangle("line", 0, 0, window.width, menuBar.height)
  
  -- Menu items
  local x = 5
  love.graphics.setColor(0, 0, 0)
  
  for i, item in ipairs(menuBar.items) do
    local itemWidth = love.graphics.getFont():getWidth(item.label) + 16
    
    -- Highlight if hovered or active dropdown
    if menuBar.isMouseOverMenuItem(x, 0, itemWidth, menuBar.height) or menuBar.activeDropdown == i then
      love.graphics.setColor(0.8, 0.8, 1.0)
      love.graphics.rectangle("fill", x, 0, itemWidth, menuBar.height)
      love.graphics.setColor(0, 0, 0)
    end
    
    -- Draw text
    love.graphics.print(item.label, x + 8, 5)
    
    -- Store position for click detection
    item.x = x
    item.y = 0
    item.w = itemWidth
    item.h = menuBar.height
    
    x = x + itemWidth
  end
  
  -- Draw active dropdown
  if menuBar.activeDropdown then
    menuBar.drawDropdown(menuBar.activeDropdown)
  end
end

function menuBar.drawDropdown(menuIndex)
  local menuItem = menuBar.items[menuIndex]
  if not menuItem then return end
  
  local itemHeight = 25
  local dropdownHeight = #menuItem.items * itemHeight
  local separatorCount = 0
  
  -- Count separators to adjust height
  for _, item in ipairs(menuItem.items) do
    if item.label == "separator" then
      separatorCount = separatorCount + 1
    end
  end
  
  dropdownHeight = dropdownHeight + (separatorCount * 5) - (separatorCount * itemHeight)
  
  menuBar.dropdownX = menuItem.x
  menuBar.dropdownY = menuBar.height
  menuBar.dropdownWidth = 150
  menuBar.dropdownHeight = dropdownHeight
  
  -- Dropdown background
  love.graphics.setColor(0.95, 0.95, 0.95)
  love.graphics.rectangle("fill", menuBar.dropdownX, menuBar.dropdownY, menuBar.dropdownWidth, dropdownHeight)
  love.graphics.setColor(0.6, 0.6, 0.6)
  love.graphics.rectangle("line", menuBar.dropdownX, menuBar.dropdownY, menuBar.dropdownWidth, dropdownHeight)
  
  -- Dropdown items
  local y = menuBar.dropdownY
  love.graphics.setColor(0, 0, 0)
  
  for i, item in ipairs(menuItem.items) do
    if item.label == "separator" then
      -- Draw separator
      love.graphics.setColor(0.7, 0.7, 0.7)
      love.graphics.line(menuBar.dropdownX + 5, y + 2, menuBar.dropdownX + menuBar.dropdownWidth - 5, y + 2)
      love.graphics.setColor(0, 0, 0)
      y = y + 5
    else
      -- Highlight if hovered
      if menuBar.isMouseOverMenuItem(menuBar.dropdownX, y, menuBar.dropdownWidth, itemHeight) then
        love.graphics.setColor(0.8, 0.8, 1.0)
        love.graphics.rectangle("fill", menuBar.dropdownX, y, menuBar.dropdownWidth, itemHeight)
        love.graphics.setColor(0, 0, 0)
      end
      
      -- Draw text
      love.graphics.print(item.label, menuBar.dropdownX + 10, y + 5)
      
      -- Store position for click detection
      item.x = menuBar.dropdownX
      item.y = y
      item.w = menuBar.dropdownWidth
      item.h = itemHeight
      
      y = y + itemHeight
    end
  end
end

function menuBar.isMouseOverMenuItem(x, y, w, h)
  local mouseX, mouseY = love.mouse.getPosition()
  return mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h
end

function menuBar.mousepressed(x, y, button)
  if button ~= 1 then return false end
  
  -- Check if clicking on menu bar
  if y <= menuBar.height then
    for i, item in ipairs(menuBar.items) do
      if menuBar.isMouseOverMenuItem(item.x, item.y, item.w, item.h) then
        if menuBar.activeDropdown == i then
          menuBar.activeDropdown = nil -- Close if already open
        else
          menuBar.activeDropdown = i -- Open dropdown
        end
        return true
      end
    end
    -- Clicked on menu bar but not on any item
    menuBar.activeDropdown = nil
    return true
  end
  
  -- Check if clicking on dropdown
  if menuBar.activeDropdown then
    local menuItem = menuBar.items[menuBar.activeDropdown]
    if menuBar.isMouseOverMenuItem(menuBar.dropdownX, menuBar.dropdownY, menuBar.dropdownWidth, menuBar.dropdownHeight) then
      for _, item in ipairs(menuItem.items) do
        if item.label ~= "separator" and item.x and item.y and 
           menuBar.isMouseOverMenuItem(item.x, item.y, item.w, item.h) then
          if item.action then
            item.action()
          end
          menuBar.activeDropdown = nil
          return true
        end
      end
    else
      -- Clicked outside dropdown, close it
      menuBar.activeDropdown = nil
      return false -- Allow the click to pass through
    end
  end
  
  return false
end

function menuBar.update()
  -- Close dropdown if mouse moves away from menu area
  local mouseX, mouseY = love.mouse.getPosition()
  if menuBar.activeDropdown and mouseY > menuBar.height + (menuBar.dropdownHeight or 0) + 10 then
    -- Add some tolerance before auto-closing
  end
end

-- Menu action functions
function menuBar.loadTilesetDialog()
  love.window.showMessageBox("Load Tileset", 
  "To load a different tileset:\n1. Place the image in the 'tileset' folder\n2. Use File > New Map to specify the tileset\n\nCurrent tileset: " .. (grid.tileSetPath or "none"), 
    "info")
end

function menuBar.showExportOptions()
  love.window.showMessageBox("Export Options", 
    "Current export formats:\n- TXT format\n- JSON format\n- Lua format\n\nUse the export buttons in the top bar to export your map.", 
    "info")
end

function menuBar.showImportOptions()
  love.window.showMessageBox("Import Options", 
    "Current import formats:\n- TXT format\n- JSON format\n- Lua format\n\nUse the import buttons in the top bar to import a map.", 
    "info")
end

function menuBar.clearMap()
  local result = love.window.showMessageBox("Clear Map", 
    "Are you sure you want to clear the entire map? This cannot be undone.", 
    "warning", "yesno")
    
  if result then
    for x = 1, grid.width do
      for y = 1, grid.height do
        grid.map[x][y] = 0
      end
    end
    love.window.showMessageBox("Map Cleared", "The map has been cleared.", "info")
  end
end

function menuBar.fillMap()
  if mouse.fillColor and mouse.fillColor > 0 then
    local result = love.window.showMessageBox("Fill Map", 
      "Fill the entire map with the selected tile? This cannot be undone.", 
      "warning", "yesno")
      
    if result then
      for x = 1, grid.width do
        for y = 1, grid.height do
          grid.map[x][y] = mouse.fillColor
        end
      end
      love.window.showMessageBox("Map Filled", "The map has been filled with the selected tile.", "info")
    end
  else
    love.window.showMessageBox("No Tile Selected", "Please select a tile first.", "info")
  end
end

function menuBar.resizeMap()
  love.window.showMessageBox("Resize Map", 
  "To resize the map, use File > New Map and set new dimensions.\n\nNote: This will create a new map and clear existing content.", 
    "info")
end

function menuBar.toggleFullscreen()
  local isFullscreen = love.window.getFullscreen()
  love.window.setFullscreen(not isFullscreen)
  
  -- Update window dimensions
  window.width, window.height = love.graphics.getDimensions()
  hud.updateDimensions()
  window.grid.width = window.width-hud.leftBar.width-hud.rightBar.width
  window.grid.height = window.height-hud.topBar.height-menuBar.height
end

function menuBar.showAbout()
  love.window.showMessageBox("About TileMapper", 
    "TileMapper v1.0\n\nA tile-based map editor built with Love2D\n\nFeatures:\n- Visual tile placement\n- Multiple export formats\n- Fullscreen support\n- Tileset scrolling", 
    "info")
end

function menuBar.showControls()
  love.window.showMessageBox("Controls", 
    "Mouse Controls:\n- Left Click: Place tile\n- Right Click: Erase\n- Mouse Wheel: Zoom (map area) or Scroll (tileset area)\n\nKeyboard:\n- F11 or Alt+Enter: Toggle fullscreen\n- WASD: Move camera\n- Ctrl +/-: Zoom in/out\n\nMenu: Use the menu bar above", 
    "info")
end

return menuBar