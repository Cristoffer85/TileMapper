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
  local buttonText = "Browse Tileset"
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
      
      -- Copy file to tileset folder
      if browseButton.copyTilesetToProject(filePath, filename) then
        -- Fast addition of single tileset (no full reload needed!)
        if grid.addSingleTileset(filename) then
          -- Reset scroll position for better UX
          local tilesetScroll = require("panel.rightpanel.tilesetScroll")
          tilesetScroll.resetScroll()
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