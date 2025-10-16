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
  -- Don't reset collapsed sections - preserve their state!
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
  -- Save states immediately when they change
  tilesetScroll.saveToFile()
end

-- Initialize all tilesets as collapsed by default
function tilesetScroll.initializeCollapsedStates(tilesetPaths)
  if not tilesetPaths then return end
  
  -- If no states were loaded from file, start with all collapsed
  local hasAnyStates = false
  for k, v in pairs(tilesetScroll.collapsedSections) do
    hasAnyStates = true
    break
  end
  
  for i, tilesetPath in ipairs(tilesetPaths) do
    local sectionKey = "tileset_" .. i
    -- Set to collapsed if: no saved states exist, or this specific section isn't saved
    if not hasAnyStates or tilesetScroll.collapsedSections[sectionKey] == nil then
      tilesetScroll.collapsedSections[sectionKey] = true  -- Collapsed by default
    end
  end
end

-- Set a specific tileset as collapsed (for new additions)
function tilesetScroll.setTilesetCollapsed(tilesetIndex, collapsed)
  local sectionKey = "tileset_" .. tilesetIndex
  tilesetScroll.collapsedSections[sectionKey] = collapsed
end

-- Save states to a simple string format for persistence
function tilesetScroll.saveStates()
  local states = {}
  for key, value in pairs(tilesetScroll.collapsedSections) do
    if value then  -- Only save collapsed ones to keep it minimal
      table.insert(states, key)
    end
  end
  return table.concat(states, ",")
end

-- Load states from string format
function tilesetScroll.loadStates(stateString)
  tilesetScroll.collapsedSections = {}
  if stateString and stateString ~= "" then
    for key in string.gmatch(stateString, "([^,]+)") do
      tilesetScroll.collapsedSections[key] = true
    end
  end
end

-- Load collapsed states from file (called on app start)
function tilesetScroll.loadFromFile()
  local success, contents = pcall(love.filesystem.read, "tileset_states.txt")
  if success and contents then
    tilesetScroll.loadStates(contents)
  end
end

-- Save collapsed states to file (called when states change)
function tilesetScroll.saveToFile()
  local stateString = tilesetScroll.saveStates()
  pcall(love.filesystem.write, "tileset_states.txt", stateString)
end

return tilesetScroll