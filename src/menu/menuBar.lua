local menuBar = {}

function menuBar.showModal(state)
  menuBar.modal.state = state
  menuBar.modal.visible = true
  menuBar.updateModalPosition()
end

function menuBar.hideModal()
  menuBar.modal.state = nil
  menuBar.modal.visible = false
end
local import = require("menu.import.importMain")
local export = require("menu.export.exportMain")
menuBar.dropdownOpenTime = 0
menuBar.height = 25
local browse = require("utils.browse")

-- Modal dialog state for New Map
local newMap = require("menu.newMap.newMapMain")
menuBar.mapSession = { hasCreatedMap = false }

menuBar.modal = {
  visible = false,
  state = nil,
  width = 400,
  height = 300,
  x = 0,
  y = 0
}

function menuBar.updateModalPosition()
  menuBar.modal.x = (window.width - menuBar.modal.width) / 2
  menuBar.modal.y = (window.height - menuBar.modal.height) / 2
end

function menuBar.drawModal()
  if not menuBar.modal.visible then return end
  -- Semi-transparent overlay
  love.graphics.setColor(0, 0, 0, 0.7)
  love.graphics.rectangle("fill", 0, 0, window.width, window.height)
  -- Modal background
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle("fill", menuBar.modal.x, menuBar.modal.y, menuBar.modal.width, menuBar.modal.height)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", menuBar.modal.x, menuBar.modal.y, menuBar.modal.width, menuBar.modal.height)
  -- Delegate drawing to newMap dialog
  if menuBar.modal.state == "newMap" then
    newMap.draw(menuBar.modal)
  end
end

function menuBar.modalMousepressed(x, y, button)
  if not menuBar.modal.visible or button ~= 1 then return false end
  if menuBar.modal.state == "newMap" then
    return newMap.mousepressed(x, y, menuBar.modal)
  end
  return false
end

function menuBar.modalTextinput(text)
  if not menuBar.modal.visible then return false end
  if menuBar.modal.state == "newMap" then
    return newMap.textinput(text)
  end
  return false
end

function menuBar.modalKeypressed(key)
  if not menuBar.modal.visible then return false end
  if key == "escape" then
    menuBar.hideModal()
    return true
  end
  if menuBar.modal.state == "newMap" then
    return newMap.keypressed(key, menuBar.modal)
  end
  return false
end

-- Utility: import/export file dialog for menu actions
local function importFileDialog(extension, importFunc)
  local filename = browse.openFile(extension, "Select File to Import")
  if filename then
    local file = io.open(filename, "r")
    if file then
      importFunc(file)
      io.close(file)
    else
      love.window.showMessageBox("Import Error", "Could not open file: "..filename, "error")
    end
  end
end

local function exportFileDialog(extension, exportFunc)
    local defaultName = (grid and grid.mapName and #grid.mapName > 0) and grid.mapName or "map"
    local filename = browse.saveFile(extension, "Select Export Location", defaultName .. extension)
  if filename then
    local file = io.open(filename, "w+")
    if file then
      exportFunc(file)
      io.close(file)
    else
      love.window.showMessageBox("Export Error", "Could not open file: "..filename, "error")
    end
  end
end

menuBar.items = {
  {
    label = "File",
    items = {
      {label = "New Map", action = function()
        local welcome = package.loaded["menu.welcome.welcome"]
        local confirmation = require("utils.confirmation")
        local function doShowNewMap()
          menuBar.showModal("newMap")
        end
        -- Only show confirmation if a map has already been created after welcome flow
        if menuBar.mapSession.hasCreatedMap then
          confirmation.show(
            "Are you sure you want to start a new map?        \n All unsaved/unexported data will be lost!",
            doShowNewMap,
            function() end
          )
        else
          doShowNewMap()
        end
      end},
      {label = "divider"},
      {label = "Import .txt", action = function() importFileDialog(".txt", import.txt) end},
      {label = "Import json", action = function() importFileDialog(".json", import.json) end},
      {label = "Import lua", action = function() importFileDialog(".lua", import.lua) end},
      {label = "divider"},
      {label = "Export .txt", action = function() exportFileDialog(".txt", export.txt) end},
      {label = "Export json", action = function() exportFileDialog(".json", export.json) end},
      {label = "Export lua", action = function() exportFileDialog(".lua", export.lua) end}
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
  local welcome = package.loaded["menu.welcome.welcome"]
  local modalActive = (welcome and welcome.visible) or (menuBar.modal and menuBar.modal.visible)
  for i, item in ipairs(menuBar.items) do
    local itemWidth = love.graphics.getFont():getWidth(item.label) + 16
    if not modalActive and (menuBar.isMouseOverMenuItem(x, 0, itemWidth, menuBar.height) or menuBar.activeDropdown == i) then
      love.graphics.setColor(0.8, 0.8, 1.0)
      love.graphics.rectangle("fill", x, 0, itemWidth, menuBar.height)
      love.graphics.setColor(0, 0, 0)
    end
    love.graphics.print(item.label, x + 8, 5)
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
  -- Draw modal dialog if visible
  menuBar.drawModal()
end
-- removed extra end

function menuBar.drawDropdown(menuIndex)
  local menuItem = menuBar.items[menuIndex]
  if not menuItem then return end
  
  local itemHeight = 25
  local dividerHeight = 8
  local dropdownHeight = 0
  for _, item in ipairs(menuItem.items) do
    if item.label == "divider" then
      dropdownHeight = dropdownHeight + dividerHeight
    else
      dropdownHeight = dropdownHeight + itemHeight
    end
  end

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
    if item.label == "divider" then
      love.graphics.setColor(0.7, 0.7, 0.7)
      love.graphics.line(menuBar.dropdownX + 8, y + dividerHeight/2, menuBar.dropdownX + menuBar.dropdownWidth - 8, y + dividerHeight/2)
      love.graphics.setColor(0, 0, 0)
      y = y + dividerHeight
    else
      local isHovered = menuBar.isMouseOverMenuItem(menuBar.dropdownX, y, menuBar.dropdownWidth, itemHeight)
      if isHovered then
        love.graphics.setColor(0.8, 0.8, 1.0)
        love.graphics.rectangle("fill", menuBar.dropdownX, y, menuBar.dropdownWidth, itemHeight)
        love.graphics.setColor(0, 0, 0)
      end
      love.graphics.print(item.label, menuBar.dropdownX + 10, y + 5)
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
          menuBar.dropdownOpenTime = 0 -- Reset open timer
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
        if item.label ~= "divider" and item.x and item.y and menuBar.isMouseOverMenuItem(item.x, item.y, item.w, item.h) then
          if item.action then item.action() end
          menuBar.activeDropdown = nil
          return true
        end
      end
    else
      menuBar.activeDropdown = nil
      return false
    end
  end
  
  return false
end

function menuBar.update()
  -- Add a short delay before allowing dropdown to auto-close
  if menuBar.activeDropdown then
    menuBar.dropdownOpenTime = (menuBar.dropdownOpenTime or 0) + 1
    local mouseX, mouseY = love.mouse.getPosition()
    local minY = menuBar.height
    local maxY = menuBar.height + (menuBar.dropdownHeight or 0)
    local minX = menuBar.dropdownX
    local maxX = menuBar.dropdownX + (menuBar.dropdownWidth or 0)
    -- Also get the menu bar link area
    local link = menuBar.items[menuBar.activeDropdown]
    local linkX = link and link.x or 0
    local linkY = link and link.y or 0
    local linkW = link and link.w or 0
    local linkH = link and link.h or 0
    local overDropdown = (mouseY >= minY and mouseY <= maxY and mouseX >= minX and mouseX <= maxX)
    local overLink = (mouseX >= linkX and mouseX <= linkX + linkW and mouseY >= linkY and mouseY <= linkY + linkH)

    -- Smooth switching: if mouse is over another menu bar link, switch dropdown
    for k, item in pairs(menuBar.items) do
      if k ~= menuBar.activeDropdown then
        if mouseX >= item.x and mouseX <= item.x + item.w and mouseY >= item.y and mouseY <= item.y + item.h then
          menuBar.activeDropdown = k
          menuBar.dropdownOpenTime = 0
          break
        end
      end
    end

    if menuBar.dropdownOpenTime > 10 then -- ~10 frames delay
      if not overDropdown and not overLink then
        menuBar.activeDropdown = nil
        menuBar.dropdownOpenTime = 0
      end
    end
  end
end

function menuBar.showAbout()
  love.window.showMessageBox("About TileMapper", 
    "TileMapper v1.0\n\nA tile-based map editor built with Love2D\n\nFeatures:\n- Visual tile placement\n- Multiple export formats\n- Fullscreen support\n- Multiple Tileset handling", 
    "info")
end

function menuBar.showControls()
  love.window.showMessageBox("Controls", 
    "Mouse Controls:\n- Left Click: Place tile\n- Right Click: Erase\n- Mouse Wheel: Zoom (map area) or Scroll (tileset area)\n\nKeyboard:\n- F11 or Alt+Enter: Toggle fullscreen\n- WASD: Move camera\n- Ctrl +/-: Zoom in/out\n\nMenu: Use the menu bar above", 
    "info")
end

return menuBar