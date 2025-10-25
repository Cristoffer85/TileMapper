-- Tileset click handling functionality
local tilesetClick = {}
local tilesetDisplay = require("panel.rightpanel.tilesetDisplay")
local tilesetScroll = require("panel.rightpanel.tilesetScroll")

function tilesetClick.handleTilesetClick(x, y)
  if not grid.multiTilesetMode or not grid.tilesets then
    return false
  end

  -- First check section headers
  local pX = 10
  local rightBarWidth = 200  -- rightPanel.width
  local width = rightBarWidth - pX * 2
  local rightBarX = window.width - rightBarWidth

  for tilesetIndex, sectionInfo in pairs(tilesetDisplay.getSectionPositions()) do
    local sectionKey = "tileset_" .. tilesetIndex

    -- Check header click
    if y >= sectionInfo.headerY and y <= sectionInfo.headerY + sectionInfo.headerHeight and 
       x >= rightBarX + 5 and x <= rightBarX + width - 5 then
      tilesetScroll.toggleSection(sectionKey)
      return true
    end
  end

  -- Check tile clicks in expanded sections
  local tilesetClickAreas = tilesetDisplay.getTilesetClickAreas()
  if tilesetClickAreas then
    for tilesetIndex, tileAreas in pairs(tilesetClickAreas) do
      local sectionKey = "tileset_" .. tilesetIndex

      -- Only check tiles if section is expanded
      if not tilesetScroll.getCollapsedSections()[sectionKey] then
        for i, tileArea in ipairs(tileAreas) do
          if x >= tileArea.x and x <= tileArea.x + tileArea.w and 
             y >= tileArea.y and y <= tileArea.y + tileArea.h then
            mouse.currentColor = tileArea.tileId
            mouse.fillColor = tileArea.tileId

            -- Switch to pen tool for painting
            if tool.current ~= "fill" then
              tool.current = "pen"
            end

            return true
          end
        end
      end
    end
  end
  return false
end

return tilesetClick