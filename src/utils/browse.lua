-- Helper class that helps provide file browsing capabilities with native Windows dialogs
-- Only windows is currently supported at this time

local browse = {}
local grid = require("ui.grid")

-- Windows File Dialog via FFI = Foreign Function Interface.
local ffi = require("ffi")
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
  int GetSaveFileNameA(OPENFILENAMEA* lpofn);
  void* GetModuleHandleA(const char* lpModuleName);
  unsigned long GetEnvironmentVariableA(const char* lpName, char* lpBuffer, unsigned long nSize);
]]
local comdlg32 = ffi.load("comdlg32")
local kernel32 = ffi.load("kernel32")

-- Helper function to get user's Documents folder as initial directory
local function getInitialDir()
  local userProfile = ffi.new("char[260]")
  kernel32.GetEnvironmentVariableA("USERPROFILE", userProfile, 260)
  return ffi.string(userProfile) .. "\\Documents"
end

-- Open file dialog
function browse.openFile(extension, title)
  local fileBuffer = ffi.new("char[260]")
  fileBuffer[0] = 0
  local ofn = ffi.new("OPENFILENAMEA")
  ofn.lStructSize = ffi.sizeof("OPENFILENAMEA")
  ofn.hwndOwner = nil
  ofn.lpstrFilter = string.format("%s Files (*%s)\0*%s\0All Files (*.*)\0*.*\0\0", extension:upper(), extension, extension)
  ofn.nFilterIndex = 1
  ofn.lpstrFile = fileBuffer
  ofn.nMaxFile = 260
  ofn.lpstrInitialDir = getInitialDir()
  ofn.lpstrTitle = title or "Select File to Open"
  ofn.Flags = 0x00000008 -- OFN_FILEMUSTEXIST
  local result = comdlg32.GetOpenFileNameA(ofn)
  if result ~= 0 then
    return ffi.string(fileBuffer)
  else
    return nil
  end
end

-- Save file dialog
function browse.saveFile(extension, title, defaultFilename)
  local fileBuffer = ffi.new("char[260]")
  fileBuffer[0] = 0
  if defaultFilename and #defaultFilename > 0 then
    local ext = extension:gsub("^%.","")
    local filename = defaultFilename
    if not filename:lower():match("%..+$") then
      filename = filename .. ext
    end
    ffi.copy(fileBuffer, filename)
  end
  local ofn = ffi.new("OPENFILENAMEA")
  ofn.lStructSize = ffi.sizeof("OPENFILENAMEA")
  ofn.hwndOwner = nil
  ofn.lpstrFilter = string.format("%s Files (*%s)\0*%s\0All Files (*.*)\0*.*\0\0", extension:upper(), extension, extension)
  ofn.nFilterIndex = 1
  ofn.lpstrFile = fileBuffer
  ofn.nMaxFile = 260
  ofn.lpstrInitialDir = getInitialDir()
  ofn.lpstrTitle = title or "Select Export Location"
  ofn.Flags = 0x00000002 + 0x00000004  -- OFN_OVERWRITEPROMPT + OFN_HIDEREADONLY
  local result = comdlg32.GetSaveFileNameA(ofn)
  if result ~= 0 then
    return ffi.string(fileBuffer)
  else
    return nil
  end
end

-- Open tileset image and copy to tileset folder
function browse.openTilesetImage()
  local filePath = browse.openFile(".png", "Select Tileset Image")
  if not filePath or filePath == "" or not filePath:lower():match("%.png$") then
    return false
  end
  local filename = filePath:match("([^\\]+)$") or filePath:match("([^/]+)$") or filePath
  local baseDirectory = love.filesystem.getSourceBaseDirectory()
  local targetDir = baseDirectory .. "/src/assets/tileset/"
  local targetPath = targetDir .. filename
  -- Read source file
  local sourceFile = io.open(filePath, "rb")
  if not sourceFile then
    love.window.showMessageBox("Copy Error", "Could not read tileset: " .. filePath, "error")
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
  -- Add tileset to grid
  if grid.addSingleTileset(filename) then
    local tilesetScroll = require("panel.rightpanel.tilesetScroll")
    tilesetScroll.resetScroll()
    return true
  end
  return false
end

return browse