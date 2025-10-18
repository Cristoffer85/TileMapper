local button = {}
button.bg = {}
button.bgInput = {}
button.list = {}
button._loaded = false

-- Function to load all button images
function button.load()
  if button._loaded then return end
  
  -- Use simple asset paths - assets will be available in src directory
  
  --Background
  button.bg.on = love.graphics.newImage("assets/button/bgButtonOn.png")
  button.bg.off = love.graphics.newImage("assets/button/bgButtonOff.png")
  button.bg.over = love.graphics.newImage("assets/button/bgButtonOver.png")

  button.bgInput.on = love.graphics.newImage("assets/button/bgInputOn.png")
  button.bgInput.off = love.graphics.newImage("assets/button/bgInputOff.png")
  button.bgInput.over = love.graphics.newImage("assets/button/bgInputOver.png")


  --Tool
  --button.list["select"] = love.graphics.newImage("assets/button/toolButtonSelect.png")
  button.list["pen"] = love.graphics.newImage("assets/button/toolButtonPen.png")
  button.list["erase"] = love.graphics.newImage("assets/button/toolButtonErase.png")
  button.list["fill"] = love.graphics.newImage("assets/button/toolButtonFill.png")
  --button.list["tileSwapper"] = love.graphics.newImage("assets/button/toolButtonTileSwapper.png")
  button.list["tilePicker"] = love.graphics.newImage("assets/button/toolButtonTilePicker.png")
  button.list["camera"] = love.graphics.newImage("assets/button/toolButtonCamera.png")

  --Action
  button.list["grid"] = love.graphics.newImage("assets/button/actionButtonGrid.png")
  button.list["resetPos"] = love.graphics.newImage("assets/button/actionButtonResetPos.png")
  button.list["resetMap"] = love.graphics.newImage("assets/button/actionButtonResetMap.png")

  --Import/Export
  button.list["exportLua"] = love.graphics.newImage("assets/button/actionButtonExportLua.png")
  button.list["exportTxt"] = love.graphics.newImage("assets/button/actionButtonExportTxt.png")
  button.list["exportJson"] = love.graphics.newImage("assets/button/actionButtonExportJson.png")
  button.list["importLua"] = love.graphics.newImage("assets/button/actionButtonImportLua.png")
  button.list["importTxt"] = love.graphics.newImage("assets/button/actionButtonImportTxt.png")
  button.list["importJson"] = love.graphics.newImage("assets/button/actionButtonImportJson.png")

  button._loaded = true
end

return button