-- Tileset scrolling functionality
local tilesetScroll = {}

tilesetScroll.scrollOffset = 0
tilesetScroll.scrollSpeed = 32
tilesetScroll.collapsedSections = {}  -- Track which tileset sections are collapsed
tilesetScroll.sectionHeight = 25     -- Height of each section header

function tilesetScroll.scrollTileset(deltaY)
  if mouse.zone == "rightBar" then
    tilesetScroll.scrollOffset = tilesetScroll.scrollOffset + (deltaY * tilesetScroll.scrollSpeed)
    
    -- Prevent scrolling above top (max scroll is 0)
    tilesetScroll.scrollOffset = math.min(0, tilesetScroll.scrollOffset)
    
    return true
  end
  return false
end

function tilesetScroll.resetScroll()
  tilesetScroll.scrollOffset = 0
  tilesetScroll.collapsedSections = {}
end

function tilesetScroll.getScrollOffset()
  return tilesetScroll.scrollOffset
end

function tilesetScroll.getCollapsedSections()
  return tilesetScroll.collapsedSections
end

function tilesetScroll.getSectionHeight()
  return tilesetScroll.sectionHeight
end

function tilesetScroll.toggleSection(sectionKey)
  tilesetScroll.collapsedSections[sectionKey] = not tilesetScroll.collapsedSections[sectionKey]
end

return tilesetScroll