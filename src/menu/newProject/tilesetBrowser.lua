-- Tileset browser UI and functionality
local tilesetBrowser = {}



function tilesetBrowser.draw(menu, data)
  -- Overlay
  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.rectangle("fill", 0, 0, window.width, window.height)
  
  local browserWidth = 350
  local browserHeight = 450
  local browserX = (window.width - browserWidth) / 2
  local browserY = (window.height - browserHeight) / 2
  
  -- Background
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle("fill", browserX, browserY, browserWidth, browserHeight)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", browserX, browserY, browserWidth, browserHeight)
  
  -- Title and instructions
  tilesetBrowser.drawHeader(browserX, browserY, browserWidth)
  
  -- File list
  local files = tilesetBrowser.getFiles()
  tilesetBrowser.drawFileList(menu, browserX, browserY, browserWidth, files, data)
  
  -- Buttons
  tilesetBrowser.drawButtons(menu, browserX, browserY, browserWidth, data)
end

function tilesetBrowser.drawHeader(browserX, browserY, browserWidth)
  love.graphics.setColor(1, 1, 1)
  local title = "Select Tileset"
  local titleWidth = love.graphics.getFont():getWidth(title)
  love.graphics.print(title, browserX + (browserWidth - titleWidth) / 2, browserY + 10)
  
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.print("From /tileset folder or Browse for external file:", browserX + 10, browserY + 35)
end

function tilesetBrowser.drawFileList(menu, browserX, browserY, browserWidth, files, data)
  local listY = browserY + 60
  local itemHeight = 25
  local maxItems = 10
  
  if #files == 0 then
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("No tileset files found.", browserX + 20, listY)
    love.graphics.print("Place .png files in the /tileset folder", browserX + 20, listY + 20)
    return
  end
  
  for i = 1, math.min(#files, maxItems) do
    local file = files[i]
    local itemY = listY + (i - 1) * (itemHeight + 2)
    local itemX = browserX + 10
    local itemW = browserWidth - 20
    
    -- Background
    local isHovered = menu.isMouseOver(itemX, itemY, itemW, itemHeight)
    local isSelected = (not data.isExternalFile and data.tilesetPath == file)
    
    love.graphics.setColor(isHovered and {0.4, 0.4, 0.6} or {0.3, 0.3, 0.3})
    love.graphics.rectangle("fill", itemX, itemY, itemW, itemHeight)
    
    love.graphics.setColor(isSelected and {0.5, 0.7, 0.5} or {0.6, 0.6, 0.6})
    love.graphics.rectangle("line", itemX, itemY, itemW, itemHeight)
    
    -- File name
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(file, itemX + 5, itemY + 3)
  end
  
  -- Store click areas separately to preserve files array
  tilesetBrowser.fileClickAreas = {}
  for i = 1, math.min(#files, maxItems) do
    local file = files[i]
    local itemY = listY + (i - 1) * (itemHeight + 2)
    local itemX = browserX + 10
    local itemW = browserWidth - 20
    tilesetBrowser.fileClickAreas[i] = {name = file, x = itemX, y = itemY, w = itemW, h = itemHeight}
  end
  
  -- Show external file selection if applicable
  if data.isExternalFile and data.tilesetDisplayName then
    local externalY = listY + (math.min(#files, maxItems) * (itemHeight + 2)) + 10
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("External file selected:", browserX + 10, externalY)
    
    love.graphics.setColor(0.3, 0.6, 0.3)
    love.graphics.rectangle("fill", browserX + 10, externalY + 18, browserWidth - 20, itemHeight)
    love.graphics.setColor(0.5, 0.8, 0.5)
    love.graphics.rectangle("line", browserX + 10, externalY + 18, browserWidth - 20, itemHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(data.tilesetDisplayName, browserX + 15, externalY + 21)
  end
end



function tilesetBrowser.drawButtons(menu, browserX, browserY, browserWidth, data)
  local browserHeight = 450
  local buttonY = browserY + browserHeight - 50
  local buttonW = 80
  local buttonH = 25
  local buttonSpacing = 15
  local totalButtonWidth = 3 * buttonW + 2 * buttonSpacing
  local startX = browserX + (browserWidth - totalButtonWidth) / 2
  
  local selectButtonX = startX
  local browseButtonX = startX + buttonW + buttonSpacing
  local cancelButtonX = startX + 2 * (buttonW + buttonSpacing)
  
  -- Select button
  love.graphics.setColor(data.tilesetPath ~= "" and {0.2, 0.6, 0.2} or {0.3, 0.3, 0.3})
  love.graphics.rectangle("fill", selectButtonX, buttonY, buttonW, buttonH)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", selectButtonX, buttonY, buttonW, buttonH)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Select", selectButtonX + 25, buttonY + 3)
  
  -- Browse button
  love.graphics.setColor(0.2, 0.4, 0.6)
  love.graphics.rectangle("fill", browseButtonX, buttonY, buttonW, buttonH)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", browseButtonX, buttonY, buttonW, buttonH)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Browse", browseButtonX + 20, buttonY + 3)
  
  -- Cancel button
  love.graphics.setColor(0.6, 0.2, 0.2)
  love.graphics.rectangle("fill", cancelButtonX, buttonY, buttonW, buttonH)
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.rectangle("line", cancelButtonX, buttonY, buttonW, buttonH)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Cancel", cancelButtonX + 20, buttonY + 3)
  
  -- Store buttons
  tilesetBrowser.buttons = {
    select = {x = selectButtonX, y = buttonY, w = buttonW, h = buttonH},
    browse = {x = browseButtonX, y = buttonY, w = buttonW, h = buttonH},
    cancel = {x = cancelButtonX, y = buttonY, w = buttonW, h = buttonH}
  }
end

function tilesetBrowser.getFiles()
  local files = {}
  local baseDirectory = love.filesystem.getSourceBaseDirectory()
  
  local commonFiles = {
    "TileSheet2.png", "tileset.png", "tiles.png", "tilesheet.png",
    "tilemap.png", "terrain.png", "ground.png", "walls.png"
  }
  
  for _, file in ipairs(commonFiles) do
    local fullPath = baseDirectory .. "/tileset/" .. file
    local f = io.open(fullPath, "rb")
    if f then
      f:close()
      table.insert(files, file)
    end
  end
  
  return files
end

function tilesetBrowser.mousepressed(x, y, menu, data, controller)
  local buttons = tilesetBrowser.buttons
  if not buttons then return false end
  
  -- File clicks
  if tilesetBrowser.fileClickAreas then
    for _, file in ipairs(tilesetBrowser.fileClickAreas) do
      if file.x and menu.isMouseOver(file.x, file.y, file.w, file.h) then
        data.tilesetPath = file.name
        data.isExternalFile = false
        return true
      end
    end
  end
  
  -- Button clicks
  if menu.isMouseOver(buttons.select.x, buttons.select.y, buttons.select.w, buttons.select.h) then
    if data.tilesetPath ~= "" then
      controller.showTilesetBrowser = false
      tilesetBrowser.reset()
    end
    return true
  elseif menu.isMouseOver(buttons.browse.x, buttons.browse.y, buttons.browse.w, buttons.browse.h) then
    tilesetBrowser.openFileBrowser(data)
    return true
  elseif menu.isMouseOver(buttons.cancel.x, buttons.cancel.y, buttons.cancel.w, buttons.cancel.h) then
    controller.showTilesetBrowser = false
    tilesetBrowser.reset()
    return true
  end
  
  return false
end

function tilesetBrowser.textinput(text)
  return false
end

function tilesetBrowser.keypressed(key, controller)
  if key == "escape" then
    controller.showTilesetBrowser = false
    tilesetBrowser.reset()
    return true
  end
  return false
end

function tilesetBrowser.openFileBrowser(data)
  if love.system.getOS() == "Windows" then
    -- Use FFI to call Windows API directly for completely silent file dialog
    local ffi = require("ffi")
    
    -- Define Windows API functions
    ffi.cdef[[
      typedef struct {
        unsigned long lStructSize;
        void* hwndOwner;
        void* hInstance;
        const char* lpstrFilter;
        char* lpstrCustomFilter;
        unsigned long nMaxCustFilter;
        unsigned long nFilterIndex;
        char* lpstrFile;
        unsigned long nMaxFile;
        char* lpstrFileTitle;
        unsigned long nMaxFileTitle;
        const char* lpstrInitialDir;
        const char* lpstrTitle;
        unsigned long Flags;
        unsigned short nFileOffset;
        unsigned short nFileExtension;
        const char* lpstrDefExt;
        void* lCustData;
        void* lpfnHook;
        const char* lpTemplateName;
      } OPENFILENAMEA;
      
      int GetOpenFileNameA(OPENFILENAMEA* lpofn);
      void* GetModuleHandleA(const char* lpModuleName);
      char* GetEnvironmentStringsA();
      int FreeEnvironmentStringsA(char* lpszEnvironmentBlock);
      unsigned long GetEnvironmentVariableA(const char* lpName, char* lpBuffer, unsigned long nSize);
    ]]
    
    -- Load required Windows DLLs
    local comdlg32 = ffi.load("comdlg32")
    local kernel32 = ffi.load("kernel32")
    
    -- Create file buffer
    local fileBuffer = ffi.new("char[260]")  -- MAX_PATH
    fileBuffer[0] = 0  -- Null terminate
    
    -- Get user's Pictures folder path
    local picturesPath = ffi.new("char[260]")
    kernel32.GetEnvironmentVariableA("USERPROFILE", picturesPath, 260)
    local initialDir = ffi.string(picturesPath) .. "\\Pictures"
    
    -- Set up OPENFILENAME structure
    local ofn = ffi.new("OPENFILENAMEA")
    ofn.lStructSize = ffi.sizeof("OPENFILENAMEA")
    ofn.hwndOwner = nil
    ofn.lpstrFilter = "PNG Images (*.png)\0*.png\0All Files (*.*)\0*.*\0\0"
    ofn.nFilterIndex = 1
    ofn.lpstrFile = fileBuffer
    ofn.nMaxFile = 260
    ofn.lpstrInitialDir = initialDir
    ofn.lpstrTitle = "Select Tileset Image"
    ofn.Flags = 0x00001000 + 0x00000004  -- OFN_FILEMUSTEXIST + OFN_HIDEREADONLY
    
    -- Show file dialog
    local result = comdlg32.GetOpenFileNameA(ofn)
    
    if result ~= 0 then
      -- File was selected
      local filePath = ffi.string(fileBuffer)
      
      if filePath ~= "" and filePath:lower():match("%.png$") then
        local filename = filePath:match("([^\\]+)$") or filePath:match("([^/]+)$") or filePath
        
        data.tilesetPath = filePath
        data.tilesetDisplayName = filename  
        data.isExternalFile = true
        
        love.window.showMessageBox("File Selected", "Selected: " .. filename, "info")
      else
        love.window.showMessageBox("Invalid Selection", "Please select a PNG image file.", "error")
      end
    end
    -- If result is 0, user canceled - do nothing
    
  else
    -- For Linux/Mac - zenity is usually fast and silent
    local command = 'zenity --file-selection --title="Select Tileset Image" --file-filter="PNG Images | *.png" 2>/dev/null'
    local handle = io.popen(command)
    if handle then
      local result = handle:read("*a")
      handle:close()
      
      if result and result:match("%S") then
        local filePath = result:gsub("[\r\n]", "")
        local filename = filePath:match("([^/]+)$") or filePath
        
        data.tilesetPath = filePath
        data.tilesetDisplayName = filename
        data.isExternalFile = true
        
        love.window.showMessageBox("File Selected", "Selected: " .. filename, "info")
      end
    end
  end
end

function tilesetBrowser.reset()
  tilesetBrowser.fileClickAreas = {}
end

return tilesetBrowser