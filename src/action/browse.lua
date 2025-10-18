local browse = {}

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

local function getInitialDir()
  local userProfile = ffi.new("char[260]")
  kernel32.GetEnvironmentVariableA("USERPROFILE", userProfile, 260)
  return ffi.string(userProfile) .. "\\Documents"
end

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

function browse.saveFile(extension, title)
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
  ofn.lpstrTitle = title or "Select Export Location"
  ofn.Flags = 0x00000002 + 0x00000004  -- OFN_OVERWRITEPROMPT + OFN_HIDEREADONLY
  local result = comdlg32.GetSaveFileNameA(ofn)
  if result ~= 0 then
    return ffi.string(fileBuffer)
  else
    return nil
  end
end

return browse
