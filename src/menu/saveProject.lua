-- Save project functionality
local saveProject = {}

function saveProject.save()
  if not export or not export.txt then
    love.window.showMessageBox("Export Error", "Export functionality not available.", "error")
    return
  end
  
  -- Save in all available formats
  for _, format in ipairs(export.list) do
    if export[format] then
      export[format]()
    end
  end
  
  love.window.showMessageBox("Project Saved", "Project saved successfully!", "info")
end

function saveProject.saveAs(filename)
  -- This would implement save as functionality
  -- For now, just call the regular save
  saveProject.save()
end

function saveProject.autoSave()
  -- This could implement automatic saving
  if export and export.txt then
    export.txt()
  end
end

return saveProject